# KoboToolbox Docker Stack

A complete Docker-based deployment solution for KoboToolbox, providing a secure, scalable, and production-ready environment for data collection and survey management.

## Overview

This repository contains a comprehensive Docker stack for deploying KoboToolbox with the following key features:

- **Template-based Configuration**: Secure credential management using example files
- **SSL/TLS Support**: Automated certificate management with Let's Encrypt
- **Cloud Storage Integration**: Google Cloud Storage mounting via gcsfuse
- **Multi-service Architecture**: Separate backend, frontend, and proxy services
- **Production Ready**: Optimized for scalable deployments

## Repository Structure

```
kobo-docker-stack/
├── README.md                 # This file - repository overview
├── .gitignore               # Git ignore rules for security
├── kobo-env/                # Configuration and environment files
│   ├── README.md           # Detailed configuration guide
│   ├── envfiles/           # Environment variable templates
│   ├── enketo_express/     # Enketo form engine configuration
│   ├── postgres/           # PostgreSQL configuration
│   └── fstab.example       # Google Cloud Storage mount template
├── kobo-docker/            # Docker Compose configurations
│   ├── README.md           # Deployment instructions
│   ├── docker-compose.*.yml # Service definitions
│   ├── nginx/              # Nginx configuration and scripts
│   ├── redis/              # Redis configuration and backup scripts
│   └── scripts/            # Utility scripts
└── nginx-certbot/          # SSL certificate management
    ├── README.md           # SSL setup instructions
    ├── docker-compose.yml  # Nginx + Certbot configuration
    └── init-letsencrypt.sh # SSL certificate initialization
```

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed
- Domain name pointing to your server
- [Google Cloud Storage bucket](https://cloud.google.com/storage/docs/creating-buckets) with [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse) for file storage (optional but recommended for production)
- [Service Account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) for GCS access (if using cloud storage)
- External PostgreSQL database (optional, can use containerized version)
- External MongoDB database (optional, can use containerized version)
- Basic understanding of Docker deployments

### Deployment Steps

1. **Configure Environment**
   ```bash
   cd kobo-env
   # Follow the detailed setup guide in kobo-env/README.md
   ```

2. **Set Up SSL Certificates**
   ```bash
   cd nginx-certbot
   # Follow the SSL setup guide in nginx-certbot/README.md
   ```

3. **Deploy Services**
   ```bash
   cd kobo-docker
   # Follow the deployment guide in kobo-docker/README.md
   ```

## Key Components

### Configuration Management (`kobo-env/`)

- **Template-based Security**: All sensitive data uses `.example` files as templates
- **Environment Variables**: Centralized configuration for all services
- **Database Settings**: PostgreSQL, MongoDB, and Redis configurations
- **External Services**: SMTP, AWS S3, Google Analytics integration
- **Cloud Storage**: Google Cloud Storage mounting configuration

### Docker Services (`kobo-docker/`)

- **Backend Stack**: Database services, API servers, background workers
- **Frontend Stack**: Web interface, form builder, data visualization
- **Service Orchestration**: Coordinated startup and dependency management
- **Volume Management**: Persistent data storage and backup strategies

### SSL & Proxy (`nginx-certbot/`)

- **Reverse Proxy**: Nginx configuration for service routing
- **SSL Termination**: Automated Let's Encrypt certificate management
- **Security Headers**: HTTPS enforcement and security best practices
- **Static File Serving**: Optimized delivery of assets and media

## Security Features

- **Credential Protection**: All sensitive files are Git-ignored
- **Template System**: Example files prevent accidental credential commits
- **SSL/TLS Encryption**: End-to-end encrypted communications
- **Access Controls**: Proper file permissions and user isolation
- **Backup Security**: Encrypted backup strategies for sensitive data

## Production Considerations

- **Scalability**: Horizontal scaling support for high-traffic deployments
- **Monitoring**: Built-in logging and health check configurations
- **Backup Strategy**: Automated database and file backup solutions
- **Update Management**: Rolling update procedures for zero-downtime deployments
- **Resource Optimization**: Memory and CPU tuning for production workloads

## Getting Help

- **Configuration Issues**: See [kobo-env/README.md](kobo-env/README.md)
- **Deployment Problems**: See [kobo-docker/README.md](kobo-docker/README.md)
- **SSL Certificate Issues**: See [nginx-certbot/README.md](nginx-certbot/README.md)
- **KoboToolbox Documentation**: [Official KoboToolbox Docs](https://support.kobotoolbox.org/)

## Contributing

When contributing to this repository:

1. Never commit actual configuration files (only `.example` files)
2. Test changes in a development environment first
3. Update relevant README files when adding new features
4. Follow the existing template-based security patterns

## Acknowledgments

This repository is based on and inspired by the official [kobo-install](https://github.com/kobotoolbox/kobo-install) project. <mcreference link="https://github.com/kobotoolbox/kobo-install" index="0">0</mcreference> While kobo-install provides an automated installation script, this repository offers a more manual, Docker Compose-based approach with enhanced security features and template-based configuration management.

## License

This deployment configuration is provided as-is for KoboToolbox deployments. Please refer to the official KoboToolbox project for software licensing terms.