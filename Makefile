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
VALA_SOURCES := src/View/GTK/C2PAddressBookListRow.vala
VALA_NAMESPACE := src/View/GTK/C2P.vala
VALA_C_SOURCES := $(patsubst %.vala, %.c, $(VALA_SOURCES))
RESOURCE_C_SOURCES :=  $(RES)/GTK/UI/resource.c
OBJECTS := $(patsubst %.m, $(OBJ)/%.o, $(M_SOURCES)) $(patsubst %.c, $(OBJ)/%.o, $(VALA_C_SOURCES)) $(patsubst %.c, $(OBJ)/%.o, $(RESOURCE_C_SOURCES))
TARGET := contacts2phone

$(TARGET): $(OBJECTS)
	$(CC) $^ -o $@ $(LIBS)

$(OBJECTS): $(VALA_C_SOURCES)

src/View/GTK/%.c: src/View/GTK/%.vala
	$$(valac --pkg gtk4 -C --target-glib=auto -g --enable-checking --enable-experimental-non-null --gresources res/GTK/UI/c2p.gresource.xml -h $(patsubst %.c,%.h,$@) $< $(VALA_NAMESPACE))

$(OBJ)/src/View/GTK/%.o: src/View/GTK/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ)/$(RES)/GTK/UI/%.o: $(RES)/GTK/UI/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(RESOURCE_C_SOURCES): %: $(RES)/GTK/UI/c2p.gresource.xml
	$$(glib-compile-resources --sourcedir $(RES)/GTK/UI/ $< --target=$@ --generate-source)

$(OBJ)/%.o: %.m
	@mkdir -p $(@D)
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ)/Exception/%.o: Exception/%.m
	@mkdir -p $(@D)
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ)/Model/%.o: Model/%.m
	@mkdir -p $(@D)
	$(CC) $(OBJCFLAGS) $(CFLAGS) -c $< -o $@

build: $(TARGET)

install: $(TARGET)
	@install -d $(DESTDIR)$(PREFIX)/bin/
	@install -m 755 contacts2phone $(DESTDIR)$(PREFIX)/bin/

run: $(TARGET)
	@./$<

clean:
	@rm -f $(OBJECTS) $(TARGET)
	@rm -f res/GTK/UI/resource.c
	@rm -f src/View/GTK/*.c
