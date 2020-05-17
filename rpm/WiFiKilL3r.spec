# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       WiFiKilL3r

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    WiFiKilL3r
Version:    0.11
Release:    1
Group:      Qt/Qt
License:    LICENSE
URL:        https://theyosh.nl
Source0:    %{name}-%{version}.tar.bz2
Source100:  WiFiKilL3r.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   pyotherside-qml-plugin-python3-qt5
Requires:   dbus-python3
Requires:   systemd
Requires:   systemd-user-session-targets
Requires:   connman-tools
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
WiFiKilL3r will monitor your WiFi status and shuts it down when not connected to a trusted network. This will protect your from WiFi location tracking devices in cities and other locations.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files

# Post is officially not allowed.... :(
%post
chmod 4755 /usr/share/WiFiKilL3r/qml/bin/*-wifi-root_*
chmod 4755 /usr/share/WiFiKilL3r/qml/python/WiFiKilL3r_Cron.sh
chmod 4755 /usr/share/WiFiKilL3r/qml/python/WiFiKilL3r.py
rm /home/nemo/.local/share/systemd/user/WiFiKilL3r.* 2> /dev/null || true
rm /usr/lib/systemd/user/WiFiKilL3r.* 2> /dev/null || true
cp -u /usr/share/WiFiKilL3r/qml/python/systemd/WiFiKilL3r.* /home/nemo/.config/systemd/user/ 2> /dev/null || true
chown nemo. /home/nemo/.config/systemd/user/WiFiKilL3r.*
su -c 'systemctl --user daemon-reload' -s /bin/bash nemo

# Due to some fuck ups.... we need to clean up...
if [ -L /home/nemo/.config/systemd/user/timers.target.wants/WiFiKilL3r.timer ] && [ ! -e /home/nemo/.config/systemd/user/timers.target.wants/WiFiKilL3r.timer ]
then
  rm /home/nemo/.config/systemd/user/timers.target.wants/WiFiKilL3r.timer
  su -c 'systemctl --user enable WiFiKilL3r.timer' -s /bin/bash nemo
fi

if [ -L /home/nemo/.config/systemd/user/user-session.target.wants/WiFiKilL3r.service ] && [ ! -e /home/nemo/.config/systemd/user/user-session.target.wants/WiFiKilL3r.service ]
then
  rm /home/nemo/.config/systemd/user/user-session.target.wants/WiFiKilL3r.service
  su -c 'systemctl --user enable WiFiKilL3r.service' -s /bin/bash nemo
fi
