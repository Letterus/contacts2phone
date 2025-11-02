project('contacts2phone', ['objc', 'objcpp'], meson_version: '>=1.5.0')

objfw = dependency('objfw')
gtk4 = dependency('gtk4')
libadwaita = dependency('libadwaita-1', version: '>= 1.5')
libebook = dependency('libebook-1.2')

peel = dependency('peel')

peel_gen = find_program('peel-gen')
peel_headers = custom_target('peel-codegen',
  command: [
    peel_gen,
    '--api-tweaks', '/usr/local/share/peel/api-tweaks.txt',
    '--recursive',
    '--out-dir', '@OUTDIR@',
    'Gtk', '4.0',
    'Adw', '1',
    'EBook', '1.2'
  ],
  output: 'peel',
)

glib_compile_resources = find_program('glib-compile-resources')
gtk_resources = custom_target('compile-resources',
  command: [
    glib_compile_resources,
    '--sourcedir', '../res/GTK/UI/',
    '../res/GTK/UI/c2p.gresource.xml',
    '--target=resources.m',
    '--generate-source'
  ],
  output: 'resources.m'
)

subdir('src')

executable('contacts2phone',
    sources,
    peel_headers,
    gtk_resources,
    dependencies: [objfw, peel, gtk4, libadwaita, libebook]
)
