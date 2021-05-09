all:
	@objfw-compile `pkg-config --cflags glib-2.0 libedataserver-1.2 libebook-1.2 --libs glib-2.0 libedataserver-1.2 libebook-1.2` -o addr2snom A2SApplication.m A2SEvolutionDataService.m Exceptions/A2SDescriptionException.m Exceptions/A2SEDSException.m
