GCC_ROOT = riscv64-linux-gnu-

CC = $(GCC_ROOT)gcc
QEMU_USER = qemu-riscv64

CAL_OBJ = cal.o

cal: $(CAL_OBJ)
	$(CC) -static -o cal $(CAL_OBJ)

all: cal examples

examples: hello hello2 main

hello: hello.o
	$(CC) -static -o hello hello.o

run-hello: hello
	@$(QEMU_USER) hello

hello2: hello2.o
	$(CC) -static -o hello2 hello2.o

run-hello2: hello2
	@$(QEMU_USER) hello2

main: main.o
	$(CC) -static -o main main.o

run-main: main
	$(QEMU_USER) main

clean:
	rm -f hello hello.o
	rm -f hello2 hello2.o
	rm -f main main.o
	rm -f cal $(CAL_OBJ)

%.s: %.c
	$(CC) -S -fpic -c $<

%.o: %.s
	$(CC) -fpic -c $<
	
%.o: %.c
	$(CC) -fpic -c $<

