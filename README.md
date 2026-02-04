# DevOps Microservices App (Django + React + GitOps)

 A full-stack microservices application built with Python (Django) for the backend and React for the frontend. This project demonstrates DevOps best practices, including GitOps workflows, CI/CD automation, containerization, and cloud-native deployment.

An AI-powered platform that connects musicians to gigs in real-time using Generative AI and AI Agents.

![Platform Screenshot](./screenshot.png)

---
![Arch Diagram](./react-django.png)
---

## 🚀 Features

 - Microservices Architecture – Modular services for scalability and maintainability
- Backend: Django REST Framework (API-first design)
- Frontend: React with responsive UI
- Database: PostgreSQL (or update with your DB)
- CI/CD Pipelines: Automated testing & deployment (GitLab/Jenkins/GitHub Actions – specify yours)
- GitOps Workflow: Infrastructure as Code + Continuous Delivery
- Dockerized Services: Easy local development and cloud deployment
- Kubernetes Ready: Deployment manifests for orchestration

## 🏗️ Architecture

```
flowchart TD
    A[React Frontend] -->|REST API| B[Django Backend]
    B --> C[(Database)]
    B --> D[Auth Service]
    B --> E[Other Microservices]
    A --> F[NGINX/Load Balancer]

```

### Database: PostgreSQL / MySQL

### Backend
- **Django 4.2** - Web framework
- **Django REST Framework** - API framework
- **PostgreSQL** - Primary database
- **Redis** - Caching and task queue
- **Celery** - Background task processing
- **Jazzmin** - Beautiful admin interface


## 🚀 Setup & Installation

### Environment Setup
Create a `.env` file in the root directory:
```bash
# Django Settings
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DB_NAME=Your_DB_NAME
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=db
DB_PORT=5432

# Redis
REDIS_URL=redis://redis:6379/0

# OpenAI (Optional for development)
OPENAI_API_KEY=your-openai-api-key
```

## Access the Application 
- Frontend → http://localhost:3000
- Backend → http://localhost:8000

### 3. Start Development Environment usig makefile
```bash
# Build and start all services
make dev
```

### 4. Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000/api/
- **Admin Interface**: http://localhost:8000/admin/
- **API Documentation**: http://localhost:8000/api/docs/

### 5. Create Superuser
```bash
make createsuperuser
```

## 📱 Available Commands

```bash
# Development
make dev              # Build and start development environment
make quick-start      # Quick start without building
make build            # Build all Docker images
make up               # Start all services
make down             # Stop all services

# Database
make migrate          # Run Django migrations
make makemigrations  # Create Django migrations

# Management
make shell            # Open backend shell
make frontend-shell   # Open frontend shell
make db-shell         # Open database shell
make logs             # Show all logs
make backend-logs     # Show backend logs
make frontend-logs    # Show frontend logs

# Maintenance
make clean            # Clean up containers and volumes
make restart          # Restart all services
make status           # Show service status
```


## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - User login
- `POST /api/auth/logout/` - User logout
- `POST /api/auth/refresh/` - Token refresh

### Profiles
- `GET /api/profile/` - User profile
- `PUT /api/profile/update/` - Update profile
- `GET /api/musician/profile/` - Musician profile
- `PUT /api/musician/profile/update/` - Update musician profile
- `GET /api/venue/profile/` - Venue profile
- `PUT /api/venue/profile/update/` - Update venue profile


## 🧪 Testing

```bash
# Run Django tests
make test

# Run frontend tests
make frontend-shell
npm test
```

# CI/CD Pipeline – Implementation Report

## Overview
This repository demonstrates the implementation of a **production-like CI/CD pipeline** using **GitHub Actions**, designed with a strong focus on **code quality**, **security**, and **best DevOps practices**.

The pipeline integrates:
- **SonarCloud** for static code analysis
- **Trivy** for dependency and container image security scanning
- **Docker** for building application images
- **Docker Hub** for image publishing

---

## Pipeline Architecture

The final and stable pipeline follows this execution flow:

SonarCloud Analysis
↓
Trivy Filesystem Scan
↓
Docker Build → Trivy Image Scan → Docker Push


This architecture was chosen to ensure:
- Fast feedback
- Minimal complexity
- Deterministic and reproducible builds
- Security validation before publishing images

---

## Challenges and Issues Encountered

### 1. SonarCloud Configuration Errors

**Problem:**
The pipeline failed repeatedly with:
sonar-scanner failed with exit code 3


**Root Causes:**
- Missing or incorrect `sonar.organization`
- Mismatched `sonar.projectKey`
- Confusion between SonarQube (self-hosted) and SonarCloud requirements
- Incorrect `SONAR_HOST_URL`

**Resolution:**
- Created a proper SonarCloud Organization
- Retrieved the exact **Organization Key** and **Project Key** from SonarCloud UI
- Updated `sonar-project.properties` to match SonarCloud metadata exactly
- Set `SONAR_HOST_URL` to `https://sonarcloud.io`

**Lesson Learned:**
SonarCloud is extremely strict. Any mismatch between configuration and platform metadata results in immediate failure.

---

### 2. Trivy Image Scan Failures

**Problem:**
Trivy failed with errors such as:
unable to find the specified image
UNAUTHORIZED: authentication required


**Root Cause:**
Docker images were built in one GitHub Actions job and scanned in another.
GitHub Actions jobs run on **isolated runners**, so Docker images do not persist across jobs.

**Resolution:**
- Moved Docker build and Trivy image scan into the **same job**
- Ensured the image exists locally at scan time

**Lesson Learned:**
Docker images are local state and must be scanned in the same job where they are built unless explicitly pushed or transferred.

---

### 3. Docker Push Failures

**Problem:**
An image does not exist locally with the tag


**Root Cause:**
The pipeline attempted to push Docker images in a job where they were never built or loaded.

**Resolution:**
- Adopted a single-job strategy:
  - Build image
  - Scan image with Trivy
  - Push image (only on `main` branch)

**Lesson Learned:**
The most reliable CI pattern is:
> **Build → Scan → Push in the same job**

---

### 4. Invalid Workflow Dependencies

**Problem:**
Job depends on unknown job


**Root Cause:**
A job was removed, but other jobs still referenced it using `needs`.

**Resolution:**
- Updated the workflow dependency graph
- Ensured all `needs` references point to existing jobs

**Lesson Learned:**
When refactoring pipelines, the dependency graph (DAG) must remain consistent.

---

## Final Design Decision

### Chosen Best Practice
The final pipeline design prioritizes:
- Simplicity
- Speed
- Security
- Maintainability

**Why this approach was selected:**
- No Docker image rebuilds
- No artifact complexity
- Same image scanned and published
- Widely adopted in real-world production environments

---

## Key Takeaways

- CI/CD pipelines should be **stateless and deterministic**
- Tool configuration must exactly match platform metadata
- Security scans should happen **before publishing artifacts**
- Simpler pipelines are easier to maintain and debug
- GitHub Actions job isolation must always be considered in design

---

## Conclusion

Despite multiple configuration and architectural challenges, the final CI/CD pipeline is:
- Stable
- Secure
- Efficient
- Production-ready

The issues encountered during implementation provided valuable hands-on experience with real-world DevOps challenges, especially around CI isolation, security scanning, and pipeline design decisions.

---

## Future Improvements

- Enforce SonarCloud Quality Gates on Pull Requests
- Add coverage reporting
- Integrate GitOps-based deployment (e.g., ArgoCD)
- Extend pipeline to Kubernetes environments
