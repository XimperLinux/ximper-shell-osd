project('ximper-shell-osd', ['vala', 'c'],
  version: '0.1.0',
  meson_version: '>= 0.62.0',
)

subdir('src')
subdir('data')

conf_data = configuration_data()
conf_data.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))

configure_file(
  configuration: conf_data,
  input: 'services/dbus/ru.ximperlinux.shell.OSD.service.in',
  output: 'ru.ximperlinux.shell.OSD.service',
  install_dir: get_option('datadir') / 'dbus-1' / 'services',
)
