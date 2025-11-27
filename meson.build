project('contacts2phone', ['objc', 'objcpp'], meson_version: '>=1.5.0')

objfw = dependency('objfw')
gtk4 = dependency('gtk4')
libadwaita = dependency('libadwaita-1', version: '>= 1.5')
libebook = dependency('libebook-1.2')
libedataserver = dependency('libedataserver-1.2')

peel = dependency('peel')

peel_gen = find_program('peel-gen')
peel_headers = custom_target('peel-codegen',
  command: [
    peel_gen,
    '--recursive',
    '--out-dir', '@OUTDIR@',
    'Gtk', '4.0',
    'Adw', '1',
    'EBook', '1.2'
  ],
  output: 'peel',
)

# Need to add gresources manually, because the Gnome module isn't compatible
# to objc(pp) projects.
resDir = '../res'
resSource = 'resources.m'
resInput = files(
  'res/GTK/UI/c2p.gresource.xml',
  'res/GTK/UI/AddressBookListRow.ui',
  'res/GTK/UI/MainView.ui'
  )

glib_compile_resources = find_program('glib-compile-resources')
gtk_resources = custom_target('compile-resources',
  input: resInput,
  output: resSource,
  command: [
    glib_compile_resources,
    '--sourcedir', f'@resDir@/GTK/UI/',
    f'@resDir@/GTK/UI/c2p.gresource.xml',
    '--target=@OUTPUT@',
    '--generate-source'
  ]
)

subdir('src')

executable('contacts2phone',
    sources,
    peel_headers,
    gtk_resources,
    dependencies: [objfw, peel, gtk4, libadwaita, libebook, libedataserver]
)
