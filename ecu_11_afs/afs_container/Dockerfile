FROM python:3.9-alpine

# Install system and build dependencies
RUN apk update && apk add --no-cache \
    iputils \
    netcat-openbsd \
    tcpdump \
    py3-pyserial \
    build-base \
    libffi-dev \
    zeromq-dev \
    python3-dev

# Install pyzmq from PyPI (via pip)
RUN pip install --no-cache-dir pyzmq

# Set working directory
WORKDIR /app

# Copy your script
COPY zmq_serial.py .

# Run the script
CMD ["python3", "/app/zmq_serial.py"]
