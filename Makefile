.PHONY: build clean test install uninstall doc format

build:
	dune build @install

test:
	dune runtest

install:
	dune install

uninstall:
	dune uninstall

clean:
	dune clean

doc:
	dune build @doc

format:
	-dune build @fmt
	dune promote
