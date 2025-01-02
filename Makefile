ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif
PATH  := /usr/local/bin:$(PATH)
CC    := clang
CFLAGS := $$(objfw-config --package OGEBook --package OGEBookContacts --package OGEDataServer --package OGCamel --package OGObject --cppflags)
OBJCFLAGS := $$(objfw-config --objcflags)
LIBS := $$(objfw-config --package OGEBook --package OGEBookContacts --package OGEDataServer --package OGCamel --package OGObject --rpath --libs)

OBJ := obj

SOURCES := $(wildcard *.m) $(wildcard Service/*.m) $(wildcard View/GTK/*.m) $(wildcard Exception/*.m) $(wildcard Model/*.m)
OBJECTS := $(patsubst %.m, $(OBJ)/%.o, $(SOURCES))

contacts2phone: $(OBJECTS)
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

build: contacts2phone

install: contacts2phone
	@install -d $(DESTDIR)$(PREFIX)/bin/
	@install -m 755 contacts2phone $(DESTDIR)$(PREFIX)/bin/

run: contacts2phone
	@./contacts2phone
