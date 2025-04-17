#!/bin/bash

################################################################################
#                                                                              #
#                                 {o,o}                                        #
#                                 |)__)                                        #
#                                 -"-"-                                        #
#                                                                              #
################################################################################
#
# Generate self signed SSL certificates
#
##############################---VARIABLES---###################################

SCRIPT_PWD="$( dirname $0 )"
DOMAINS_FILE="${SCRIPT_PWD}/domains.list"
: ${CERT_META:="/C=EN/ST=NRW/L=Berlin/O=My Inc/OU=DevOps/CN=www.example.com/emailAddress=dev@www.example.com"}
USER_ID=$(id -u)
GROUP_ID=$(id -g)

################################################################################

###############################---WORKDIR---####################################

cd $( dirname $0 )

################################################################################

##############################---FUNCTIONS---###################################

function gen_certs() {
    if [ -f ${DOMAINS_FILE} ]
    then
        cat ${DOMAINS_FILE} | while read new_domain
            do
            if [ -f ${SCRIPT_PWD}/certs/${new_domain}.crt ] && [ -f ${SCRIPT_PWD}/certs/${new_domain}.key ]
                then
                echo "Certificate and key for domain '${new_domain}' already exist - skipping"
            else
                echo "Generating certificate and key for domain ${new_domain}"
                docker run -v "${SCRIPT_PWD}/certs:/opt/certs" --rm alpine/openssl req -x509 -newkey rsa:4096 -nodes -subj "${CERT_META}" -days 3650 -keyout /opt/certs/${new_domain}.key -out /opt/certs/${new_domain}.crt
            fi
        done
        echo "Fixing permissions"
        pwd
        docker run -v "${SCRIPT_PWD}/certs:/opt/certs" --rm alpine sh -c "chown ${USER_ID}:${GROUP_ID} /opt/certs/*"
    else
        echo "Missing domains.list file"
        exit 1
    fi
}

################################################################################

###############################---EXECUTION---##################################

gen_certs

################################################################################
