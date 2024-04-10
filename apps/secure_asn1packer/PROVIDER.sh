#!/usr/bin/env bash

declare -r AES256CBC_HEXKEY="f8991ccc46e146b7bc5cb0c5917979c4c1f06747f1300552e880b25466684231"
declare -r AES256CBC_HEXIV="2ea699bf38bc6e1779e26b0a8eb21b64"

# openssl genrsa -out rsa2048.key 2048
declare -r _gs_ASYMKEY_FILE=${ASYMKEY_FILE:-$(${SKDIRNAME} "${BASH_SOURCE[0]}")/rsa2048.key}
# openssl rsa -in rsa2048.key -pubout -out rsa2048.puk
declare -r _gs_ASYMPUK_FILE=${ASYMPUK_FILE:-$(${SKDIRNAME} "${BASH_SOURCE[0]}")/rsa2048.puk}

function secure_asn1packer_encrypt() {
    local plain_file=$1
    local cipher_file=$2

    ${SKOPENSSL} aes-256-cbc -K ${AES256CBC_HEXKEY} -iv ${AES256CBC_HEXIV} -e -in "${plain_file}" -out "${cipher_file}"
}

function secure_asn1packer_decrypt() {
    local cipher_file=$1
    local plain_file=$2

    ${SKOPENSSL} aes-256-cbc -K ${AES256CBC_HEXKEY} -iv ${AES256CBC_HEXIV} -d -in "${cipher_file}" -out "${plain_file}"
}

function secure_asn1packer_sign() {
    local raw_file=$1
    local sign_file=$2

    if ! file_access_r "${_gs_ASYMKEY_FILE}"; then
        return "${SHELLKIT_RET_FILEIO}"
    fi
    ${SKOPENSSL} dgst -sha512 -sign "${_gs_ASYMKEY_FILE}" -out "${sign_file}" "${raw_file}"
}

function secure_asn1packer_verify() {
    local raw_file=$1
    local sign_file=$2

    if ! file_access_r "${_gs_ASYMPUK_FILE}"; then
        return "${SHELLKIT_RET_FILEIO}"
    fi
    ${SKOPENSSL} dgst -sha512 -verify "${_gs_ASYMPUK_FILE}" -signature "${sign_file}" "${raw_file}" > /dev/null
}

function secure_asn1packer_join_signature() {
    local raw_file=$1
    local sign_file=$2
    local joined_file=$3

    ${SKCAT} "${raw_file}" "${sign_file}" > "${joined_file}"
}

function secure_asn1packer_split_signature() {
    local joined_file=$1
    local raw_file=$2
    local sign_file=$3

    local -i len_sign=2048/8
    local -i len_joined
    local -i len_raw
    len_joined=$(file_get_size "${joined_file}")
    len_raw=$((len_joined - len_sign))
    ${SKHEAD} -c ${len_raw} "${joined_file}" > "${raw_file}"
    ${SKTAIL} -c ${len_sign} "${joined_file}" > "${sign_file}"
}
