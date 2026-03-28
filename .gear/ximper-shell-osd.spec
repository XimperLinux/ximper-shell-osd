%define xdg_name ru.ximperlinux.shell.OSD

Name: ximper-shell-osd
Version: 0.1.0
Release: eter1
License: GPL-3.0

Summary: OSD overlay for Ximper Shell

Group: Graphical desktop/Other

Url: https://gitlab.eterfund.ru/ximperlinux/ximper-shell-osd
Vcs: https://gitlab.eterfund.ru/ximperlinux/ximper-shell-osd.git

Source: %name-%version.tar

BuildRequires(pre): rpm-macros-meson rpm-build-xdg

BuildRequires: meson
BuildRequires: vala

BuildRequires: vapi(gtk4-layer-shell-0)

BuildRequires: pkgconfig(gtk4)
BuildRequires: pkgconfig(json-glib-1.0)
BuildRequires: pkgconfig(libadwaita-1)
BuildRequires: pkgconfig(gtk4-layer-shell-0)

BuildRequires: pkgconfig(libpulse)
BuildRequires: pkgconfig(ddcutil)

%description
An on-screen display daemon for volume and brightness with GTK4/Libadwaita GUI for Wayland.
A component of the Ximper Shell.

%prep
%setup

%build
%meson
%meson_build

%install
%meson_install

%files
%_bindir/%name

%_datadir/dbus-1/services/%xdg_name.service

%dir %_xdgconfigdir/ximper-shell/osd
%config %_xdgconfigdir/ximper-shell/osd/*

%changelog
* Fri Mar 28 2026 Kirill Unitsaev <fiersik@altlinux.org> 0.1.0-eter1
- Initial build
