#!/bin/bash

SCHEMA_VERSION=0.2.0
TMPDIR=`mktemp -d`
DOWNLOAD_URL="https://github.com/k-motoyan/welog-schema/archive/v$SCHEMA_VERSION.zip"

if [[ ! -d ./tmp ]]; then
    mkdir ./tmp
fi

curl -L $DOWNLOAD_URL -o "$TMPDIR/welog-schema.zip"
unzip "$TMPDIR/welog-schema.zip" -d "$TMPDIR" 
cp -i "$TMPDIR/welog-schema-$SCHEMA_VERSION/schema.graphql" ./tmp/schema.graphql

rm -rf $TMPDIR
