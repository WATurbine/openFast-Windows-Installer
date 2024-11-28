#!/bin/bash

# exit on error
set -e

sudo apt update
sudo apt upgrade -y

# install dependencies (assume a fresh install)
sudo apt install -y \
    build-essential \
    git \
    cmake \
    gfortran \
    libblas-dev \
    liblapack-dev \
    libfftw3-dev

cd ~
# clone OpenFAST repository if it doesn't exist
if [ ! -d "openfast" ]; then
    echo "Cloning OpenFAST repository..."
    git clone https://github.com/OpenFAST/openfast.git
else
    echo "OpenFAST repository already exists."
fi

# build OpenFAST
cd openfast
mkdir -p build && cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$HOME/.local
make -j$(nproc)
make install

# ensure $HOME/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
fi

openfast -h

echo "OpenFAST installation and test completed successfully."
