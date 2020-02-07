RUST_LIB_NAME = terminus_store_prolog
RUST_LIB = lib$(RUST_LIB_NAME).$(SOEXT)
RUST_TARGET=release
RUST_TARGET_DIR = rust/target/$(RUST_TARGET)/
CC = gcc
ARCH = 
TARGET = $(PACKSODIR)/libterminus_store.$(SOEXT)
CARGO_FLAGS=

all: release

rust_bindings:
	cbindgen --config rust/cbindgen.toml rust/src/lib.rs --output c/terminus_store.h

check::

build:
	mkdir -p $(PACKSODIR)
	cd rust; cargo build $(CARGO_FLAGS)
	cp $(RUST_TARGET_DIR)/$(RUST_LIB) $(PACKSODIR)
	$(CC) -shared $(CFLAGS) -Wall -o $(TARGET) ./c/*.c -Isrc -L./$(PACKSODIR) -Wl,-rpath='$$ORIGIN' -l$(RUST_LIB_NAME)

debug: RUST_TARGET = debug
debug: CFLAGS += -ggdb
debug: build

release: RUST_TARGET = release
release: CARGO_FLAGS += --release
release: CFLAGS += -O3
release: build

install::

clean:
	rm -rf *.$(SOEXT) lib buildenv.sh
	cd rust; cargo clean
