FROM ubuntu
WORKDIR /app
COPY requirements.txt /app
RUN apt-get -y update && apt-get -y install pypy virtualenv build-essential libvips42
RUN virtualenv -p /usr/bin/pypy venv
RUN venv/bin/pip install -r requirements.txt
RUN apt-get -y remove --auto-remove virtualenv build-essential
RUN apt-get -y clean
ENV PYTHONUNBUFFERED=1
ENV port=5000
ENV threads=4
ENV workers=1
ENV timeout=300
COPY . /app
ENTRYPOINT venv/bin/gunicorn -b0:$port --threads=$threads --workers=$workers --timeout $timeout --reload  app:app
