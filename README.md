# Super Super Dodgeball
A native SNES port of the NES game Super Dodgeball.

# Generating the needed files

For copyright reasons I am not supplying any of the CHR ROM bytes.  There's a go script included in the `utilities/` directory that will extract the needed `.asm` files from a headered Super Dodge Ball rom with an md5 hash of `9c819e679f5fab4ef836761d31e98adc`.

Simply run:

` go run parseNesFileToBanks.go -in=Super\ Dodge\ Ball\ \(U\).nes`

And 16 `.asm` files will be generated.  You can ignore the bankx.asm ones.  Copy the 8 `chrom-tiles-X.asm` to the `/src` directory.

# Building

## Prerequisites

* cc65 - the 65c816 compiler and linker, available [here](https://www.cc65.org/)
* [go](https://go.dev/) - in order to generate the chr rom files