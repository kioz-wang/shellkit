#!/usr/bin/env bash

function file_get_size() {
    local file_path=$1
    ${SKWC} -c < "${file_path}"
}
declare -frx file_get_size

function file_get_hash() {
    local file_path=$1
    # Specifies name of the digest to be used. See by `openssl dgst -list`
    local openssl_dgst=$2
    local openssl_dgst_result
    openssl_dgst_result=$(${SKOPENSSL} dgst "-${openssl_dgst}" "${file_path}")
    ${SKECHO} -n "${openssl_dgst_result##*= }"
}
declare -frx file_get_hash

function file_base64() {
    # Specifies direction of the Base64 to be used: encode(e)/decode(d).
    # See by `openssl base64 -help`
    local openssl_dir=$1
    if [ $# -eq 2 ]; then
        local file_path=$2
    fi
    if [ -n "${file_path}" ]; then
        local -ar param_in=("-in" "${file_path}")
    fi
    ${SKOPENSSL} base64 -A "-${openssl_dir}" "${param_in[@]}"
}
declare -frx file_base64

function file_access_r() {
    local file_path=$1
    [ -f "${file_path}" ] && [ -r "${file_path}" ]
}
declare -frx file_access_r

function file_access_w() {
    local file_path=$1
    [ -f "${file_path}" ] && [ -w "${file_path}" ]
}
declare -frx file_access_w

function dir_access_r() {
    local dir_path=$1
    [ -d "${dir_path}" ] && [ -r "${dir_path}" ]
}
declare -frx dir_access_r

function dir_access_w() {
    local dir_path=$1
    [ -d "${dir_path}" ] && [ -w "${dir_path}" ]
}
declare -frx dir_access_w
