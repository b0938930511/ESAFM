SRC := lbm.c main.c
SRC := $(addprefix src/, $(SRC))
CFLAGS := -DLARGE_WORKLOAD -DSPEC_LP64 -DSPEC -DNDEBUG
LDFLAGS := -lm
BENCH := 619.lbm_s

include ../Makefile.config
