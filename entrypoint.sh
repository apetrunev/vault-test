#!/bin/sh

VAULT_CONF_DIR=/etc/vault
VAULT_CONF_FILE=$VAULT_CONF_DIR/config.hcl
VAULT_TLS_DIR=$VAULT_CONF_DIR/tls

if test -z "$DOMAIN"; then echo "err: var $DOMAIN is undefined"; exit 1; fi
if ! test -d $VAULT_CONF_DIR; then echo "err: $VAULT_CONF_DIR not found"; exit 1;fi
if ! test -f $VAULT_CONF_FILE; then echo "err: $VAULT_CONF_FILE not found"; exit 1; fi
if ! test -d $VAULT_TLS_DIR; then echo "err: $VAULT_TLS_DIR not found"; exit 1; fi
if ! test -d $VAULT_TLS_DIR/$DOMAIN; then echo "err: $VAULT_TLS_DIR/$DOMAIN not found"; exit 1; fi

# https://developer.hashicorp.com/vault/tutorials/day-one-raft/raft-deployment-guide

# fix owner and permissios for certs
find $VAULT_TLS_DIR/$DOMAIN/ -mindepth 1 -maxdepth 1 -type d -name "*.crt" -exec sh -c "chown root:root {} && chmod 0644 {}" \;
find $VAULT_TLS_DIR/ca/ -mindepth 1 -maxdepth 1 -type d -name "*.crt" -exec sh -c "chown root:root {} && chmod 0644 {}" \;
# fix owner and permissions for key
find $VAULT_TLS_DIR/$DOMAIN/ -mindepth 1 -maxdepth 1 -type d -name "*.key" -exec sh -c "chown -v vault:vault {} && chmod -v 0640 {}" \;

sudo -u vault bash -c "vault server -config=$VAULT_CONF_FILE"
#sh -c "while true; do sleep 10; done"
