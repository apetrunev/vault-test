# Generate wildcard cert and key for domain
DOMAIN = example.com
STAR_DOMAIN = *.$(DOMAIN)
CA_DIR := ca
KEY := server.key
CRT := server.crt
CSR := server.csr
CSR_CONF := csr.conf
CERT_CONF := cert.conf
DAYS := 365

#
# CSR
#

define CSR_conf :=
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = RU
ST = Moscow
L = Moscow
O = Infra
OU = Dev
CN = $(DOMAIN)

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $(DOMAIN)
DNS.2 = $(STAR_DOMAIN)
endef

#
# CERT
#

define CERT_conf :=
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $(DOMAIN)
DNS.2 = $(STAR_DOMAIN)
endef

all: install

$(CA_DIR):
	mkdir -vp $(CA_DIR)/
	openssl req -x509 \
		    -sha256 -days 356 \
		    -nodes \
		    -newkey rsa:2048 \
		    -subj "/CN=$(STAR_DOMAIN)/C=RU/L=Moscow" \
		    -keyout $(CA_DIR)/self_ca.key -out $(CA_DIR)/self_ca.crt 

export CSR_conf
$(CSR_CONF):
	echo "$$CSR_conf" > $@

export CERT_conf
$(CERT_CONF):
	echo "$$CERT_conf" > $@

install: ca $(CSR_CONF) $(CERT_CONF)
	openssl genrsa -out $(KEY) 2048	
	openssl req -new -key $(KEY) -out $(CSR) -config $(CSR_CONF)
	openssl x509 -req -in $(CSR) -CA $(CA_DIR)/self_ca.crt -CAkey $(CA_DIR)/self_ca.key -CAcreateserial -out $(CRT) -days $(DAYS) -sha256 -extfile $(CERT_CONF)
	mkdir -vp $(DOMAIN)/
	mv -v $(KEY) $(DOMAIN)/
	mv -v $(CRT) $(DOMAIN)/
	mv -v $(CSR) $(DOMAIN)/

clean:
	rm -rvf $(DOMAIN)
	rm -rvf $(CSR_CONF)
	rm -rvf $(CERT_CONF)
	rm -rvf $(CA_DIR)
