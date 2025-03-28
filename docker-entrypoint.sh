#!/bin/bash

if [ ! -d /work/cassl ]; then
    echo "Error: /work/cassl directory does not exist!"
    echo "Please mount this directory before running the Docker container."
    exit 1
fi

if [ ! -f /work/cassl/rootCA.crt ] || [ ! -f /work/cassl/rootCA.key ]; then
    echo "Certificate and key files are missing in /work/cassl, generating new CA..."
    /work/anyproxy/bin/anyproxy-ca --generate
    cp -a /root/.anyproxy/certificates/rootCA.crt /work/cassl/
    cp -a /root/.anyproxy/certificates/rootCA.key /work/cassl/
else
    echo "Using exist Certificate and key files..."
    mkdir -p /root/.anyproxy/certificates
    cp -a /work/cassl/rootCA.crt /root/.anyproxy/certificates/rootCA.crt
    cp -a /work/cassl/rootCA.key /root/.anyproxy/certificates/rootCA.key
fi

node /work/server.js
