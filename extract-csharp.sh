#!/usr/bin/env bash

#
# extract-csharp.sh - small frontend to extract.awk
#

API_KEY=${MAILGUN_API_KEY:-""}
DOMAIN=${MAILGUN_DOMAIN:-""}
FROM_ADDR=${MAILGUN_FROM_ADDR:-""}
TO_ADDR=${MAILGUN_TO_ADDR:-""}
SNIPPET_TEMPL=${SNIPPET_TEMPL:-"snippet-csharp.in"}

CODE_BLOCK_NAME=$1;     shift
SNIPPETS_DIR=$1;        shift
OUTPUT_DIR=$1;          shift
FILE_EXT=$1;            shift

if [ -z "${CODE_BLOCK_NAME}" ] || [ -z "${SNIPPETS_DIR}" ] || [ -z "${OUTPUT_DIR}" ] ; then
    echo "usage: $0: $0 [code block name] [snippets directory] [output directory]"
    exit 1
fi

if [ -z "${FILE_EXT}" ] ; then
    FILE_EXT="cs"
fi

if [ ! -d ${SNIPPETS_DIR} ] ; then
    echo "Snippets dir does not exist!"
    exit 127
fi

if [ ! -d ${OUTPUT_DIR} ] ; then
    mkdir -p ${OUTPUT_DIR}
fi

function getClassName() {
    filename="${1##*/}"

    echo "$(echo $filename | sed -e 's/\..*//' | sed -e 's/\b\(.\)/\u\1/g' | tr -d '-')Chunk"
}

function extractSnippets() {
    for file in $(ls ${SNIPPETS_DIR})
    do
        outfile="${OUTPUT_DIR%/}/${file%.*}.in"
        printf " [*] Extract code-block %s from %s -> %s\n" "${CODE_BLOCK_NAME}" "${SNIPPETS_DIR%/}/${file}" "${outfile}"
        awk -v block_name=${CODE_BLOCK_NAME} -f extract.awk < "${SNIPPETS_DIR%/}/${file}" > "${outfile}"
    done
}

function doReplace() {
    for file in $(ls ${OUTPUT_DIR%/}/*.in)
    do
        printf " [+] Rewriting %s with private variables\n" "${file}"
        cat "${file}" | \
            sed -e "s/YOUR_API_KEY/${API_KEY}/g" | \
            sed -e "s/YOUR_DOMAIN_NAME/${DOMAIN}/g" | \
            sed -e "s/YOU/${USER}/g" > ${file%.*}.out
    done

    # clean up .in files
    rm ${OUTPUT_DIR%/}/*.in
}

function doTemplate() {
    for file in $(ls ${OUTPUT_DIR%/}/*.out)
    do
        outfile="${file%.*}.${FILE_EXT}"
        export CLASS_NAME="$(getClassName ${file})"
        export CLASS_BODY="$(cat ${file})"
        printf " [+] Writing class [%s] for code in file %s\n" "${CLASS_NAME}" "${outfile}"
        cat ${SNIPPET_TEMPL} | envsubst > "${outfile}"
        unset CLASS_NAME
        unset CLASS_BODY
    done

    # clean up .out files
    rm ${OUTPUT_DIR%/}/*.out
}

function doIndent() {
    for file in $(ls ${OUTPUT_DIR%/}/*.${FILE_EXT})
    do
        printf " [!] Re-indenting %s\n" "${file}"
        indent -sob -nhnl -nut -i4 "${file}"
    done

    # clean up indent backups
    rm ${OUTPUT_DIR%/}/*.${FILE_EXT}~
}

extractSnippets
doReplace
doTemplate
doIndent
