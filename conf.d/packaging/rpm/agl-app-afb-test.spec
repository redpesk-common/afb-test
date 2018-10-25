#
# spec file for package app-afb-test
#

%define _prefix /opt/AGL
%define __cmake cmake

%if 0%{?fedora_version}
%global debug_package %{nil}
%endif

Name:           agl-app-afb-test
# WARNING {name} is not used for tar file name in source nor for setup
#         Check hard coded values required to match git directory naming
Version:        2.0
Release:        0
License:        Apache-2.0
Summary:        AGL app-afb-test
Group:          Development/Libraries/C and C++
Url:            https://gerrit.automotivelinux.org/gerrit/#/admin/projects/apps/app-afb-test
Source:         app-afb-test-%{version}.tar.gz
Patch0:         project_version.patch
BuildRequires:  pkgconfig(lua) >= 5.3
BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  pkgconfig(json-c)
BuildRequires:  pkgconfig(afb-daemon)
BuildRequires:  pkgconfig(libsystemd) >= 222

BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
This is a migration of former app-templates git submodule which let you ease the
development of apps and widget building.

%package devel
Group:          Development/Libraries/C and C++
Requires:       %{name} = %{version}
Provides:       pkgconfig(%{name}) = %{version}
Summary:        AGL app-afb-test-devel
%description devel
This is a migration of former app-templates git submodule which let you ease the
development of apps and widget building.

%prep
%setup -q -n app-afb-test-%{version}
%patch0 -p1

%build
export PKG_CONFIG_PATH=%{_libdir}/pkgconfig
[ ! -d build ] && mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=DEBUG ..
%__make %{?_smp_mflags}

%install
[ -d build ] && cd build
%make_install
mkdir -p %{buildroot}%{_prefix}/afm/applications/afTest/%{version}
mv %{buildroot}%{_prefix}/afTest/* %{buildroot}/%{_prefix}/afm/applications/afTest/%{version}
rmdir %{buildroot}/%{_prefix}/afTest

%post

%postun

%files
%defattr(-,root,root)
%dir %{_prefix}
%dir %{_bindir}
%{_bindir}/afm-test
%dir %{_prefix}/afm/
%dir %{_prefix}/afm/applications/
%dir %{_prefix}/afm/applications/afTest/
%dir %{_prefix}/afm/applications/afTest/%{version}/
%dir %{_prefix}/afm/applications/afTest/%{version}/etc
%{_prefix}/afm/applications/afTest/%{version}/etc/aft-afbtest.json
%dir %{_prefix}/afm/applications/afTest/%{version}/bin
%dir %{_prefix}/afm/applications/afTest/%{version}/lib
%{_prefix}/afm/applications/afTest/%{version}/lib/aft.so
%dir %{_prefix}/afm/applications/afTest/%{version}/htdocs
%dir %{_prefix}/afm/applications/afTest/%{version}/var
%{_prefix}/afm/applications/afTest/%{version}/var/aft.lua
%{_prefix}/afm/applications/afTest/%{version}/var/luaunit.lua

%files devel
%defattr(-,root,root)
%dir %{_prefix}
%dir %{_libdir}/pkgconfig
%{_libdir}/pkgconfig/*.pc

%changelog
* Thu Oct 25 2018 Romain
- initial creation
