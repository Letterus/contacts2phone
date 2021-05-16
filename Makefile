PATH  := /usr/local/bin:$(PATH)
CC    := clang
CFLAGS := $$(pkg-config --cflags glib-2.0 libedataserver-1.2 libebook-1.2) $$(objfw-config --cppflags)
OBJCFLAGS := $$(objfw-config --objcflags)
LIBS := $$(pkg-config --libs glib-2.0 libedataserver-1.2 libebook-1.2) $$(objfw-config --rpath --libs)

OBJ := obj

SOURCES := $(wildcard *.m) $(wildcard Exception/*.m) $(wildcard Model/*.m)
OBJECTS := $(patsubst %.m, $(OBJ)/%.o, $(SOURCES))

addr2snom: $(OBJECTS)
	$(CC) $(LIBS) $^ -o $@

$(OBJ)/%.o: %.m
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ)/Exception/%.o: Exception/%.m
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ)/Model/%.o: Model/%.m
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

build: addr2snom

run: addr2snom
	./addr2snom
