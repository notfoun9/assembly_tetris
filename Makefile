EXECUTABLES_PATH="$(shell pwd)/executables"
export EXECUTABLES_PATH

OBJECTS_PATH="$(shell pwd)/objects"
export OBJECTS_PATH

EXAMPLES_PATH="$(shell pwd)/examples"
export EXAMPLES_PATH

UTILS_PATH="$(shell pwd)/utils"
ASFLAGS := "-I$(UTILS_PATH)"

MACROS_PATH="$(shell pwd)/macros"
ASFLAGS += "-I$(MACROS_PATH)" 
export ASFLAGS

all: colors pieces grid positions utils shadow main

main: main.s
	@as $(ASFLAGS) -g -o $(OBJECTS_PATH)/$@.o $<
	@ld -o $(EXECUTABLES_PATH)/$@   \
		$(OBJECTS_PATH)/pieces.o    \
		$(OBJECTS_PATH)/grid.o      \
		$(OBJECTS_PATH)/shadow.o    \
		$(OBJECTS_PATH)/positions.o \
		$(OBJECTS_PATH)/colors.o    \
		$(OBJECTS_PATH)/utils.o     \
		$(OBJECTS_PATH)/iomanip.o   \
		$(OBJECTS_PATH)/$@.o

grid: grid.s
	@as $(ASFLAGS) -g -o $(OBJECTS_PATH)/$@.o $<

pieces: pieces.s
	@as $(ASFLAGS) -g -o $(OBJECTS_PATH)/$@.o $<

positions: positions.s
	@as $(ASFLAGS) -g -o $(OBJECTS_PATH)/$@.o $<

colors: colors.s
	@as $(ASFLAGS) -g -o $(OBJECTS_PATH)/$@.o $<

shadow: shadow.s
	@as $(ASFLAGS) -g -o $(OBJECTS_PATH)/$@.o $<

.PHONY: utils
utils:
	@$(MAKE) --no-print-directory -C $(UTILS_PATH)

.PHONY: examples
examples:
	@$(MAKE) --no-print-directory -C $(EXAMPLES_PATH) all

