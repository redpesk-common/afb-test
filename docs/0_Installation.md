# Installation

## Pre-requisites

[Setup the pre-requisite](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/host-configuration/docs/1_Prerequisites.html) then [install the Application Framework](http://docs.automotivelinux.org/docs/devguides/en/dev/reference/host-configuration/docs/2_AGL_Application_Framework.html) on your host.

You will also need to install lua-devel >= 5.3 to be able to build the project.

Fedora:

```bash
dnf install lua-devel
```

OpenSuse:

```bash
zypper install lua53-devel
```

Ubuntu (>= Xenial), Debian stable:

```bash
apt-get install liblua5.3-dev
```

## Grab source and build

Download the **afb-test** binding source code using git:

```shell
git clone --recurse-submodules https://gerrit.automotivelinux.org/gerrit/apps/app-afb-test
cd afb-test
mkdir build
cd build
cmake .. && make
```