project('contacts2phone', ['objc', 'objcpp'], meson_version: '>=1.5.0')

objfw = dependency('objfw')
libebook = dependency('libebook-1.2')
libedataserver = dependency('libedataserver-1.2')

executable('contacts2phone',
    sources,
    dependencies: [objfw, libebook, libedataserver]
)
