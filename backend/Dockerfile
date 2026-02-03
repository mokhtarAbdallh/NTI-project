############################################
# Stage 1: Builder (Install Dependencies)
############################################
FROM python:3.10-slim AS builder

WORKDIR /app

# Install build dependencies (only needed here)
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install python packages into a separate folder
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt


############################################
# Stage 2: Final Runtime Image (Production)
############################################
FROM python:3.10-slim

WORKDIR /app

# Install only runtime dependency for postgres
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder stage
COPY --from=builder /install /usr/local

# Copy project source code
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Run Django with Gunicorn (Production)
CMD ["gunicorn", "gig_router.wsgi:application", "--bind", "0.0.0.0:8000"]

