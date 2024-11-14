# Podéis usar este Makefile como referencia. Vuestro codigo debe poderse 
# compilar con GCC usando los flags que ya estan especificados en CFLAGS.
# Podéis experimentar con la variable OPT para añadir opciones adicionales.

CC = gcc 
OPT = -mcpu=cortex-a7 -mtune=cortex-a7 -mfloat-abi=hard -mfpu=neon-vfpv4 -funsafe-math-optimizations -O3 -fopenmp
CFLAGS = -Wall -std=gnu99 $(OPT)
LDFLAGS = -Wall
LDLIBS = -fopenmp

targets = benchmark
objects = benchmark.o dgemm.o
ass_obj = benchmark.s dgemm.s

.PHONY : default
default : all

.PHONY : all
all : clean $(objects) benchmark

benchmark : benchmark.o dgemm.o
	$(CC) -o $@ $^ $(LDLIBS)

%.o : %.c
	$(CC) -c $(CFLAGS) $<

.PHONY : ensambla
ensambla: clean $(ass_obj) all

%.s : %.c
	$(CC) -S $(CFLAGS) $<

.PHONY : clean
clean:
	rm -f $(targets) $(objects) $(ass_obj)

