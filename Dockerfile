# Use a standard, slim Python base image
FROM python:3.11-slim

# Install system dependencies:
# jq - for parsing JSON
# awscli - for interacting with AWS services like S3
RUN apt-get update && apt-get install -y \
    jq \
    awscli \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy our local files into the container's working directory
COPY random_number.py .
COPY dispatcher.sh .

# Make the dispatcher script executable
RUN chmod +x dispatcher.sh

# Tell the container to run our dispatcher script when it starts
ENTRYPOINT ["/app/dispatcher.sh"]
