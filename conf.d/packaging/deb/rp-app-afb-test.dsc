Format: 1.0
Source: rp-app-afb-test
Binary: rp-app-afb-test-bin, rp-app-afb-test-dev
Architecture: any
Version: 2.0-0
Maintainer: romain.forlot <romain.forlot@iot.bzh>
Standards-Version: 3.8.2
Homepage: https://gerrit.automotivelinux.org/gerrit/apps/app-afb-test
Build-Depends: debhelper (>= 5),
 pkg-config,
 dpkg-dev,
 cmake,
 rp-libappcontroller-dev,
 rp-libafb-helpers-dev,
 rp-cmake-apps-module-bin,
 rp-app-framework-binder-bin,
 rp-app-framework-binder-dev,
 lua5.3,
 liblua5.3-dev,
 libjson-c-dev,
 libsystemd-dev,
DEBTRANSFORM-RELEASE: 1
Files:
 app-afb-test_2.0.tar.gz
