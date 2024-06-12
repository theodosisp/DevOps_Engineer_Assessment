FROM python:3.8-slim

WORKDIR /app

COPY requirement.txt .

RUN pip install --no-cache-dir -r requirement.txt

COPY . .

COPY hello_world.py .

CMD ["python", "hello_world.py"]
