ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif
PATH  := /usr/local/bin:$(PATH)
CC    := clang
CFLAGS := $$(objfw-config --package ObjGTK4 --package OGAdw --package OGEBook --package OGEBookContacts --package OGEDataServer --package OGCamel --package OGObject --cppflags)
OBJCFLAGS := $$(objfw-config --objcflags)
LIBS := $$(objfw-config --package ObjGTK4 --package OGAdw --package OGEBook --package OGEBookContacts --package OGEDataServer --package OGCamel --package OGObject --rpath --libs)

OBJ := obj
RES := res

M_SOURCES := $(wildcard src/*.m) $(wildcard src/Service/*.m) $(wildcard src/Controller/GTK/*.m) $(wildcard src/Exception/*.m) $(wildcard src/Model/*.m)
OBJECTS := $(patsubst %.m, $(OBJ)/%.o, $(M_SOURCES)) $(OBJ)/View/GTK/C2PAddressBookListBoxRow.o $(OBJ)/$(RES)/GTK/UI/resource.o 

contacts2phone: $(OBJECTS)
	$(CC) $^ -o $@ $(LIBS)

$(RES)/GTK/UI/resource.c: $(RES)/GTK/UI/c2p.gresource.xml
	$$(glib-compile-resources $< --target=$@ --generate-source)

$(OBJ)/$(RES)/GTK/UI/%.o: res/GTK/UI/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ)/View/GTK/%.o: src/View/GTK/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

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
