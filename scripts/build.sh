#!/bin/sh

set -ex

cleanup() {
    vagrant destroy -f
}

trap cleanup EXIT

make dist
