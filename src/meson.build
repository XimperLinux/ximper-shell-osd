cc = meson.get_compiler('c')

osd_deps = [
  dependency('gtk4', version: '>= 4.12'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('gtk4-layer-shell-0', version: '>= 1.0'),
  dependency('json-glib-1.0'),
  dependency('gio-unix-2.0'),
  cc.find_library('m', required: false),
]

osd_sources = files(
  'main.vala',
  'application.vala',
  'config.vala',
  'osd-window.vala',
  'osd-content.vala',
  'dbus-service.vala',
  'monitors/backlight-monitor.vala',
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

if get_option('ddc')
  add_project_arguments('-D', 'HAVE_DDC', language: 'vala')
  ddcutil_vapi_dir = meson.current_source_dir() / 'monitors'
  osd_deps += [
    cc.find_library('ddcutil', required: true),
    meson.get_compiler('vala').find_library('ddcutil', dirs: ddcutil_vapi_dir),
  ]
  osd_sources += files(
    'monitors/ddc-monitor.vala',
  )
endif

executable('ximper-shell-osd', osd_sources,
  dependencies: osd_deps,
  c_args: ['-w'],
  install: true,
)
