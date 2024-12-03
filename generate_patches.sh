#!/bin/bash

# Script to generate the diff files/patches from librdkafka repo to be committed to the librdkafkaport repo
# Requirements
# 1. Apply all the patches and generate librdkafka repo using zopen build command
# 2. Commit the modified files, dev/bug fix changes should be done on top of this commit
# 3. Once changes are ready, create new commit(s) 

echo_error()
{
    echo "ERROR: $1"
}
run_checks()
{
    if [ ! -d ${LIBRDKAFKA_DIR} ]
    then
        echo_error "${LIBRDKAFKA_DIR} does not exist"
        exit
    fi

    if [ ! -d ${LIBRDKAFKA_PORT} ]
    then
        echo_error "${LIBRDKAFKA_PORT} does not exist"
        exit
    fi

    if [ ! -d ${PATCH_OUT_DIR} ]
    then
        echo_error "${PATCH_OUT_DIR} does not exist"
        exit
    fi
}

LIBRDKAFKA_DIR=/Users/rshrotey/Library/CloudStorage/OneDrive-IBM/Kafka_SDK/librdkafka
LIBRDKAFKA_PORT_DIR=/Users/rshrotey/Desktop/OneDriveIBM/Kafka_SDK/librdkafkaport
BASE_COMMIT=6eaf89fb124c421b66b43b195879d458a3a31f86 #diff will be generated with respect to this librdkafka commit
CURRENT_COMMIT=788a80c6c29463c9f884209431c3866d5cd52910 #Latest commit
PATCH_OUT_DIR=${LIBRDKAFKA_DIR}/patches #Patches will be saved to this directory

## main() STARTS HERE ##
echo "LIBRDKAFKA_DIR      ${LIBRDKAFKA_DIR}"
echo "LIBRDKAFKA_PORT_DIR ${LIBRDKAFKA_PORT_DIR}"
echo "BASE_COMMIT         ${BASE_COMMIT}"
echo "CURRENT_COMMIT      ${CURRENT_COMMIT}"
echo "PATCH_OUT_DIR           ${PATCH_OUT_DIR}"

run_checks

pushd ${LIBRDKAFKA_DIR}
echo "#### Base commit ####"
git show -s --format=%s ${BASE_COMMIT}

echo "#### Current commit ####"
git show -s --format=%s ${CURRENT_COMMIT}

MODIFIED_FILES=$(git diff-tree --no-commit-id --name-only ${CURRENT_COMMIT} -r)
echo "Modified files: ${MODIFIED_FILES} "

for file in ${MODIFIED_FILES}
do
    echo "Generating diff for ${file}"
    PATCH_DIR=$(dirname ${file})
    PATCH_FILE_NAME=$(basename ${file})
    PATCH_FILE_NAME=${PATCH_FILE_NAME}.patch

    if [ -f ${PATCH_OUT_DIR}/${PATCH_FILE_NAME} ]
    then
        echo "WARNING: ${PATCH_OUT_DIR}/${PATCH_FILE_NAME} already exists, contents will be overwritten"
    fi
    git diff ${BASE_COMMIT} -- ${file} > ${PATCH_OUT_DIR}/${PATCH_FILE_NAME}
    cp ${PATCH_OUT_DIR}/${PATCH_FILE_NAME} ${LIBRDKAFKA_PORT_DIR}/patches/${PATCH_DIR}/${PATCH_FILE_NAME} #copy patch file to librdkafka port
    cd ${LIBRDKAFKA_PORT_DIR} ; git add ${LIBRDKAFKA_PORT_DIR}/patches/${PATCH_DIR}/${PATCH_FILE_NAME} ; cd - #Add the file to the working tree
done

popd