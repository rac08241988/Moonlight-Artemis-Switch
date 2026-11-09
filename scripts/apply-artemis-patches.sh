#!/bin/bash
# Applies the Artemis Switch changes to the borealis and moonlight-common-c submodules.
set -e
cd "$(dirname "$0")/.."
git submodule update --init --recursive
git -C extern/borealis apply ../../patches/borealis-artemis.patch
git -C extern/moonlight-common-c apply ../../patches/moonlight-common-c-artemis.patch
echo "Artemis patches applied."
