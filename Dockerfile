FROM python:3.12-slim
WORKDIR /app
COPY random_number.py .
ENTRYPOINT ["python", "-u", "random_number.py"]
