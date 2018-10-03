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

## Test natively on your host

If you want to use the **afb-test** binding natively on your host, you have to
install it. Then *pkg-config* tool can find the **afb-test.pc** and you can
use **afm-test** launcher:

```bash
sudo make install
# Eventually set PKG_CONFIG_PATH environment variable if not installed in the
# system directory
export PKG_CONFIG_PATH=<path-to-pkgconfig-dir>:${PKG_CONFIG_PATH}
# The same for the PATH environment variable where afm-test has been installed
export PATH=<path-to-afm-test-dir>:${PATH}
```

Then you can test other binding using the **afm-test** launcher. Example here,
with another binding project using **app-templates** submodule or the
**cmake-apps-module** CMake module:

> **Note** CMake module is the new way to use **app-templates**

```bash
cd build
cmake ..
make
afm-test package package-test
```
