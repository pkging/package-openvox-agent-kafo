%define gem_name kafo
%define gem_cache_dir /opt/puppetlabs/puppet/share/gems

Summary:   A gem for making installations based on puppet user friendly
Name:      openvox-agent-%{gem_name}
Version:   7.8.0
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv3+
URL:       https://github.com/theforeman/%{gem_name}
Source0:   https://rubygems.org/gems/%{gem_name}-%{version}.gem
Requires:  openvox-agent >= 8
Requires:  openvox-agent < 9
Requires:  openvox-agent-kafo-wizards
Requires:  openvox-agent-ansi
Requires:  openvox-agent-kafo-parsers >= 0.1.6
Requires:  openvox-agent-logging < 3
Requires:  openvox-agent-clamp >= 1.3.1
Requires:  openvox-agent-clamp < 2
Requires:  openvox-agent-highline >= 1.6.21
Requires:  openvox-agent-highline < 4
Requires:  openvox-agent-powerbar
Requires:  /opt/puppetlabs/puppet/bin/gem
Requires:  sed
BuildArch: noarch
Obsoletes: puppet-agent-kafo

%description
If you write puppet modules for installing your software, you can use kafo to
create powerful installer.

%prep
%setup -q -c -T
cp -a %{SOURCE0} ./

%build

%install
mkdir -p %{buildroot}%{gem_cache_dir}
cp -a ./%{gem_name}-%{version}.gem %{buildroot}%{gem_cache_dir}

%files
%{gem_cache_dir}/%{gem_name}-%{version}.gem

%post
/opt/puppetlabs/puppet/bin/gem install --local %{gem_cache_dir}/%{gem_name}-%{version}.gem >/dev/null && sed -i "s/next if line\.start_with\?.*$/next if line.start_with?('#') || line.empty?/" /opt/puppetlabs/puppet/lib/ruby/gems/*/gems/%{gem_name}-%{version}/lib/kafo/data_type_parser.rb

%preun
if [ $1 == 0 ]; then  # uninstall
  /opt/puppetlabs/puppet/bin/gem uninstall -x -v %{version} %{gem_name} >/dev/null
else  # upgrade
  # Only uninstall on upgrade if there are multiple gem versions installed, as the package
  # is probably changing version, not only undergoing a release bump
  if ! /opt/puppetlabs/puppet/bin/gem list %{gem_name} | grep %{gem_name} | grep -q '(%{version})'; then
    /opt/puppetlabs/puppet/bin/gem uninstall -x -v %{version} %{gem_name} >/dev/null
  fi
fi

%changelog
* Wed Aug 05 2026 Lennart Betz <lbetz@prefork.de> - 7.8.0-1
- Release 7.8.0, rename package, remove OpenVox 7 support
* Fri Aug 30 2024 Lennart Betz <lennart.betz@netways.de> - 7.5.0-1
- Release 7.5.0
