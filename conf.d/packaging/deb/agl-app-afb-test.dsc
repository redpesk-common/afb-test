Format: 1.0
Source: agl-app-afb-test
Binary: agl-app-afb-test-bin, agl-app-afb-test-dev
Architecture: any
Version: 2.0-0
Maintainer: romain.forlot <romain.forlot@iot.bzh>
Standards-Version: 3.8.2
Homepage: https://gerrit.automotivelinux.org/gerrit/apps/app-afb-test
Build-Depends: debhelper (>= 5),
 pkg-config,
 dpkg-dev,
 cmake,
 agl-cmake-apps-module-bin,
 agl-app-framework-binder-bin,
 agl-app-framework-binder-dev,
 lua5.3,
 liblua5.3-dev,
 libjson-c-dev,
 libsystemd-dev,
DEBTRANSFORM-RELEASE: 1
Files:
 app-afb-test_2.0.tar.gz
