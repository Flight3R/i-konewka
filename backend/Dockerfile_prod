FROM python:3.8-slim

WORKDIR /ikonewka

COPY src /ikonewka

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "wsgi:app"]
