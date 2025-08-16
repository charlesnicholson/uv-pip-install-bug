#!/usr/bin/env bash
set -eEuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

UV_PREFIX=https://github.com/astral-sh/uv/releases/download/0.8.11

UV_MAC_NAME=uv-aarch64-apple-darwin
UV_MAC_URL=${UV_PREFIX}/${UV_MAC_NAME}.tar.gz

UV_LINUX_NAME=uv-x86_64-unknown-linux-gnu
UV_LINUX_URL=${UV_PREFIX}/${UV_LINUX_NAME}.tar.gz

UV_LOCAL_TGZ=${SCRIPT_DIR}/uv.tar.gz

case "$(uname -s)" in
    Darwin)
        UV_NAME=$UV_MAC_NAME
        UV_URL=$UV_MAC_URL
        ;;
    Linux)
        UV_NAME=$UV_LINUX_NAME
        UV_URL=$UV_LINUX_URL
        ;;
    *)
        echo "unknown os"
        exit 1
        ;;
esac

UV=${SCRIPT_DIR}/${UV_NAME}/uv

if [ ! -f "$UV" ]; then
    curl -sL -o "$UV_LOCAL_TGZ" "$UV_URL"
    tar -xzf "$UV_LOCAL_TGZ" && rm "$UV_LOCAL_TGZ"
fi

MY_VENV=${SCRIPT_DIR}/venv
MY_PYTHON=${MY_VENV}/bin/python

if [ -d "$MY_VENV" ]; then
rm -rf $MY_VENV
fi

$UV venv -p 3.13 ${MY_VENV} -q

for i in $(seq 1 100); do
    echo "$i/100"

    $UV pip install -q -p $MY_PYTHON -e mycompany.a/ --config-settings editable_mode=compat
    $UV pip install -q -p $MY_PYTHON -e mycompany.b/ --config-settings editable_mode=compat
    $UV pip uninstall -q -p $MY_PYTHON mycompany.a
    $UV pip uninstall -q -p $MY_PYTHON mycompany.b
done
