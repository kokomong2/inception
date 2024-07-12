# =============================================
# VARIABLES
# =============================================
NAME := certificate
ABSOLUTE_CERT_DIR := $(PWD)/$(CERT_DIR)
EMAIL := sgo@42seoul.student.kr

# =============================================
# GENERAL RULES
# =============================================
all: $(NAME)

$(NAME): $(ABSOLUTE_CERT_DIR)/$(DOMAIN).pem $(ABSOLUTE_CERT_DIR)/$(DOMAIN).key
	@touch $@

clean:
	rm -f $(wildcard $(ABSOLUTE_CERT_DIR)/*.crt)
	rm -f $(wildcard $(ABSOLUTE_CERT_DIR)/*.csr)
	rm -f $(wildcard $(ABSOLUTE_CERT_DIR)/*.srl)

fclean:
	make clean
	rm -f $(NAME)
	rm -f $(wildcard $(ABSOLUTE_CERT_DIR)/*.key)
	rm -f $(wildcard $(ABSOLUTE_CERT_DIR)/*.pem)

re:
	make fclean
	make all

%.pem: %.crt $(ABSOLUTE_CERT_DIR)/root-ca.crt
	cat $^ > $@

%.csr: %.key
	openssl req \
		-new \
		-key $< \
		-subj "/C=KR/ST=Seoul/L=Seoul/STREET=416, Gaepo-ro, Gangnam-gu/O=42 Seoul/OU=Cadet/CN=$(basename $(@F))/E=$(EMAIL)" \
		-out $@

%.crt: %.csr $(ABSOLUTE_CERT_DIR)/root-ca.crt
	openssl x509 \
		-req \
		-sha256 \
		-days 30 \
		-CAkey $(ABSOLUTE_CERT_DIR)/root-ca.key \
		-CA $(ABSOLUTE_CERT_DIR)/root-ca.crt \
		-CAcreateserial \
		-in $< \
		-out $@
	openssl x509 -in $@ -text

%/root-ca.crt: %/root-ca.key
	openssl req \
		-x509 \
		-new \
		-nodes \
		-sha256 \
		-key $< \
		-days 365 \
		-subj "/C=KR/ST=Seoul/L=Seoul/STREET=416, Gaepo-ro, Gangnam-gu/O=42 Seoul/OU=Cadet/CN=root-ca/E=$(EMAIL)" \
		-out $@
	openssl x509 -in $@ -text

%.key:
	openssl genrsa -out $@ 2048

.PHONY: all clean fclean re

.PRECIOUS: %.key %.csr %.crt
