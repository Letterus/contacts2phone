project('contacts2phone')

add_languages('cpp', 'objc', 'objcpp', native: false)

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

subdir('src')

executable('contacts2phone',
    sources,
    peel_headers,
    dependencies: [objfw, peel, gtk4, libadwaita, libebook]
)
