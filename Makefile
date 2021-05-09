all:
	@objfw-compile `pkg-config --cflags glib-2.0` `pkg-config --libs glib-2.0` `pkg-config --cflags libedataserver-1.2` `pkg-config --libs libedataserver-1.2` `pkg-config --cflags libebook-1.2` `pkg-config --libs libebook-1.2` -o addr2snom A2SApplication.m Exceptions/A2SDescriptionException.m Exceptions/A2SEDSException.m
