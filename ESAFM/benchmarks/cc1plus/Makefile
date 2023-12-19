#============== TARGET_OPTIONS ===============
CFLAGS :=
LDFLAGS :=
SRC :=
BIN := build/cc1plus
WHOLE_PROGRAM := true

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
	$(LLCTIMECMD) $(BC) -x ir $(BIN).tmp.bc $(OPT) -fno-strict-aliasing -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -o $(BIN).o.$(NAME) -c
	$(LLDTIMECMD) $(BC) -no-pie $(OPT) -fuse-ld=$(LLD) -fno-strict-aliasing -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -o $(BIN).$(NAME) $(BIN).o.$(NAME) libdecnumber.a -lmpc -lmpfr -lgmp -rdynamic -ldl -lz

clean:
	$(RM) $(LBINS) build/*

name_bin:
	@echo $(BIN).$(NAME)

name_obj:
	@echo $(BIN).o.$(NAME)
