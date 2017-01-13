PREFIX  = /opt/riscv
ARCH    = riscv32-unknown-elf
BINDIR  = $(PREFIX)/bin
ADDNAME = $(ARCH)-

AR      = $(BINDIR)/$(ADDNAME)ar
AS      = $(BINDIR)/$(ADDNAME)as
CC      = $(BINDIR)/$(ADDNAME)gcc
LD      = $(BINDIR)/$(ADDNAME)ld
NM      = $(BINDIR)/$(ADDNAME)nm
OBJCOPY = $(BINDIR)/$(ADDNAME)objcopy
OBJDUMP = $(BINDIR)/$(ADDNAME)objdump
RANLIB  = $(BINDIR)/$(ADDNAME)ranlib
STRIP   = $(BINDIR)/$(ADDNAME)strip

OBJS  = startup.o main.o
OBJS += lib.o serial.o xmodem.o elf.o

TARGET = kzload

CFLAGS = -Wall -nostdinc -nostdlib -fno-builtin
CFLAGS += -I.
#CFLAGS += -g
CFLAGS += -O
CFLAGS += -DKZLOAD

LFLAGS = -static -n -Tld.scr -L.

.SUFFIXES: .c .o
.SUFFIXES: .s .o

all :		$(TARGET)

$(TARGET) :	$(OBJS)
		$(CC) $(OBJS) -o $(TARGET) $(CFLAGS) $(LFLAGS)
		cp $(TARGET) $(TARGET).elf
		$(STRIP) $(TARGET)
		$(OBJCOPY) -O ihex kzload.elf kzload.ihex
		./ramcnv.pl kzload.ihex
		mv ram.data? ../../verilog/

.c.o :		$<
		$(CC) -c $(CFLAGS) $<

.s.o :		$<
		$(CC) -c $(CFLAGS) $<

$(TARGET).mot :	$(TARGET)
		$(OBJCOPY) -O srec $(TARGET) $(TARGET).mot

image :		$(TARGET).mot

clean :
		rm -f $(OBJS) $(TARGET) $(TARGET).elf $(TARGET).mot $(TARGET).ihex ../../verilog/ram.data?
