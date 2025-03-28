FROM node:12-slim

WORKDIR /work/
COPY package.json package-lock.json /work/
RUN npm ci && npm cache clean --force

COPY ./anyproxy /work/anyproxy/

# You don't want your trusted root CA key in a public docker image
# They will be generated in docker-entrypoint.sh
# RUN /work/anyproxy/bin/anyproxy-ca --generate \
#     && mkdir /work/ssl/ \
#     && cp /root/.anyproxy/certificates/rootCA.crt /work/ssl/ \
#     && cp /root/.anyproxy/certificates/rootCA.key /work/ssl/

# Copy over and build front-end
COPY gui/package.json gui/package-lock.json /work/gui/
RUN cd /work/gui && npm ci && npm cache clean --force
COPY gui /work/gui
RUN cd /work/gui && npm run build && npm cache clean --force

COPY utils.js api-server.js server.js database.js docker-entrypoint.sh /work/

# For debugging/hot-reloading
#RUN npm install -g nodemon

ENTRYPOINT ["/work/docker-entrypoint.sh"]
#ENTRYPOINT ["node", "/work/server.js"]
