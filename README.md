![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Solo Squash VGA Game demo project on Tiny Tapeout IHP 0.2

> [!NOTE]
> This is a fork of the experimental [ttihp-verilog-template](https://github.com/TinyTapeout/ttihp-verilog-template) targeting ttihp0p2. See that template repo for instructions on how to use it.

This is an experimental submission of my basic solo_squash VGA game as submitted to TT03p5. It resembles Pong, but just for 1 player.

![Solo Squash VGA game running on an FPGA](./docs/solo-squash-fpga.jpg)

- [Read the documentation for project](docs/info.md)

> [!NOTE]
> This uses git submodules, so when you clone it, you should do so with `--recurse-submodules` or otherwise do `git submodule init` afterwards. Use `git submodule` to list.

> [!NOTE]
> I have an original [comprehensive testing guide](https://github.com/algofoogle/tt03p5-solo-squash/blob/main/doc/testing.md) for the TT03p5 version of the submission, which should mostly be the same for this version, but I should hopefully have changed the pinout to be TinyVGA compatible by the time I'm finished. Also, actual MicroPython firmware for the demo board might end up being different.

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

