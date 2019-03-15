FROM debian:stretch-slim
WORKDIR /app
COPY requirements.txt /app
# library versions
ENV POPPLER_VERSION=0.69.0
ENV VIPS_VERSION=8.7.0 
# prerequisities
RUN apt-get -y update
RUN apt-get -y install pypy virtualenv build-essential g++ autoconf libfontconfig1-dev pkg-config libjpeg-dev gnome-common libglib2.0-dev gtk-doc-tools libyelp-dev yelp-tools gobject-introspection libsecret-1-dev libnautilus-extension-dev wget xz-utils cmake libopenjp2-7-dev
RUN wget https://poppler.freedesktop.org/poppler-$POPPLER_VERSION.tar.xz
RUN wget https://github.com/libvips/libvips/archive/v$VIPS_VERSION.tar.gz
RUN tar -xJf poppler-$POPPLER_VERSION.tar.xz
# build 
WORKDIR /app/poppler-$POPPLER_VERSION/build
RUN cmake ..
RUN make
RUN make install
WORKDIR /app
RUN tar zxvf v$VIPS_VERSION.tar.gz
WORKDIR /app/libvips-$VIPS_VERSION
RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make && make install
WORKDIR /app
# python deps
RUN virtualenv -p /usr/bin/pypy venv
RUN venv/bin/pip install -r requirements.txt
# cleanup
RUN rm -r v$VIPS_VERSION.tar.gz poppler-$POPPLER_VERSION.tar.xz /app/poppler-$POPPLER_VERSION /app/libvips-$VIPS_VERSION
RUN apt-get -y remove --auto-remove virtualenv build-essential wget xz-utils cmake
RUN apt-get -y clean
RUN ln -s /usr/local/lib/libpoppler-glib.so.8 /usr/lib/
RUN ln -s /usr/local/lib/libpoppler.so.80 /usr/lib/
# launch
ENV PYTHONUNBUFFERED=1
ENV port=5000
ENV threads=4
ENV workers=1
ENV timeout=300
EXPOSE 5000
COPY . /app
ENTRYPOINT venv/bin/gunicorn -b0:$port --threads=$threads --workers=$workers --timeout $timeout --reload app:app

