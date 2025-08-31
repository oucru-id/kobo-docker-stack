#!/bin/bash
set -e

echo 'Detecting MongoDB configuration...'

# Configuration
MAX_ATTEMPTS=40
SLEEP_INTERVAL=3

# Function to detect if we're using MongoDB Atlas
is_mongodb_atlas() {
  if [[ "$MONGO_DB_URL" == *"mongodb+srv://"* ]] || [[ "$MONGO_DB_URL" == *".mongodb.net"* ]]; then
      return 0  # true
  else
      return 1  # false
  fi
}

# Function to wait for local MongoDB
wait_for_local_mongo() {
  echo 'Detected local MongoDB configuration.'
  echo "Waiting for container at $KOBO_MONGO_HOST:$KOBO_MONGO_PORT..."
  
  if command -v wait-for-it >/dev/null 2>&1; then
      wait-for-it -t $MAX_ATTEMPTS -h $KOBO_MONGO_HOST -p $KOBO_MONGO_PORT
      echo 'Local MongoDB container is up.'
  else
      # Fallback TCP test
      ATTEMPT=1
      while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
          echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: Testing local MongoDB connection..."
          
          if timeout 5 bash -c "</dev/tcp/$KOBO_MONGO_HOST/$KOBO_MONGO_PORT" 2>/dev/null; then
              echo 'Local MongoDB container is up.'
              return 0
          fi
          
          echo "Connection failed. Retrying in $SLEEP_INTERVAL seconds..."
          sleep $SLEEP_INTERVAL
          ATTEMPT=$((ATTEMPT + 1))
      done
      
      echo 'ERROR: Could not connect to local MongoDB after $MAX_ATTEMPTS attempts'
      return 1
  fi
}

# Function to wait for MongoDB Atlas using Python
wait_for_atlas_mongo() {
  echo 'Detected MongoDB Atlas configuration.'
  echo 'Testing MongoDB Atlas connection using Python...'
  
  # Create Python script for testing MongoDB connection
  cat > /tmp/test_mongo.py << 'EOF'
import os
import sys
import time

try:
  from pymongo import MongoClient
  from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
  PYMONGO_AVAILABLE = True
except ImportError:
  PYMONGO_AVAILABLE = False

def test_with_pymongo(mongo_url, max_attempts, sleep_interval):
  for attempt in range(1, max_attempts + 1):
      try:
          print(f'Attempt {attempt}/{max_attempts}: Testing MongoDB Atlas with PyMongo...')
          client = MongoClient(mongo_url, serverSelectionTimeoutMS=5000)
          client.admin.command('ping')
          print('MongoDB Atlas connection successful!')
          client.close()
          return True
      except (ConnectionFailure, ServerSelectionTimeoutError) as e:
          print(f'Connection failed: {str(e)[:100]}...')
          if attempt < max_attempts:
              print(f'Retrying in {sleep_interval} seconds...')
              time.sleep(sleep_interval)
      except Exception as e:
          print(f'Unexpected error: {e}')
          return False
  return False

def test_basic_connectivity(mongo_url, max_attempts, sleep_interval):
  import socket
  import re
  
  # Extract host from MongoDB URL
  match = re.search(r'@([^/?]+)', mongo_url)
  if not match:
      print('Could not extract host from MongoDB URL')
      return False
  
  host = match.group(1).split(':')[0]
  port = 27017
  
  for attempt in range(1, max_attempts + 1):
      try:
          print(f'Attempt {attempt}/{max_attempts}: Testing basic connectivity to {host}:{port}...')
          sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
          sock.settimeout(5)
          result = sock.connect_ex((host, port))
          sock.close()
          
          if result == 0:
              print('Basic connectivity successful!')
              return True
          else:
              print(f'Connection failed (error code: {result})')
              
      except Exception as e:
          print(f'Connection test failed: {e}')
          
      if attempt < max_attempts:
          print(f'Retrying in {sleep_interval} seconds...')
          time.sleep(sleep_interval)
  
  return False

def main():
  mongo_url = os.environ.get('MONGO_DB_URL')
  if not mongo_url:
      print('ERROR: MONGO_DB_URL environment variable not set')
      sys.exit(1)
  
  max_attempts = int(os.environ.get('MAX_ATTEMPTS', '40'))
  sleep_interval = int(os.environ.get('SLEEP_INTERVAL', '3'))
  
  if PYMONGO_AVAILABLE:
      success = test_with_pymongo(mongo_url, max_attempts, sleep_interval)
  else:
      print('PyMongo not available, using basic connectivity test...')
      success = test_basic_connectivity(mongo_url, max_attempts, sleep_interval)
  
  sys.exit(0 if success else 1)

if __name__ == '__main__':
  main()
EOF

  # Run the Python script
  export MAX_ATTEMPTS SLEEP_INTERVAL
  if python3 /tmp/test_mongo.py; then
      rm -f /tmp/test_mongo.py
      return 0
  else
      rm -f /tmp/test_mongo.py
      return 1
  fi
}

# Main logic
if [ -n "$MONGO_DB_URL" ] && is_mongodb_atlas; then
  wait_for_atlas_mongo
elif [ -n "$KOBO_MONGO_HOST" ] && [ -n "$KOBO_MONGO_PORT" ]; then
  wait_for_local_mongo
else
  echo 'ERROR: Could not determine MongoDB configuration.'
  echo 'Please ensure either:'
  echo '  - MONGO_DB_URL is set for MongoDB Atlas, or'
  echo '  - KOBO_MONGO_HOST and KOBO_MONGO_PORT are set for local MongoDB'
  exit 1
fi

echo 'MongoDB is ready!'
