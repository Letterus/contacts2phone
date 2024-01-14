ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif
PATH  := /usr/local/bin:$(PATH)
CC    := clang
CFLAGS := $$(pkg-config --cflags glib-2.0) $$(objfw-config --package OGEBook --package OGEDataServer --cppflags)
OBJCFLAGS := $$(objfw-config --objcflags)
LIBS := $$(pkg-config --libs glib-2.0) $$(objfw-config --package OGEBook --package OGEDataServer --rpath --libs)

OBJ := obj

SOURCES := $(wildcard *.m) $(wildcard Exception/*.m) $(wildcard Model/*.m)
OBJECTS := $(patsubst %.m, $(OBJ)/%.o, $(SOURCES))

addr2snom: $(OBJECTS)
	$(CC) $(LIBS) $^ -o $@

$(OBJ)/%.o: %.m
	@mkdir -p $(@D)
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ)/Exception/%.o: Exception/%.m
	@mkdir -p $(@D)
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ)/Model/%.o: Model/%.m
	@mkdir -p $(@D)
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

build: addr2snom

install: addr2snom
	@install -d $(DESTDIR)$(PREFIX)/bin/
	@install -m 755 addr2snom $(DESTDIR)$(PREFIX)/bin/

run: addr2snom
	@./addr2snom
