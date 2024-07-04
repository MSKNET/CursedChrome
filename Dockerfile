FROM node:12.16.2-stretch


ENV DEBIAN_FRONTEND=noninteractive
RUN echo "deb http://deb.debian.org/debian stretch main" > /etc/apt/sources.list \
	&& echo "deb-src http://deb.debian.org/debian stretch main" >> /etc/apt/sources.list \
	&& echo "deb http://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list \
	&& echo "deb-src http://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list \
	&& echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list \
	&& echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

RUN apt update && apt install ffmpeg -y


WORKDIR /work/
COPY anyproxy/ ./anyproxy/
COPY package.json package-lock.json .
RUN npm install


COPY gui/ ./gui/
WORKDIR /work/gui
RUN npm install && npm run build 

WORKDIR /work/
COPY utils.js api-server.js server.js database.js docker-entrypoint.sh .
RUN /work/anyproxy/bin/anyproxy-ca --generate \
	&& mkdir /work/ssl/ \
	&& cp /root/.anyproxy/certificates/rootCA.* /work/ssl/ 
RUN apt-get clean && npm cache clean -f



ENTRYPOINT ["/work/docker-entrypoint.sh"]