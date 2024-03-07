#!/bin/bash

check_expect()
{
    expect -version
    if [ $? -ne 0 ]
    then
        echo "Please install expect first."
        exit 1
    fi
}

set_parameters()
{
    # custom
    domain=test.com
    ipaddr=128.224.157.239
    country=CN
    state=BeiJing
    locality=BeiJing
    orgnization=ExampleCorp
    common=ExampleName
    email=example@example.com
    ca_key_password=wshuai

    # default
    ca_key=selfca.key
    ca_crt=selfca.crt

    ct_key=selfct.key
    ct_csr=selfct.csr
    ct_crt=selfct.crt
}

gen_ca()
{
    openssl genrsa -des3 -passout pass:${ca_key_password} -out ${ca_key} 2048
    openssl req \
        -x509 -new -nodes -key ${ca_key} -passin pass:wshuai -sha256 -days 36500 -out ${ca_crt} \
        -subj "/C=${country}/ST=${state}/L=${locality}/O=${orgnization}/CN=${common}/emailAddress=${email}"
}
 
gen_cert()
{
    openssl genrsa -out ${ct_key} 2048
    openssl req -new -key ${ct_key} -out ${ct_csr} \
        -subj "/C=${country}/ST=${state}/L=${locality}/O=${orgnization}/CN=${common}/emailAddress=${email}"
    expect << EOF
    spawn openssl x509 -req -in ${ct_csr} -out ${ct_crt} -days 3650 \
        -CAcreateserial -CA ${ca_crt} -CAkey ${ca_key} \
        -CAserial serial -extfile cert.ext
    expect "Enter pass phrase for ${ca_key}:"
    send "${ca_key_password}\n"
    expect eof
EOF
}

create_ext()
{
    cat > cert.ext <<EOF
    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [alt_names]
    IP.1 = 127.0.0.1
    IP.2 = ${ipaddr}
    DNS.3 = localhost
    DNS.4 = ${domain}
    DNS.5 = *.${domain}
EOF
}

delete_ext()
{
    rm -f cert.ext
}

main()
{
    check_expect
    set_parameters
    create_ext
    gen_ca
    gen_cert
    delete_ext
}

main