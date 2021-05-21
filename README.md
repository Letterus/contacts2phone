# addr2snom

Tool to upload contacts from a GNOME addressbook to an Snom VoIP phone (M300/M700/M900) using the [IPPhoneDirectory format](https://service.snom.com/display/wiki/How+to+use+the+Local+Central+Directory+on+M300%2C+M700%2C+M900+DECT+base#HowtousetheLocalCentralDirectoryonM300,M700,M900DECTbase-TheIPPhoneDirectoryformat) (Local Central Directory) (WIP)

## Current usage

Execute and redirect stdout output:

```
./addr2snom > Directory.xml
```

To save directory file locally.

Use this to upload to your IP DECT base directly (if you have curl installed):
```
 ./addr2snom | curl -i -X POST -u <adminuser> -F "Directory=@-" http://<ip address>/UploadFile.html
```

Replace `<adminuser>` and `<ip address>` by your local values. Hit return.

Insert your admin password. You should see HTML output telling you the settings were saved.

## Dependencies

- objfw-1.0 (built with clang)
- glib-2.0
- libedataserver-1.2
- libebook-1.2

## Build dependencies

- clang
