# contacts2phone

Tool to upload contacts from a GNOME addressbook to an Snom VoIP phone (M300/M700/M900) using the [IPPhoneDirectory format](https://service.snom.com/display/wiki/How+to+use+the+Local+Central+Directory+on+M300%2C+M700%2C+M900+DECT+base#HowtousetheLocalCentralDirectoryonM300,M700,M900DECTbase-TheIPPhoneDirectoryformat) (Local Central Directory) (WIP)

## Current usage

Execute and redirect stdout output:

```
./contacts2phone > Directory.xml
```

To save directory file locally.

Use this to upload to your IP DECT base directly (if you have curl installed):
```
 ./contacts2phone | curl -i -X POST -u <adminuser> -F "Directory=@-" http://<ip address>/UploadFile.html
```

Replace `<adminuser>` and `<ip address>` by your local values. Hit return.

Insert your admin password. You should see HTML output telling you the settings were saved.

## Build dependencies

- [objfw-1.x (built with clang)](https://github.com/ObjFW/ObjFW)
- glib-2.0
- libedataserver-1.2
- libebook-1.2
- [OGObject (latest)](https://codeberg.org/ObjGTK/OGObject)
- [OGEBook (latest)](https://codeberg.org/ObjGTK/OGEBook)

Installation for Ubuntu/elementary OS:

```
sudo apt-get install libglib2.0-dev libedataserver1.2-dev libebook1.2-dev
```

And from sources (currently).
