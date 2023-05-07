TARGET_EXEC := ./build/chibiTest
# MAIN := ./main.cpp
# blink led program
MAIN := ./main-test.cpp

# Directory
BUILD_DIR 		:= ./build
CHIBIOS_DIR		:= ./ChibiOS
CHRT_DIR		:= $(CHIBIOS_DIR)/ChRt
TEENSY_CORES 	:= $(CHIBIOS_DIR)/arduino/hardware/teensy/avr/cores/teensy4
NANO_CORES		:= $(CHIBIOS_DIR)/arduino/hardware

TOOLS_PATH		:= $(CHIBIOS_DIR)/arduino/hardware/tools
LIBRARY_PATH 	:= $(CHIBIOS_DIR)/arduino/libraries

# Source Files and Headers
#	find C and C++ files
# $(shell find $(CHIBIOS_DIR) -name '*.cpp' -or -name '*.c' -or -name '*.s')'
# btw u can use wilcard
SRCS := $(shell find $(TEENSY_CORES) -name '*.cpp' -or -name '*.c' -or -name '*.s')	\
		$(shell find $(CHRT_DIR) -name '*.cpp' -or -name '*.c' -or -name '*.s')	\
		$(MAIN)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
SPECS = --specs=nano.specs

#	find header files
# $(shell find $(CHIBIOS_DIR) -type d)
INC_DIRS := $(shell find $(TEENSY_CORES) -type d)	\
			$(shell find $(CHRT_DIR) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# Teensy 41
MCU := IMXRT1062
MCU_LD := $(TEENSY_CORES)/imxrt1062_t41.ld
MCU_BOARD := ARDUINO_TEENSY41

# Arduino Nano

# Options
OPT = -DF_CPU=600000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH -DUSING_MAKEFILE
OPT += -D__$(MCU)__ -DARDUINO=10813 -DTEENSYDUINO=154 -D$(MCU_BOARD)
CPU_OPT = -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb

# Flags
CPPFLAGS = -Wall -g -O2 $(CPU_OPT) -MMD $(OPT) -I. -ffunction-sections -fdata-sections
CXXFLAGS = -std=gnu++14 -felide-constructors -fno-exceptions -fpermissive -fno-rtti -Wno-error=narrowing
CFLAGS =
LDFLAGS = -Os -Wl,--gc-sections,--relax $(SPECS) $(CPU_OPT) -T$(MCU_LD)
# LIBS = -larm_cortexM7lfsp_math -lm -lstdc++
LIBS = -lm

COMPILER_PATH := $(TOOLS_PATH)/arm/bin
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# Rules
flash: $(TARGET_EXEC).hex
	teensy_loader_cli -mmcu=imxrt1062 -w -v $<

teensy41: $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET_EXEC).elf $(OBJS) $(LIBS)
	$(SIZE) $(TARGET_EXEC).elf
	$(OBJCOPY) -O ihex -R .eeprom $(TARGET_EXEC).elf $(TARGET_EXEC).hex

$(BUILD_DIR)/%.c.o:%.c
	@mkdir -p $(dir $@)
	@$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -o $@ -c $<

$(BUILD_DIR)/%.cpp.o:%.cpp
	@mkdir -p $(dir $@)
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INC_FLAGS) -o $@ -c $<

#$(BUILD_DIR)/%.S.o:%.S
#	mkdir -p $(dir $@)
#	$(CC) $(ASSFLAGS) $< -o $@

# this is important
-include $(DEPS)

clean:
	rm -rf ./build

test0: 
	@echo "Check All Sources Files and Headers : "
	@ls $(SRCS)
	@echo $(INC_FLAGS)
	@echo $(SRCS) > ./test/sources_list.txt
	@echo $(INC_FLAGS) > ./test/lib_list.txt

test1: $(OBJS)
	@echo $(OBJS) > object_files.txt
	@echo OK

# test2: 
# 	$(CC) $(LDFLAGS) -o ./build/a.hex $(OBJS) $(LIBS)
# 	@echo OK

# flash prep
# %.hex: %.elf
# 	$(SIZE) $<
# 	$(OBJCOPY) -O ihex -R .eeprom $< $@
# ifneq (,$(wildcard $(TOOLS_PATH)))
# 	$(TOOLS_PATH)/teensy_post_compile -file=$(basename $@) -path=$(shell pwd) -tools=$(TOOLS_PATH)
# 	-$(TOOLS_PATH)/teensy_reboot
# # endif

# makefile template : https://makefiletutorial.com/#makefile-cookbook
# other reference : https://github.com/apmorton/teensy-template/blob/master/Makefile
