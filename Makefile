
GHDL = ghdl
FLAGS = --std=08
WORKDIR = work
STOP_TIME = 20us

# Files
FILES = uart_tx.vhd uart_rx.vhd uart_tb.vhd
SIM_TOP = uart_tb
WAVE_FILE = wave.vcd

# Targets
all: clean compile run view

compile:
	@echo Analyzing files...
	$(GHDL) -a $(FLAGS) $(FILES)
	@echo Elaborating design...
	$(GHDL) -e $(FLAGS) $(SIM_TOP)

run:
	@echo Running simulation...
	$(GHDL) -r $(FLAGS) $(SIM_TOP) --vcd=$(WAVE_FILE) --stop-time=$(STOP_TIME)

view:
	@echo Opening waveform...
	gtkwave $(WAVE_FILE)

clean:
	@echo Cleaning up...
	$(GHDL) --clean
	@if exist $(WAVE_FILE) del /q $(WAVE_FILE)
	@if exist work-obj08.cf del /q work-obj08.cf
