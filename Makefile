all: itoa input sleep count stack

itoa: itoa.s
	@as -o itoa.o itoa.s
	@ld -o executables/itoa itoa.o
	@rm itoa.o

input: input.s
	@as -o input.o input.s
	@ld -o executables/input input.o
	@rm input.o

sleep: sleep.s
	@as -g -o sleep.o sleep.s
	@ld -o executables/sleep sleep.o
	@rm sleep.o

count: count.s
	@as -g -o count.o count.s
	@ld -o executables/count count.o
	@rm count.o

stack: stack.s
	@as -g -o stack.o stack.s
	@ld -o executables/stack stack.o
	@rm stack.o
