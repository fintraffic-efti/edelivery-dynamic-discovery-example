FROM python:3.11-slim

COPY ./backend_service.py /opt/app/
COPY ./edelivery-send.py /opt/app/
COPY ./requirements.txt /opt/app/

WORKDIR /opt/app
RUN pip install --no-cache-dir -r requirements.txt
