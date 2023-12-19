#============== TARGET_OPTIONS ===============
CFLAGS :=
LDFLAGS :=
SRC :=
BIN := build/vmlinux.o

BC = $(CC)

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
	$(LLCTIMECMD) $(BLD) -x ir $(BIN).tmp.bc $(OPT) -o $(BIN).o.$(NAME) -c $(LDFLAGS)
	$(LLDTIMECMD) $(LLD) -m elf_x86_64 -mllvm -import-instr-limit=5 -r -o $(BIN).$(NAME) -T tmp_initcalls.lds --whole-archive $(BIN).o.$(NAME) arch/x86/kernel/head_64.o usr/built-in.a arch/x86/built-in.a certs/built-in.a arch/x86/lib/built-in.a arch/x86/lib/lib.a arch/x86/power/built-in.a --no-whole-archive --start-group --end-group

clean:
	$(RM) $(LBINS) build/*

name_bin:
	@echo $(BIN).$(NAME)

name_obj:
	@echo $(BIN).o.$(NAME)
