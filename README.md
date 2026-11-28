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

## Current workaround

### Upload XML as long as that's not implemented

Use curl:

` ./contacts2phone -s "Addressbook" | curl -i -X POST -u <adminuser> -F "Directory=@-" http://<ip address>/UploadFile.html`

Replace `<adminuser>` and `<ip address>` by your local values. Hit return.

Insert your admin password. You should see HTML output telling you the settings were saved.

### Storing the password

Use `secret-tool` to store the password in GNOME keyring (Debian/Ubuntu package: `libsecret-tools`):

`secret-tool store --label "SNOM Phone Base" host <ip address> user <adminuser>`

### Use the password

Get it like this:

`secret-tool lookup host <ip address> user <adminuser>`

Use it with curl:

`./contacts2phone -s "Addressbook" | curl -i -X POST -u "<adminuser>:$(secret-tool lookup host <ip address> user <adminuser>)" -F "Directory=@-" http://<ip address>/UploadFile.html`

## Build dependencies

See [meson file](meson.build).

## How to build

- Install dependencies
- `meson setup builddir && cd builddir`
- `meson compile`
- `sudo meson install`
