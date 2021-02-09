#==============================================================================
# Copyright 2020 Daniel Boals & Michael Boals
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#==============================================================================


ASRC=startup.s
OBJS=
BUILDDIR = build
IMAGEDIR = disk_image
BCMBINS  = bcm_bins

#------------------------------------------------------------------------------
# Attempt to auto discover tool chain
#------------------------------------------------------------------------------
UNAME := $(shell uname)

ifeq (Darwin,$(findstring Darwin,$(UNAME)))
OS=MACOS
endif
ifeq (Linux,$(findstring Linux, $(UNAME)))
OS=LINUX
endif

ifeq (MACOS,$(OS))
CC      := $(shell which aarch64-none-elf-gcc)
AS      := $(shell which aarch64-none-elf-as)
LD      := $(shell which aarch64-none-elf-ld)
AR      := $(shell which aarch64-none-elf-ar) -rs
OBJCOPY := $(shell which aarch64-none-elf-objcopy)
MKDIR	:= mkdir
RMDIR	:= rm -rf
CP	:= cp
endif

ifeq (LINUX,$(OS))
CC      := $(shell which aarch64-none-elf-gcc )
AS      := $(shell which aarch64-none-elf-as )
LD      := $(shell which aarch64-none-elf-ld )
AR      := $(shell which aarch64-none-elf-ar ) -rs
OBJCOPY := $(shell which aarch64-none-elf-objcopy )
MKDIR	:= mkdir -p
RMDIR	:= rm -rf
CP	:= cp
endif


#------------------------------------------------------------------------------
# command line options for the various tools
#------------------------------------------------------------------------------
#LFLAGS      = -Map=$(BUILDROOT)/$@.map -L$(BUILDROOT) -static $(LIBS) $(LIBS)
CFLAGS      = -std=c11 -Wall -g -ggdb -O0 -fno-builtin -nostartfiles -Xlinker "-verbose -gc-sections" -ffunction-sections -std=c99 $(INC)
AFLAGS      = --gstabs+
CPPFLAGS    =


#
# convert our lists of sources to lists of object files
#
AOBJS       = $(strip $(patsubst %,$(BUILDDIR)/%,$(patsubst %.s,%.o,$(ASRC))))
OBJS        = $(strip $(patsubst %,$(BUILDDIR)/%,$(patsubst %.c,%.o,$(CSRC))))


#
# Targets to tell Make how to make .o files from .s files
#
$(BUILDDIR)/%.o: %.s
	$(AS)  $(INC) $(AFLAGS) -o $@ $<


#
# default target
#
all: IMAGE


#
# Target to build a rasberry pi 4 boot disk image with the null kernela and null armstub
#
IMAGE: DIRECTORIES $(BUILDDIR)/startup.bin $(BUILDDIR)/null_kernel.bin
	$(CP) config.txt $(IMAGEDIR)
	$(CP) $(BCMBINS)/start4.elf $(IMAGEDIR) 
	$(CP) $(BCMBINS)/fixup4.dat $(IMAGEDIR) 
	$(CP) $(BUILDDIR)/null_kernel.bin $(IMAGEDIR)
	$(CP) $(BUILDDIR)/startup.bin $(IMAGEDIR) 


DIRECTORIES: $(BUILDDIR) $(IMAGEDIR)
	

$(BUILDDIR)/startup.bin: DIRECTORIES $(BUILDDIR)/startup.o
	$(OBJCOPY) -O binary $(BUILDDIR)/startup.o $(BUILDDIR)/startup.bin
		

$(BUILDDIR)/null_kernel.bin: DIRECTORIES $(BUILDDIR)/null_kernel.o
	$(OBJCOPY) -O binary $(BUILDDIR)/null_kernel.o $(BUILDDIR)/null_kernel.bin

clean:
	$(RMDIR) $(BUILDDIR)	
	$(RMDIR) $(IMAGEDIR)


$(BUILDDIR): 
	$(MKDIR) $(BUILDDIR)


$(IMAGEDIR):
	$(MKDIR) $(IMAGEDIR)


