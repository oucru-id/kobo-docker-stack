# KoBo Environment Configuration

This directory contains environment configuration files for the KoBo Docker stack. Environment variables are managed using template files for easy setup and configuration.

## Directory Structure

```
kobo-env/
├── README.md                 # This file
├── fstab                     # Google Cloud Storage mount configuration
├── fstab.example             # Template for GCS mount configuration
├── envfiles/                 # Environment files directory
│   ├── *.txt.example        # Template files (committed to git)
│   ├── *.txt                # Actual environment files (ignored by git)
│   └── README.md            # Environment files documentation
├── enketo_express/
│   ├── config.json          # Enketo configuration (ignored by git)
│   └── config.json.example  # Enketo configuration template
└── postgres/
    └── conf/
        ├── postgres.conf         # PostgreSQL configuration (ignored by git)
        └── postgres.conf.example # PostgreSQL configuration template
```

## Environment Files

The following environment files are managed using templates:

- `aws.txt` - AWS S3 storage configuration
- `databases.txt` - Database connection settings
- `django.txt` - Django application settings
- `domains.txt` - Domain and URL configuration
- `external_services.txt` - External service integrations
- `smtp.txt` - Email/SMTP configuration

## Getting Started

### Initial Setup

1. **Copy template files**: Use the management script to create environment files from templates
   ```bash
   ../manage-env.sh -c
   ```

2. **Edit configuration**: Update the `.txt` files with your actual values
   ```bash
   # Edit each file with your specific configuration
   nano envfiles/domains.txt
   nano envfiles/django.txt
   nano envfiles/databases.txt
   # ... etc
   ```

3. **Start services**: Run Docker Compose with your configured environment
   ```bash
   cd ..
   docker-compose up -d
   ```

## Usage

### Managing Environment Files

Use the `../manage-env.sh` script to manage environment files:

```bash
# Copy template files to create .txt files
../manage-env.sh -c

# Clean up .txt files (keeps templates)
../manage-env.sh -l

# Show help
../manage-env.sh -h
```

### Development Workflow

1. **Initial setup**: Copy templates to create configuration files
   ```bash
   ../manage-env.sh -c
   ```

2. **Configure environment**: Edit the `.txt` files with your settings
   ```bash
   # Example: Configure domain settings
   nano envfiles/domains.txt
   ```

3. **Start development**: Run Docker services
   ```bash
   cd ..
   docker-compose up -d
   ```

4. **Clean up** (optional): Remove configuration files when done
   ```bash
   cd kobo-env
   ../manage-env.sh -l
   ```

### Docker Integration

Before running Docker Compose, ensure environment files exist:

```bash
# Create environment files from templates
../manage-env.sh -c

# Start KoBo services
cd ..
docker-compose up -d
```

## Configuration Files

All configuration files use a template-based approach for security:

### Environment Files (`envfiles/`)

1. **Copy example files**: Copy `.txt.example` files to `.txt` files
2. **Edit values**: Replace placeholder values with your actual configuration
3. **Keep secure**: The actual `.txt` files are ignored by Git

Example:
```bash
cp kobo-env/envfiles/django.txt.example kobo-env/envfiles/django.txt
# Edit django.txt with your actual values
```

**Available environment files:**
- `aws.txt.example` - AWS S3 configuration
- `databases.txt.example` - MongoDB, PostgreSQL, and Redis settings
- `django.txt.example` - Django application settings
- `domains.txt.example` - Domain and URL configuration
- `external_services.txt.example` - External service integrations
- `smtp.txt.example` - Email server configuration

### Application Configuration Files

#### Enketo Express Configuration

1. **Copy the example**: `cp kobo-env/enketo_express/config.json.example kobo-env/enketo_express/config.json`
2. **Configure settings**: Edit `config.json` with your actual values:
   - Server URL and API key for KoboToolbox integration
   - Encryption keys for form data security
   - Redis connection details for caching
   - Google Analytics and API keys
   - Support email address

#### PostgreSQL Configuration

1. **Copy the example**: `cp kobo-env/postgres/conf/postgres.conf.example kobo-env/postgres/conf/postgres.conf`
2. **Tune settings**: Adjust PostgreSQL parameters based on your server specifications:
   - Memory allocation (`shared_buffers`, `effective_cache_size`)
   - Connection limits (`max_connections`)
   - Performance tuning parameters

**Note**: Both `config.json` and `postgres.conf` are ignored by Git to protect sensitive configuration data.

### Required Files

These files must be configured for KoBo to work properly:

- **domains.txt**: Configure your domain names and subdomains
- **databases.txt**: Set up database connections (MongoDB, PostgreSQL)
- **django.txt**: Django application settings and secrets
- **config.json**: Enketo Express configuration
- **postgres.conf**: PostgreSQL database configuration

### Optional Files

- **aws.txt**: AWS S3 storage configuration (if using S3)
- **smtp.txt**: Email configuration (if sending emails)
- **external_services.txt**: Third-party service integrations

## Security Notes

- **Never commit `.txt` files** - They contain sensitive configuration data
- **Use strong passwords** - Generate secure passwords for database connections
- **Protect your server** - Ensure proper firewall and access controls
- **Regular backups** - Back up your configuration and data regularly

## Template Files

Template files (`.txt.example`) provide:
- Example configurations with placeholder values
- Documentation for each setting
- Safe defaults where applicable
- Comments explaining configuration options

## Troubleshooting

### Missing Environment Files
```
Error: Environment file not found
```
**Solution**: Run `../manage-env.sh -c` to create files from templates.

### Permission Denied
```
Permission denied: envfiles/domains.txt
```
**Solution**: Check file permissions and ensure you have write access.

### Docker Compose Fails
```
Error: Missing environment variables
```
**Solution**: Ensure all required `.txt` files exist and contain valid configuration.

## Team Setup

For new team members:

1. Clone the repository
2. Copy template files: `./manage-env.sh -c`
3. Get configuration values from team lead (securely)
4. Update `.txt` files with actual values
5. Start services: `docker-compose up -d`

## Google Cloud Storage Integration

### GCSFuse Mount Configuration

The `fstab` file contains mount configurations for Google Cloud Storage buckets using gcsfuse:

```bash
# Example fstab entries for KoBo media storage
spheeres-bucket_kobocat-media /opt/kobo-docker/.vols/kobocat_media_uploads gcsfuse rw,allow_other,implicit_dirs,key_file=/opt/kobo-docker/sa-key.json,uid=1000,gid=1000,file_mode=777,dir_mode=777,_netdev 0 0
spheeres-bucket_kpi-media /opt/kobo-docker/.vols/kpi_media gcsfuse rw,allow_other,implicit_dirs,key_file=/opt/kobo-docker/sa-key.json,uid=1000,gid=1000,file_mode=777,dir_mode=777,_netdev 0 0
```

### Prerequisites

1. **Install gcsfuse**: Install Google Cloud Storage FUSE on your system
   ```bash
   # Ubuntu/Debian
   curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
   echo "deb https://packages.cloud.google.com/apt gcsfuse-bionic main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
   sudo apt update && sudo apt install gcsfuse
   
   # macOS
   brew install gcsfuse
   ```

2. **Service Account Key**: Place your Google Cloud service account key at `/opt/kobo-docker/sa-key.json`
   ```bash
   # Copy your service account key to the expected location
   sudo cp /path/to/your/service-account-key.json /opt/kobo-docker/sa-key.json
   sudo chmod 600 /opt/kobo-docker/sa-key.json
   ```

3. **Create Mount Points**: Ensure mount directories exist
   ```bash
   sudo mkdir -p /opt/kobo-docker/.vols/kobocat_media_uploads
   sudo mkdir -p /opt/kobo-docker/.vols/kpi_media
   ```

### Mount Configuration

To enable GCS mounts:

1. **Update fstab**: Edit the `fstab` file with your bucket names
2. **Mount filesystems**: Use the fstab entries to mount GCS buckets
   ```bash
   # Mount all entries from fstab
   sudo mount -a
   
   # Or mount specific entries
   sudo mount /opt/kobo-docker/.vols/kobocat_media_uploads
   sudo mount /opt/kobo-docker/.vols/kpi_media
   ```

### Security Notes for GCS Integration

- **Protect service account key**: Ensure `sa-key.json` has restricted permissions (600)
- **Use least privilege**: Grant minimal required permissions to the service account
- **Rotate keys regularly**: Update service account keys periodically
- **Monitor access**: Enable audit logging for GCS bucket access

## Additional Resources

- [KoBo Toolbox Documentation](https://docs.kobotoolbox.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Environment Variables Best Practices](https://12factor.net/config)
- [Google Cloud Storage FUSE Documentation](https://cloud.google.com/storage/docs/gcs-fuse)
- [GCS Service Account Keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)