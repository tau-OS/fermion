sources = [
   'application.vala',
   'window.vala',
   'preferences.vala',
   'utils.vala',
   'widgets/terminal.vala',
   'handlers/keyboard.vala',
   'handlers/mouse.vala',
   'dialogs/unsafe_paste.vala',
   'dialogs/process.vala'
]

config_file = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf
)

deps = [
    dependency('gtk4'),
    dependency('libhelium-1'),
    dependency('gee-0.8'),
    dependency('vte-2.91-gtk4', version: '>= 0.70'),
    dependency('libpcre2-8'),
    meson.get_compiler('vala').find_library('posix')
]

add_project_arguments(['--define', 'VTE_0_68_GTK4'], language : 'vala')

gnome = import('gnome')

executable(
    meson.project_name(),
	sources,
    config_file,
	asresources,
	vala_args: '--target-glib=2.50',
	dependencies: deps,
	install: true,
)
