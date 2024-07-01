ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif
PATH  := /usr/local/bin:$(PATH)
CC    := clang
CFLAGS := $$(objfw-config --package OGEBook --package OGEBookContacts --package OGEDataServer --package OGCamel --package OGObject --cppflags)
OBJCFLAGS := $$(objfw-config --objcflags)
LIBS := $$(objfw-config --package OGEBook --package OGEBookContacts --package OGEDataServer --package OGCamel --package OGObject --rpath --libs)

OBJ := obj

SOURCES := $(wildcard *.m) $(wildcard Exception/*.m) $(wildcard Model/*.m)
OBJECTS := $(patsubst %.m, $(OBJ)/%.o, $(SOURCES))

addr2snom: $(OBJECTS)
	$(CC) $^ -o $@ $(LIBS)

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
