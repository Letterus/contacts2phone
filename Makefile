all:
	@objfw-compile `pkg-config --cflags glib-2.0` `pkg-config --libs glib-2.0` `pkg-config --cflags libedataserver-1.2` `pkg-config --libs libedataserver-1.2` `pkg-config --cflags libebook-1.2` `pkg-config --libs libebook-1.2` --arc -o addr2snom Addr2Snom.m
