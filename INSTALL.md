# Installation Instructions

Ngen development has largely been on the Centos Operating System (OS), a linux distribution downstream of Red Hat. This means that either a linux host, linux virtual machine (VM) on a non-linux host, or Docker will be required to build and run ngen. The quickest way to build and run ngen on any OS is with [Docker](#building-and-running-with-docker). If you'd like to manually build ngen and you're running on a linux OS, or already have your VM set up, skip to the [Linux Manual Install Instructions](#linux-manual-install-instructions)

If you're running on windows and don't have a linux VM set up, ngen can be built and run using WSL ([Windows Subsystem for Linux]()). WSL is preferable to manually running a linux based virtual machine (VM) because the WSL start up time is faster, the memory requirements are smaller, and it's just plain easier. Steps to preparing a windows build environment using WSL are [here](#ngen-on-windows-install).

## Building a Docker Ngen image:
First, install docker

Next, clone the github repository:
`git clone https://github.com/NOAA-OWP/ngen.git`

Then we can build with docker:
`cd ngen && docker build . --file ./docker/CENTOS_NGEN_RUN.dockerfile --tag localbuild/ngen:latest`

If the following error occurs:
`ERROR: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/_ping": dial unix /var/run/docker.sock: connect: permission denied`
Try adding user to docker permission:
`sudo usermod -aG docker $USER`
Then log out and back in for user change to take effect.

## Linux Manual Install Instructions
**First, open a linux terminal and enter the following command based on your linux distribution:**

Centos 8.4.2105:
`
yum install tar git gcc-c++ gcc make cmake python38 python38-devel python38-numpy bzip2 udunits2-devel texinfo jq
`

Fedora37: 
'
yum install tar git gcc-c++ gcc make cmake python38 python3-devel python3-numpy bzip2 udunits2-devel texinfo
'

**Then clone the github repository and cd into it:**
`git clone https://github.com/NOAA-OWP/ngen.git && cd ngen`

**Download the Boost Libraries:**
```shell
curl -L -O https://boostorg.jfrog.io/artifactory/main/release/1.72.0/source/boost_1_72_0.tar.bz2 \
    && tar -xjf boost_1_72_0.tar.bz2 \
    && rm -f boost_1_72_0.tar.bz2
```

**Get the current working directory, which is the absolute path to the ngen folder**
```shell
pwd
```

**Set the ENV for Boost**
```shell
export BOOST_ROOT="{absolute path to the ngen folder}/boost_1_72_0"
```

**Get the path to the compiler**
```shell
which g++
```

**Set the ENV for the compiler**
```shell
export CXX={path to g++}
```

**Get the git submodules:**
```shell
git submodule update --init --recursive -- test/googletest &&\
git submodule update --init --recursive -- extern/pybind11
```

**Ngen is now installed! For generating the build system, building, and runnning ngen, see /ngen/README.md**



## Ngen on Windows Install

**Install WSL if not already installed**

**Update WSL and set version to 2**
```shell
wsl --update && wsl --set-default-version 2
```
**Install Fedora through microsoft marketplace**

**Launch Fedora, create linux user, and complete [Linux Manual Install Instructions](#linux-manual-install-instructions)**



---

**Further information on each step:**

Make sure all necessary [dependencies](doc/DEPENDENCIES.md) are installed, and then [build the main ngen target with CMake](doc/BUILDS_AND_CMAKE.md).  Then run the executable, as described [here for basic use](README.md#usage) or [here for distributed execution](doc/DISTRIBUTED_PROCESSING.md#examples).
