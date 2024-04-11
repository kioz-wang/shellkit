#!/usr/bin/env bash

function assert_params_num_min() {
    local exec_name=$1
    local params_lst=$2
    local -i params_num_min=$3
    local -i params_realnum=$4
    if ((params_realnum < params_num_min)); then
        ${SKECHO} "Usage:"
        ${SKECHO} "  ${exec_name} ${params_lst}"
        exit "${SHELLKIT_RET_INVPARAM}"
    fi
}
declare -frx assert_params_num_min

function assert_file_exist() {
    local file_path=$1
    if [[ ! -f "${file_path}" ]]; then
        ${SKECHO} "FileNotFound ${file_path}"
        exit "${SHELLKIT_RET_NOTFOUND}"
    fi
}
declare -frx assert_file_exist

function assert_files_r() {
    local files_path=("$@")
    for file_path in "${files_path[@]}"; do
        assert_file_exist "${file_path}"
        if [[ ! -r "${file_path}" ]]; then
            ${SKECHO} "FileNotReadable ${file_path}"
            exit "${SHELLKIT_RET_FILEIO}"
        fi
    done; unset file_path
}
declare -frx assert_files_r

function assert_files_w() {
    local files_path=("$@")
    for file_path in "${files_path[@]}"; do
        assert_file_exist "${file_path}"
        if [[ ! -w "${file_path}" ]]; then
            ${SKECHO} "FileNotWritable ${file_path}"
            exit "${SHELLKIT_RET_FILEIO}"
        fi
    done; unset file_path
}
declare -frx assert_files_w

function assert_dir_exist() {
    local dir_path=$1
    if [[ ! -d "${dir_path}" ]]; then
        ${SKECHO} "DirectoryNotFound ${dir_path}"
        exit "${SHELLKIT_RET_NOTFOUND}"
    fi
}
declare -frx assert_dir_exist

function assert_dirs_r() {
    local dirs_path=("$@")
    for dir_path in "${dirs_path[@]}"; do
        assert_dir_exist "${dir_path}"
        if [[ ! -r "${dir_path}" ]]; then
            ${SKECHO} "DirectoryNotReadable ${dir_path}"
            exit "${SHELLKIT_RET_FILEIO}"
        fi
    done; unset dir_path
}
declare -frx assert_dirs_r

function assert_dirs_w() {
    local dirs_path=("$@")
    for dir_path in "${dirs_path[@]}"; do
        assert_dir_exist "${dir_path}"
        if [[ ! -w "${dir_path}" ]]; then
            ${SKECHO} "DirectoryNotWritable ${dir_path}"
            exit "${SHELLKIT_RET_FILEIO}"
        fi
    done; unset dir_path
}
declare -frx assert_dirs_w
