#!/bin/bash

TMPDIR=$(mktemp -p . -d .cmXXXXX)
PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c40)
NAMESPACE=$1
SECRET=$2

kubectl get secret -n $NAMESPACE $SECRET -o yaml | yq '.data["tls.crt"]' -r | base64 -d > $TMPDIR/tls.crt
kubectl get secret -n $NAMESPACE $SECRET -o yaml | yq '.data["tls.key"]' -r | base64 -d > $TMPDIR/tls.key

CA=$(kubectl get secret -n $NAMESPACE $SECET -o yaml | yq '.data["ca.crt"]' -r)
[ ! -z "$CA" ] && echo $CA | base64 -d > $TMPDIR/ca.crt

echo $PASS | openssl pkcs12 -export -in $TMPDIR/tls.crt -inkey $TMPDIR/tls.key -out tls.pfx -passout stdin
echo $PASS

rm -rf $TMPDIR
