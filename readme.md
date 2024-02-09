# libteak

## 1. Introduction

This is a library to help develop applications for the DSP that comes with the
DSi and 3DS consoles. It is provided as part of
[BlocksDS](https://github.com/blocksds/sdk), but it can also be used as a
standalone library.

- [Documentation](https://blocksds.github.io/docs/libteak/index.html)
- [Examples](https://github.com/blocksds/sdk/tree/master/examples/dsp)

## 2. Setup

The Teak toolchain is currently only distributed by
[Wonderful Toolchain](https://wonderful.asie.pl). You will need to install the
Teak toolchain of Wonderful Toolchains. Follow the instructions in this link:
https://wonderful.asie.pl/docs/getting-started/

Note that the Teak toolchain is currently only available on Linux, not Windows.

Now, install the Teak toolchain of Wonderful Toolchains:

```bash
wf-pacman -Syu
wf-pacman -S toolchain-llvm-teak-llvm
```

Finally, build the library:

```bash
make
```
