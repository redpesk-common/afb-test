#
# spec file for package app-afb-test
#

%define _prefix /opt/RP
%define __cmake cmake

%if 0%{?fedora_version}
%global debug_package %{nil}
%endif

Name:           rp-app-afb-test
# WARNING {name} is not used for tar file name in source nor for setup
#         Check hard coded values required to match git directory naming
Version:        2.0
Release:        0
License:        Apache-2.0
Summary:        RP app-afb-test
Group:          Development/Libraries/C and C++
Url:            http://git.ovh.iot/redpesk/redpesk-core/app-afb-test.git
Source:         app-afb-test-%{version}.tar.gz
BuildRequires:  pkgconfig(lua) >= 5.3
BuildRequires:  cmake
BuildRequires:  rp-cmake-apps-module
BuildRequires:  gcc-c++
BuildRequires:  pkgconfig(json-c)
BuildRequires:  pkgconfig(afb-daemon)
BuildRequires:  pkgconfig(appcontroller)
BuildRequires:  pkgconfig(ctl-utilities)
BuildRequires:  pkgconfig(afb-helpers)
BuildRequires:  pkgconfig(libsystemd) >= 222
Requires:       jq
Requires:	lcov

BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
afb-test is a test framework made to test other binding.

%package devel
Group:          Development/Libraries/C and C++
Requires:       %{name} = %{version}
Provides:       pkgconfig(%{name}) = %{version}
Summary:        RP app-afb-test-devel
%description devel
afb-test is a test framework made to test other binding.

%prep
%setup -q -n app-afb-test-%{version}

%build
export PKG_CONFIG_PATH=%{_libdir}/pkgconfig
[ ! -d build ] && mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=DEBUG -DVERSION=%{version} ..
%__make %{?_smp_mflags}

%install
[ -d build ] && cd build
%make_install

%post

%postun

%files
%defattr(-,root,root)
%dir %{_prefix}
%dir %{_bindir}
%{_bindir}/afm-test
%dir %{_prefix}

%dir %{_prefix}/afb-test/
%dir %{_prefix}/afb-test/etc
%dir %{_prefix}/afb-test/lib
%dir %{_prefix}/afb-test/var
%{_prefix}/afb-test/etc/aft-afbtest.json
%{_prefix}/afb-test/lib/aft.so
%{_prefix}/afb-test/var/aft.lua
%{_prefix}/afb-test/var/luaunit.lua

%dir %{_prefix}/afb-test-test/
%dir %{_prefix}/afb-test-test/etc
%{_prefix}/afb-test-test/etc/aft-aftest-selftest.json
%dir %{_prefix}/afb-test-test/bin
%dir %{_prefix}/afb-test-test/lib

%dir %{_prefix}/afb-test-test/htdocs
%dir %{_prefix}/afb-test-test/var
%{_prefix}/afb-test-test/var/aftTest.lua
%{_prefix}/afb-test-test/var/helloworld.lua
%{_prefix}/afb-test-test/var/mapi_low-can.lua
%{_prefix}/afb-test-test/var/mapi_tests.lua



%files devel
%defattr(-,root,root)
%dir %{_libdir}/pkgconfig
%{_libdir}/pkgconfig/*.pc

%changelog
* Thu Oct 25 2018 Romain
- initial creation
