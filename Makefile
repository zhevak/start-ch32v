TARGET = start-ch32v

OPT = -O0


SOURCE_DIR = ./source
BUILD_DIR = build


C_SOURCES = \
system.c \
main.c \
leds.c


OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCE_DIR)/$(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(SOURCE_DIR)/$(C_SOURCES)))

ASM_SOURCES = CH32V_firmware_library/Startup/startup_ch32v00x.S
LDSCRIPT = link.ld


RISCV_DIR = $(HOME)/bin/MRS_Toolchain_Linux_x64_V1.70/RISC-V\ Embedded\ GCC/bin
OPENOCD_DIR = $(HOME)/bin/MRS_Toolchain_Linux_x64_V1.70/OpenOCD/bin

CC = $(RISCV_DIR)/riscv-none-embed-gcc
AS = $(RISCV_DIR)/riscv-none-embed-gcc -x assembler-with-cpp
CP = $(RISCV_DIR)/riscv-none-embed-objcopy
SZ = $(RISCV_DIR)/riscv-none-embed-size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S


# For gcc v12 and above
# CPU = -march=rv32imac_zicsr -mabi=ilp32 -msmall-data-limit=8
CPU = -march=rv32ec -mabi=ilp32e -msmall-data-limit=8

MCU = $(CPU) $(FPU) $(FLOAT-ABI)

AS_INCLUDES =

C_INCLUDES = -I. -Isource

ASFLAGS = $(MCU) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections
CFLAGS = $(MCU) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


LIBS = -lc -lm -lnosys
LIBDIR =
LDFLAGS = $(MCU) -mno-save-restore -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wunused -Wuninitialized -T $(LDSCRIPT) -nostartfiles -Xlinker --gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map --specs=nano.specs $(LIBS)

####################################################################################################
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

#OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
#vpath %.c $(sort $(dir $(C_SOURCES)))

# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@$(BIN) $< $@

$(BUILD_DIR):
	mkdir $@


####################################################################################################
load: $(BUILD_DIR)/$(TARGET).elf
	$(OPENOCD_DIR)/openocd -f $(OPENOCD_DIR)/wch-riscv.cfg -c 'init; halt; program $(BUILD_DIR)/$(TARGET).hex verify; reset; wlink_reset_resume; exit;'

# program: $(BUILD_DIR)/$(TARGET).elf
#	sudo wch-openocd -f /usr/share/wch-openocd/openocd/scripts/interface/wch-riscv.cfg -c 'init; halt; program $(BUILD_DIR)/$(TARGET).elf verify; reset; wlink_reset_resume; exit;'

# isp: $(BUILD_DIR)/$(TARGET).bin
#	wchisp flash $(BUILD_DIR)/$(TARGET).bin


clean:
	@rm    $(BUILD_DIR)/*
	@rmdir $(BUILD_DIR)


####################################################################################################
# dependencies
-include $(wildcard $(BUILD_DIR)/*.d)

