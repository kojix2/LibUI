# libui shared library for M1 Mac

libui.dylib for Mac has been replaced with a universal binary to make LibUI compatible with M1 Mac.

See https://github.com/kojix2/LibUI/issues/47

The LibUI gem also includes libui.so for Linux and libui.dll for Windows, which are identical to the official binaries distributed by andlabs.

## Target libui version

libui version alpha 4.1
https://github.com/andlabs/libui

## Universal binary

file command to show that it is a universal binary.

```
file libui.dylib
# libui.dylib: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit dynamically linked shared library x86_64] [arm64:Mach-O 64-bit dynamically linked shared library arm64]
# libui.dylib (for architecture x86_64):	Mach-O 64-bit dynamically linked shared library x86_64
# libui.dylib (for architecture arm64):	Mach-O 64-bit dynamically linked shared library arm64
```

## sha256sum

```
6da2ff5acb6fba09b47eae0219b3aaefd002ace00003ab5d59689e396bcefff7  libui.dylib
```

## Build method

1. Get the libui version alpha 4.1 and create a shared library for arm64 on M1 mac. 
2. Download the official shared library provided by [andlabs](https://github.com/andlabs/libui/releases/tag/alpha4.1).
3. Use the lipo command to merge the two files to create a universal binary.

## Contributing

libui-ng is looking for a way to create a binary file for the M1 Mac.
See https://github.com/libui-ng/libui-ng/issues/41

## License

MIT

