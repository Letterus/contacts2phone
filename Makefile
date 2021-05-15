all:
	@objfw-compile `pkg-config --cflags glib-2.0 libedataserver-1.2 libebook-1.2 --libs glib-2.0 libedataserver-1.2 libebook-1.2` -o addr2snom A2SApplication.m A2SEvolutionDataService.m Exception/A2SDescriptionException.m Exception/A2SEDSException.m
