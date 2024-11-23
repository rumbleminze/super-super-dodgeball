# Super Super Dodgeball
A native SNES port of the NES game Super Dodgeball.

# Generating the needed files

For copyright reasons I am not supplying any of the CHR ROM bytes.  There's a go script included in the `utilities/` directory that will extract the needed `.asm` files from a headered Super Dodge Ball rom with an md5 hash of `9c819e679f5fab4ef836761d31e98adc`.

Simply run:

` go run parseNesFileToBanks.go -in=Super\ Dodge\ Ball\ \(U\).nes`

And 16 `.asm` files will be generated.  You can ignore the bankx.asm ones.  Copy the 8 `chrom-tiles-X.asm` to the `/src` directory.

# Building

## Prerequisites

* [cc65](https://www.cc65.org/) - the 65c816 compiler and linker
* [go](https://go.dev/) - in order to generate the chr rom files


## Other Userful Tools I've used for this project

* [Mesen2](https://github.com/SourMesen/Mesen2) - A fantastic emulator for development on a bunch of platforms
* [HxD](https://mh-nexus.de/en/hxd/) - A Hex Editor
* [Visual Studio Code](https://code.visualstudio.com/) - Used as the development environment

## Structure of the Project

* `bankX.asm` - The NES memory PRG banks, there are 8 of them.  This code is heavily edited/altered for the port  
* `chrom-tiles-X.asm` - The NES CHR ROM banks, also 8 of them. These are untouched aside from converting them to the SNES tile format that we use.  The go script takes care of that for you.
* `2a03_xxxxx.asm` - Sound emulation related code
* `bank-snes.asm` - All the code that runs in the `A0` bank, this is where we put most of our routines and logic that we need that is SNES specific.  Also includes various included asm files:

  * `attributes.asm` - dealing with tile and sprite attributes
  * `hardware-status-switches.asm` - various useful methods to handle differences in hardware registers
  * `hud-hdma.asm` - HDMA logic for the player health bars and names to be shown
  * `intro_screen.asm` - Title card that is shown at the start of the game
  * `palette_lookup.asm` and `palette_updates.asm` - palette logic
  * `sprites.asm` - sprite conversion and DMA'ing

* `main.asm` - the main file, root for the project
* `vars.inc`, `registers.inc`, `macros.inc` - helpful includes
* `resetvector.asm` - the reset vector code
* `hirom.cfg` - defines how our ROM is laid out, where each bank lives and how large they are

## Building

* Update the `build.sh` file with the location of your cc65 install
* make sure you've extracted and copied the chr rom banks to `/src`
* run `build.sh`
* The output will be in `out/`
