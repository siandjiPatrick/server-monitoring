Name:           siandjiservmon
Version:        1.0
Release:        1%{?dist}
Summary:        Smart Monitoring Tool


License:        MIT
URL:            https://github.com/siandjiPatrick/server-monitoring/tree/develop
Packager:       Patrick Siandji <patrick@example.com>
BuildArch:      noarch

BuildRequires:  bash
BuildRequires:  systemd

Requires:       bash
Requires:	      postfix 
Requires:       s-nail 
Requires:       cyrus-sasl 
Requires:       cyrus-sasl-plain

Source0:        siandjiservmon-1.0.tar.gz

%description
Smart monitoring tool with modular scripts.

# =====================
%prep
%setup -q -n server-monitoring

# =====================
%build
# nothing to build

# =====================
%install

rm -rf %{buildroot}

# Binary
install -Dm755 src/bin/siandjiservmon.sh \
  %{buildroot}/usr/local/bin/siandjiservmon

# Libraries
mkdir -p %{buildroot}/usr/lib/siandjiservmon
cp -r src/lib %{buildroot}/usr/lib/siandjiservmon/
cp -r src/lib/manage %{buildroot}/usr/lib/siandjiservmon/lib
cp -r src/lib/notify %{buildroot}/usr/lib/siandjiservmon/lib

# Config
mkdir -p %{buildroot}/etc/siandjiservmon
cp config/postfix.conf.example %{buildroot}/etc/siandjiservmon/
cp config/email_template.conf %{buildroot}/etc/siandjiservmon/
cp config/siandjiservmon.conf %{buildroot}/etc/siandjiservmon/

# Logs
mkdir -p %{buildroot}/var/log/siandjiservmon
chown patrick:patrick %{buildroot}/var/log/siandjiservmon
chmod 770 %{buildroot}/var/log/siandjiservmon

# systemd
if [ -d src/systemd ]; then
  mkdir -p %{buildroot}/usr/lib/systemd/system
  cp systemd/* %{buildroot}/usr/lib/systemd/system/ || true
fi

# ======================
%post

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling smart-monitore service..."
systemctl enable siandjiservmon.service

# =====================
%preun

if [ $1 -eq 0 ]; then
    echo "Stopping service..."
    systemctl stop siandjiservmon.service || true

    echo "Disabling service..."
    systemctl disable siandjiservmon.service || true
fi


# =====================
%postun

echo "Reloading systemd..."
systemctl daemon-reload || true

# =====================
%files

/usr/local/bin/siandjiservmon

/usr/lib/siandjiservmon

%config(noreplace) /etc/siandjiservmon/email.conf
%config(noreplace) /etc/siandjiservmon/email_template.conf
%config(noreplace) /etc/siandjiservmon/siandjiservmon.conf

/var/log/siandjiservmon

/usr/lib/systemd/system/siandjiservmon.service

# =====================
%changelog
* Thu Apr 9 2026 Patrick Siandji <siandjipatrick@yahoo.fr> - 1.0-1
- renamed service 
- add new config 

* Tue Apr 07 2026 Patrick siandji
- Initial package (improve)
