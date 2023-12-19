#============== TARGET_OPTIONS ===============
CFLAGS :=
LDFLAGS :=
SRC :=
BIN := build/clang

BC = $(CXX)

include ../Makefile.config

#=================== RULES ==================
.PHONY: clean default $(BIN) name_bin name_obj

default: $(BIN)

$(LINKEDBIN):
	mkdir -p build
	cp -a $(LINKEDBIN:build/%=%) $(LINKEDBIN)

$(BIN): $(LINKEDBIN)
	$(OPTTIMECMD) $(LLOPT) $(FM_FLAGS) $(LINKEDBIN) -o $(BIN).tmp.bc
ifeq ($(DISASSEMBLE), true)
	$(LLDIS) $(BIN).tmp.bc -o $(BIN).$(NAME).ll
endif
	$(LLCTIMECMD) $(BC) -x ir $(BIN).tmp.bc $(OPT) -Os -fPIC -fno-semantic-interposition -fvisibility-inlines-hidden -ffunction-sections -fdata-sections -fno-common -o $(BIN).o.$(NAME) -c
	$(LLDTIMECMD) $(BC) $(BIN).o.$(NAME) $(OPT) -fuse-ld=$(LLD) -o $(BIN).$(NAME) -Wl,--export-dynamic -lpthread  -lrt  -ldl  -lpthread  -lm  /usr/lib/x86_64-linux-gnu/libz.so  /usr/lib/x86_64-linux-gnu/libtinfo.so


clean:
	$(RM) $(LBINS) build/*

name_bin:
	@echo $(BIN).$(NAME)

name_obj:
	@echo $(BIN).o.$(NAME)
