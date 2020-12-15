# Installation

`afb-test`package is available either to run tests natively (i.e. on your desktop PC) or on target (with a Redpesk® image).

The two paragraphs here below give you the right instructions, depending of what you want.

## Installation on target

### Redpesk® 33

The default repositories available in Redpesk® 33 contains already the `afb-test` package. Therefore, you only have to run a simple `dnf install` command.

```bash
dnf install afb-test
```

## Native installation

Firstly, see ["Setup your build host"](../developer-guides/host-configuration/docs/1-Setup-your-build-host.html) in order to add the repository for your distribution.

In order to do that, go to the paragraph corresponding to your distribution, and follow the instructions given in the **"Add the repositories"** sub-paragraph.

### Ubuntu 20.04 and 18.04

Update the list of packages and simply install the `afb-test` package.

```bash
# Update the list of available packages
$ sudo apt update
# Installation of afb-test
$ sudo apt-get install afb-test
```

### Fedora 31, 32 and 33

Update the list of packages and simply install the `afb-test` package.

```bash
# Update the list of available packages
$ dnf update
# Installation of afb-test
$ dnf install afb-test
```

### OpenSUSE Leap 15.1 and 15.2

Update the list of packages and simply install the `afb-test` package.

```bash
# Refresh your repositories
$ sudo zypper ref
# Install the package
$ sudo zypper in afb-test
```
