%global gem_name ifukube 
%if 0%{?rhel} == 6
%global gem_dir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
%global gem_docdir %{gem_dir}/doc/%{gem_name}-%{version}
%global gem_cache %{gem_dir}/cache/%{gem_name}-%{version}.gem
%global gem_spec %{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
%global gem_libdir %{gem_instdir}/lib
%endif

Summary: Bugzilla querying library 
Name: rubygem-%{gem_name}
Version: 0.0.1
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
URL: https://github.com/jsomara/ifukube
Source0: http://rubygems.org/downloads/%{gem_name}-%{version}.gem
Requires: rubygems
BuildRequires: rubygems
BuildRequires: rubygem(rake)
BuildArch: noarch
Provides: rubygem(%{gem_name}) = %{version}
%if 0%{?rhel} == 6 || 0%{?fedora} < 17
Requires: ruby(abi) = 1.8
%else
Requires: ruby(abi) = 1.9.1
%endif
%if 0%{?fedora}
BuildRequires: rubygems-devel
%endif

%description
Ruby gem for querying bugzilla

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}

%prep
gem unpack %{SOURCE0}
%setup -q -D -T -n  %{gem_name}-%{version}
gem spec %{SOURCE0} -l --ruby > %{gem_name}.gemspec

%build
mkdir -p .%{gem_dir}
gem build %{gem_name}.gemspec

gem install -V \
        --local \
        --install-dir ./%{gem_dir} \
        --force \
        --rdoc \
        %{gem_name}-%{version}.gem


%install
mkdir -p %{buildroot}%{gem_dir}
cp -a ./%{gem_dir}/* %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{_sysconfdir}
cp -a ./%{_sysconfdir}/ifukube.yml %{buildroot}%{_sysconfdir}/

rm -rf %{buildroot}%{gem_instdir}/{.yardoc,etc}

%files
%dir %{gem_instdir}
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}
%config(noreplace) %{_sysconfdir}/ifukube.yml

%files doc
%doc %{gem_docdir}
%{gem_instdir}/test

%changelog
