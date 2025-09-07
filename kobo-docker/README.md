# KoboToolbox Docker Deployment

This directory contains the Docker Compose configurations for deploying KoboToolbox services.

## Prerequisites

Before deploying, ensure you have completed the following setup steps:

1. **Configure KoboEnv**: Set up all configuration files in `../kobo-env/`. See the [kobo-env README](../kobo-env/README.md) for detailed instructions.
2. **Configure SSL Certificates**: Set up nginx-certbot in `../nginx-certbot/`. See the [nginx-certbot README](../nginx-certbot/README.md) for SSL configuration.
3. **Mount Google Cloud Storage**: Ensure gcsfuse is mounted to volume locations before deploying the frontend stack (see [GCS Integration](../kobo-env/README.md#google-cloud-storage-integration)).

## Domain Configuration

**Important**: When updating domains, you must update the following configuration files in `../kobo-env/`:

- `envfiles/domains.txt` - Update public and internal domain configurations
- `envfiles/django.txt` - Update Django-related domain settings
- `envfiles/databases.txt` - Update Redis domain configurations for public and internal/private access
- `enketo_express/config.json` - Update Enketo Express domain settings

**Additionally**, you must also update the Docker Compose files for domain changes:

- `docker-compose.backend.yml` and `docker-compose.backend.override.yml` - Update backend service domain configurations for public/internal/private networks
- `docker-compose.frontend.yml` and `docker-compose.frontend.override.yml` - Update frontend service domain configurations for public/internal/private networks

After updating these files, you may need to restart the services and update network domains to ensure proper connectivity between services.

## First Time Deployment

For initial deployment, follow these steps in order:

### Step 1: Deploy Backend Services
```bash
docker compose -f docker-compose.backend.yml -f docker-compose.backend.override.yml up -d
```

### Step 2: Deploy Frontend Services
```bash
# Ensure gcsfuse is mounted before this step
docker compose -f docker-compose.frontend.yml -f docker-compose.frontend.override.yml up -d
```

### Step 3: Start Nginx with SSL
```bash
cd ../nginx-certbot
docker compose up -d
```

## Subsequent Deployments

For regular deployments after initial setup:

### Step 1: Deploy Backend Services
```bash
docker compose -f docker-compose.backend.yml -f docker-compose.backend.override.yml up -d
```

### Step 2: Deploy Frontend Services
```bash
# Mount gcsfuse (can be done before or after backend deployment)
docker compose -f docker-compose.frontend.yml -f docker-compose.frontend.override.yml up -d
```

### Step 3: Start Nginx
```bash
cd ../nginx-certbot
docker compose up -d
```

## Service Architecture

- **Backend Stack**: Database services, API servers, and core KoboToolbox services
- **Frontend Stack**: Web interface, form builder, and user-facing components
- **Nginx**: Reverse proxy, SSL termination, and static file serving

## Troubleshooting

- Ensure all configuration files are properly set up before deployment
- Check that gcsfuse mounts are active before starting frontend services
- Verify SSL certificates are properly configured in nginx-certbot
- Monitor logs using `docker compose logs -f [service-name]`

## Related Documentation

- [KoboEnv Configuration](../kobo-env/README.md)
- [Nginx-Certbot Setup](../nginx-certbot/README.md)