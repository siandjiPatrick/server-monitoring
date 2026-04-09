Name:           siandjiservmon
Version:        1.0
Release:        1%{?dist}
Summary:        Smart Monitoring Tool

License:        MIT
BuildArch:      noarch

Requires:       bash
Requires:	postfix 
Requires:       s-nail 
Requires:       cyrus-sasl 
Requires:       cyrus-sasl-plain

Source0:        siandjiservmon-1.0.tar.gz

%description
Smart monitoring tool with modular scripts.

# =====================
%prep
%setup -q -n server-monitoring


# Rename systemd service file to match package expectation
if [ -f systemd/siandjiservice.service ]; then
    mv systemd/siandjiservice.service systemd/siandjiservmon.service
fi

# =====================
%build
# nothing to build

# =====================
%install

rm -rf %{buildroot}

# Binary
install -Dm755 bin/siandjiservmon.sh \
  %{buildroot}/usr/local/bin/siandjiservmon

# Libraries
mkdir -p %{buildroot}/usr/lib/siandjiservmon
cp -r lib %{buildroot}/usr/lib/siandjiservmon/
cp -r manage %{buildroot}/usr/lib/siandjiservmon/
cp -r notify %{buildroot}/usr/lib/siandjiservmon/

# Config
mkdir -p %{buildroot}/etc/siandjiservmon
cp config/email.cf %{buildroot}/etc/siandjiservmon/
cp config/email_template.conf %{buildroot}/etc/siandjiservmon/

# Logs
mkdir -p %{buildroot}/var/log/siandjiservmon

# systemd
if [ -d systemd ]; then
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

%config(noreplace) /etc/siandjiservmon/email.cf
%config(noreplace) /etc/siandjiservmon/email_template.conf

/var/log/siandjiservmon

/usr/lib/systemd/system/siandjiservmon.service

# =====================
%changelog
* Tue Apr 07 2026 Patrick siandji
- Initial package (improve)
