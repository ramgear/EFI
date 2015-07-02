##############################################################################
PROJECT			= EFI
VERSION			= 1
SUBLEVEL		= 0
PATCHLEVEL		= 0

TARGETBOARD		?= STM32F4_DISCOVERY
PROJECTPATH		?= .
FILEVERSION = $(PROJECT)-$(TARGETBOARD)-$(VERSION).$(SUBLEVEL).$(PATCHLEVEL)

# Directories define
BUILDDIR	?= $(PROJECTPATH)/build
OBJDIR		= $(BUILDDIR)/obj
LSTDIR		= $(BUILDDIR)/lst
CMSISDIR	?= $(PROJECTPATH)/cmsis
STM32HALDIR	?= $(PROJECTPATH)/hal
LIBDIR		= $(PROJECTPATH)/lib
LDPATH		?= $(PROJECTPATH)/ldscripts
SYSDIR		= $(PROJECTPATH)/system
##############################################################################

# Configurations
USE_RTOS	?= n

# import application source
-include $(PROJECTPATH)/sources.mk

ifeq ($(USE_RTOS),y)
-include $(PROJECTPATH)/rtos.mk
endif

# Ststem Source code
ASRCS	:= 

CSRCS	+= 	$(wildcard ${CMSISDIR}/Device/ST/STM32F4xx/Source/*.c) \
			$(wildcard ${STM32HALDIR}/Src/*.c) \
			$(wildcard ${LIBDIR}/Src/*.c) \
			$(wildcard ${SYSDIR}/src/newlib/*.c) \
			$(wildcard ${SYSDIR}/src/cortexm/*.c) \
			$(wildcard ${SYSDIR}/src/diag/*.c) \
			$(wildcard ${SYSDIR}/src/cmsis/*.c)
	
CPPSRCS	+= 	$(wildcard ${LIBDIR}/Src/*.cpp) \
			$(wildcard ${SYSDIR}/src/newlib/*.cpp)

INCPATH	+= 	$(CMSISDIR)/Include \
			$(CMSISDIR)/Device/ST/STM32F4xx/Include \
			$(STM32HALDIR)/Inc \
			$(LIBDIR)/Inc \
			$(SYSDIR)/include/arm \
			$(SYSDIR)/include/cortexm \
			$(SYSDIR)/include/diag

DEFS	+= -DDEBUG -DUSE_FULL_ASSERT -DTRACE -DOS_USE_TRACE_SEMIHOSTING_DEBUG -DUSE_HAL_DRIVER

CROSS_COMPILE ?= arm-none-eabi-
CC   = $(CROSS_COMPILE)gcc
CPPC = $(CROSS_COMPILE)g++
LD   = $(CROSS_COMPILE)g++
CP   = $(CROSS_COMPILE)objcopy
AS   = $(CROSS_COMPILE)gcc -x assembler-with-cpp
OD   = $(CROSS_COMPILE)objdump
SZ   = $(CROSS_COMPILE)size
HEX  = $(CP) -O ihex
BIN  = $(CP) -O binary

# Flags
MCUFLAGS	= -mcpu=cortex-m4 -mthumb -mfloat-abi=softfp -mfpu=fpv4-sp-d16
AFLAGS		= $(MCUFLAGS)
CFLAGS 		= $(MCUFLAGS) -O2 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -ffreestanding -fno-move-loop-invariants -Wall -Wextra  -g3
CPPFLAGS	= $(CFLAGS) -fno-exceptions -fno-rtti -fno-use-cxa-atexit -fno-threadsafe-statics
LDFLAGS		= -nostartfiles -Xlinker --gc-sections
LDFLAGS		+= -L"$(LDPATH)" -Wl,-Map,"$(BUILDDIR)/$(FILEVERSION).map" --specs=nano.specs

CFLAGS		+= -Wa,-alms=$(LSTDIR)/$(notdir $(<:.c=.lst))
CPPFLAGS	+= -Wa,-alms=$(LSTDIR)/$(notdir $(<:.cpp=.lst))

# Make targets
OUTFILES = $(BUILDDIR)/$(FILEVERSION).elf $(BUILDDIR)/$(FILEVERSION).bin $(BUILDDIR)/$(FILEVERSION).hex $(BUILDDIR)/$(FILEVERSION).siz

# Objects
_AOBJS		= $(addprefix $(OBJDIR)/, $(notdir $(ASRCS:.s=.o)))
_COBJS		= $(addprefix $(OBJDIR)/, $(notdir $(CSRCS:.c=.o)))
_CPPOBJS	= $(addprefix $(OBJDIR)/, $(notdir $(CPPSRCS:.cpp=.o)))
OBJS		= $(_AOBJS) $(_COBJS) $(_CPPOBJS)

INCPATHS   = $(patsubst %,-I%,$(INCPATH))

# Paths where to search for sources
SRCPATHS  = $(sort $(dir $(ASRCS)) $(dir $(CSRCS)) $(dir $(CPPSRCS)))
VPATH     = $(SRCPATHS)

MD 	:= mkdir
RM 	:= rm
VB	:= @
ST_LINK_CLI	?= ST-LINK_CLI
STL	:= $(ST_LINK_CLI)

AFLAGS		+= -MD -MP -MF .dep/$(@F).d
CFLAGS		+= -MD -MP -MF .dep/$(@F).d
CPPFLAGS	+= -MD -MP -MF .dep/$(@F).d

# Make rules
.PHONY: all clean install

all: prepare $(OUTFILES)

prepare:
	@echo C++ Compiler flags
	@echo $(CPPFLAGS)
	@echo
	@echo Loader flags
	@echo $(LDFLAGS)
	@echo

	$(MD) -p $(BUILDDIR)
	$(MD) -p $(OBJDIR)
	$(MD) -p $(LSTDIR)
	
	@echo
	
# Make ASM Files
$(_AOBJS): $(OBJDIR)/%.o : %.s Makefile
	@echo Compiling $< to $@
	$(VB)$(AS) -c $(AFLAGS) $(DEFS) -T. $(INCPATHS) $< -o $@
	
# Make C Files
$(_COBJS): $(OBJDIR)/%.o : %.c Makefile
	@echo Compiling $< to $@
	$(VB)$(CC) -c $(CFLAGS) $(DEFS) -T. $(INCPATHS) -std=gnu11 $< -o $@
	
# Make CPP Files
$(_CPPOBJS): $(OBJDIR)/%.o : %.cpp Makefile
	@echo Compiling $< to $@
	$(VB)$(CPPC) -c $(CPPFLAGS) $(DEFS) -I. $(INCPATHS) -std=gnu++11 $< -o $@
	

$(BUILDDIR)/$(FILEVERSION).elf: $(OBJS)
	$(VB)$(CPPC) $(CPPFLAGS) -T libs.ld -T mem.ld -T sections.ld $(LDFLAGS) -o "$(BUILDDIR)/$(FILEVERSION).elf" $(OBJS) $(LIBS)

$(BUILDDIR)/$(FILEVERSION).bin: $(BUILDDIR)/$(FILEVERSION).elf
	@echo
	@echo ---------------------------------------------------
	@echo Creating $@
	$(VB)$(BIN) $< $@
	@echo ---------------------------------------------------
	@echo

$(BUILDDIR)/$(FILEVERSION).hex: $(BUILDDIR)/$(FILEVERSION).elf
	@echo
	@echo ---------------------------------------------------
	@echo Creating $@
	$(VB)$(HEX) $< $@
	@echo ---------------------------------------------------
	@echo

$(BUILDDIR)/$(FILEVERSION).siz: $(BUILDDIR)/$(FILEVERSION).elf
	@echo
	@echo ---------------------------------------------------
	$(VB)$(SZ) --format=berkeley "$(BUILDDIR)/$(FILEVERSION).elf"
	@echo ---------------------------------------------------
	@echo

clean:
	@echo Cleaning
	$(RM) -fR .dep $(BUILDDIR)
	@echo
	@echo Done
	
install:
	@echo Installing "$(BUILDDIR)/$(FILEVERSION).bin"
	-$(STL) -c SWD ur -P $(BUILDDIR)/$(FILEVERSION).bin 0x08000000 -Rst -Run
	@echo
	@echo Done

#
# Include the dependency files, should be the last of the makefile
#
-include $(shell mkdir .dep 2>/dev/null) $(wildcard .dep/*)

# *** EOF ***
