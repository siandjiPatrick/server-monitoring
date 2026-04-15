#!/usr/bin/env bash

set -euo pipefail
ancien_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# définir la plage de logs
if [[ -z "$ancien_tag" ]]; then
    echo "No previous tag found -> first release"
    RANGE="HEAD"
else
    echo "Previous release: $ancien_tag"
    RANGE="${ancien_tag}..HEAD"
fi

# générer le changelog RPM
CHANGELOG=$(git log "$RANGE" --pretty=format:"- %s")
cat > "${RPMBUILD_DIR}/SPECS/${PACKAGE_NAME}.spec" <<EOF

Name:           $PACKAGE_NAME
Version:        $new_version
Release:        1%{?dist}
Summary:        Smart Monitoring Tool


License:        MIT
URL:            https://github.com/siandjiPatrick/server-monitoring/tree/develop
Packager:       Patrick Siandji <patrick@example.com>
BuildArch:      noarch

BuildRequires:  bash
BuildRequires:  systemd
BuildRequires:  systemd-rpm-macros

%{?systemd_requires}

Requires:       bash
Requires:	postfix 
Requires:       s-nail 
Requires:       cyrus-sasl 
Requires:       cyrus-sasl-plain
Requires: 	curl

Source0: 	$PACKAGE_TAR_FILE        

%description
Smart monitoring tool with modular scripts made by Patrick.

# =====================
%prep
%setup -q -n server-monitoring


# =====================
%build
# nothing to build

# =====================
%install

rm -rf %{buildroot}

# siandjiservmon Data
install -D -m 0755 src/data/report.txt %{buildroot}/var/lib/siandjiservmon/report.txt

# Binary
install -Dm755 src/bin/siandjiservmon.sh %{buildroot}/usr/bin/siandjiservmon

# Libraries
mkdir -p %{buildroot}/usr/lib/siandjiservmon
cp -a src/lib %{buildroot}/usr/lib/siandjiservmon/
find %{buildroot}/usr/lib/siandjiservmon -type f -name "*.sh" -exec chmod 755 {} \;
find %{buildroot}/usr/lib/siandjiservmon -type f ! -name "*.sh" -exec chmod 644 {} \;

# Config
mkdir -p %{buildroot}/etc/siandjiservmon
cp src/config/postfix.conf.example %{buildroot}/etc/siandjiservmon/
cp src/config/email_template.conf %{buildroot}/etc/siandjiservmon/
cp src/config/siandjiservmon.conf %{buildroot}/etc/siandjiservmon/

# Logs
install -d -m 0755 %{buildroot}/var/log/siandjiservmon
touch %{buildroot}/var/log/siandjiservmon/siandjiservmon.log

# systemd
if [ -d src/systemd ]; then
  mkdir -p %{buildroot}/usr/lib/systemd/system
  cp -v src/systemd/*.service %{buildroot}/usr/lib/systemd/system/ || true
fi

# ====================
%pre

echo "create service user"
getent group siandjiservmon >/dev/null || groupadd -r siandjiservmon
getent passwd siandjiservmon >/dev/null || useradd -r -g siandjiservmon -d /var/lib/siandjiservmon -s /sbin/nologin siandjiservmon

# ======================
%post
%systemd_post siandjiservmon.service

# =====================
%preun
%systemd_preun siandjiservmon.service 

# =====================
%postun
%systemd_postun_with_restart siandjiservmon.service

# =====================
%files

#set default permision
#%defattr(0644, root, root, 0755)

#%{_bindir}/siandjiservmon
%attr(755, root , root ) /usr/bin/siandjiservmon

#%{_libdir}/siandjiservmon/*
/usr/lib/siandjiservmon/

%attr(644, root, root) /usr/lib/systemd/system/siandjiservmon.service

#%{_sysconfdir}/siandjiservmon/*
%config(noreplace) /etc/siandjiservmon/postfix.conf.example
%config(noreplace) /etc/siandjiservmon/email_template.conf
%config(noreplace) /etc/siandjiservmon/siandjiservmon.conf


%attr(755, siandjiservmon, siandjiservmon) /var/log/siandjiservmon
%attr(664, siandjiservmon, siandjiservmon) /var/log/siandjiservmon/siandjiservmon.log

#%attr(755, siandjiservmon, siandjiservmon) /var/lib/siandjiservmon
%attr(664, siandjiservmon, siandjiservmon) /var/lib/siandjiservmon/report.txt


# =====================
%changelog
#git log --pretty=format:"* %cd %an <%ae> - ${new_version}-1%n- %s" --date=format:"%a %b %d %Y"
* $(date "+%a %b %d %Y") Patrick <patrick@example.com> - ${new_version}-1
$CHANGELOG
EOF
