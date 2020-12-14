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

Firstly, ["Verify Your Build Host"](../developer-guides/host-configuration/docs/1-Setup-your-build-host.html). Indeed, your host needs to have a supported distribution.
Then, you can use the following command-line to get the `afb-test` binding and all its dependencies. Please use the right paragraph, according to you distribution.

### Ubuntu 20.04 and 18.04

Firstly, add the Redpesk "sdk" repository in the list of your packages repositories.

```bash
# Add the repository in your list
$ echo "deb https://download.redpesk.bzh/redpesk-devel/releases/33/sdk/$DISTRO/ ./" | sudo tee -a /etc/apt/sources.list
# Add the repository key
$ curl -L https://download.redpesk.bzh/redpesk-devel/releases/33/sdk/$DISTRO/Release.key | sudo apt-key add -
```

Then, update the list of packages and simply install the `afb-test` package.

```bash
# Update the list of available packages
$ sudo apt update
# Installation of afb-test
$ sudo apt-get install afb-test
```

### Fedora 31, 32 and 33

Firstly, add the Redpesk "sdk" repository in the list of your packages repositories.

```bash
$ cat << EOF > /etc/yum.repos.d/redpesk-sdk.repo
[redpesk-sdk]
name=redpesk-sdk
baseurl=https://download.redpesk.bzh/redpesk-devel/releases/33/sdk/$DISTRO
enabled=1
repo_gpgcheck=0
type=rpm
gpgcheck=0
skip_if_unavailable=True
EOF
```

Then, simply install the `afb-test` package.

```bash
dnf install afb-test
```

### OpenSUSE Leap 15.1 and 15.2

Firstly, add the Redpesk "sdk" repository in the list of your packages repositories.

```bash
$ OPENSUSE_VERSION=15.2 # Set the right OpenSUSE version
# Add the repository in your list
$ sudo zypper ar https://download.redpesk.bzh/redpesk-devel/releases/33/sdk/$DISTRO/ redpesk-sdk
# Refresh your repositories
$ sudo zypper ref
```

Then, simply install the `afb-test` package.

```bash
sudo zypper in afb-test
```
