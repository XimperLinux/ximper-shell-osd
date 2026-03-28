osd_deps = [
  dependency('gtk4', version: '>= 4.12'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('gtk4-layer-shell-0', version: '>= 1.0'),
  dependency('json-glib-1.0'),
  dependency('gio-unix-2.0'),
]

osd_sources = files(
  'main.vala',
  'application.vala',
  'config.vala',
  'osd-window.vala',
  'osd-content.vala',
  'dbus-service.vala',
)

if get_option('pulse-audio')
  add_project_arguments('-D', 'HAVE_PULSE_AUDIO', language: 'vala')
  osd_deps += [
    dependency('libpulse'),
    dependency('libpulse-mainloop-glib'),
  ]
  osd_sources += files(
    'monitors/pulse-monitor.vala',
  )
endif

executable('ximper-shell-osd', osd_sources,
  dependencies: osd_deps,
  c_args: ['-w'],
  install: true,
)
