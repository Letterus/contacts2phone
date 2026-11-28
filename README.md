# contacts2phone

A CLI tool to upload contacts from an Evolution/GNOME addressbook to an Snom VoIP phone (M300/M700/M900) using the [IPPhoneDirectory format](https://service.snom.com/display/wiki/How+to+use+the+Local+Central+Directory+on+M300%2C+M700%2C+M900+DECT+base#HowtousetheLocalCentralDirectoryonM300,M700,M900DECTbase-TheIPPhoneDirectoryformat) (Local Central Directory).

## Usage

```
contacts2phone [-l|--list]
	[-s "Addressbook Display Name"|--select="Addressbook Display Name"
	-u http://host|--upload-to-host=http://host
	-n username|--username=username]
```

Options:

- `-l|--list` will list available Evolution addressbooks, shown by their displayname.
- `-s "Addressbook Display Name"|--select="Addressbook Display Name"` Select an addressbook by its displayname to process it as XML. If you don't specify `-u` it will print the XML file to StdOut. Use the `>` operator to save it to a file.
- `-u`, `-p`, `-n` are work in progress currently.

## Build dependencies

See [meson file](meson.build).

## How to build

- Install dependencies
- `meson setup builddir && cd builddir`
- `meson compile`
- `sudo meson install`
