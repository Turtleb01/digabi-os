#!/bin/sh

set -xe

# TODO: Create jenkins-common, share code w/ jenkins-build.sh

REPOSITORY_HOST="renki.local"
PROXY_HOST="ci.local"
CPUS="4"

cleanup() {
    make purge
}

mdns_resolve() {
    # Linux
    if which avahi-resolve > /dev/null 2>&1 ; then
        avahi-resolve -4 -n "$1" | cut -f2
        return
    fi

    # Mac OS X
    if which dscacheutil > /dev/null 2>&1 ; then
        dscacheutil -q host -a name "$1" | awk '/ip_addr/ {print $2; exit}'
        return
    fi

    echo "Unable to resolve MDNS" 1>&2
    exit 42
}

rm -rf dist


REPOSITORY_IP="$(mdns_resolve ${REPOSITORY_HOST})"
PROXY_IP="$(mdns_resolve ${PROXY_HOST})"

PROXY="http://${PROXY_IP}:3128/"

trap cleanup EXIT

# TODO: Use specified repository when building image

if [ -z "${DEBIAN_MIRROR}" ]
then
    DEBIAN_MIRROR="http://${REPOSITORY_IP}/debian"
fi

if [ -z "${ARCH}" ]
then
    ARCH="i386"
fi

make custom-packages ARCH="$(ARCH)" DEBIAN_MIRROR="${DEBIAN_MIRROR}"
