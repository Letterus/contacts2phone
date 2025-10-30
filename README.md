# contacts2phone

This branch is developing the app featuring a GUI to upload contacts from a GNOME addressbook to an Snom VoIP phone (M300/M700/M900) using the [IPPhoneDirectory format](https://service.snom.com/display/wiki/How+to+use+the+Local+Central+Directory+on+M300%2C+M700%2C+M900+DECT+base#HowtousetheLocalCentralDirectoryonM300,M700,M900DECTbase-TheIPPhoneDirectoryformat) (Local Central Directory) (WIP)

## Build dependencies

See [meson file](meson.build).

## How to build

- Install dependencies
- `meson setup builddir && cd builddir`
- `meson compile`
- `sudo meson install`
