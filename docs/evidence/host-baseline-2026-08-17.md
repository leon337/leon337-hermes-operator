# Host Baseline — 2026-08-17

Source: read-only terminal diagnostics executed by LEANDRO on the target computer. This file stores only a sanitized summary, not raw screenshots or sensitive desktop content.

## System

- Distribution: Linux Mint 22.3 `Zena`
- Kernel: Linux 6.14.0-37-generic
- Architecture: x86_64
- Desktop: XFCE
- Session type: X11
- Display: `:0.0`

## CPU

- Intel Core i7-2670QM @ 2.20GHz
- 4 physical cores / 8 logical CPUs

## Memory observed

- Total RAM: ~7.7 GiB
- Available during diagnostic: ~1.2 GiB
- Swap: ~2.0 GiB

## Graphics

Detected hardware:

- Intel 2nd Generation Core Processor Family Integrated Graphics
- NVIDIA GF108M — GeForce GT 620M/630M/635M/640M LE family

Observed active graphics state:

- Intel kernel driver: `i915`
- NVIDIA/Nouveau kernel modules: not loaded in diagnostic
- `nvidia-smi`: not available
- X11 providers: one `modesetting` provider
- PRIME selector: not available
- OpenGL vendor: Intel
- OpenGL renderer: Mesa Intel HD Graphics 3000 (SNB GT2)

Conclusion: the NVIDIA GPU is physically present, but **not proven active or usable** in the current graphics stack. Current OpenGL rendering is on Intel HD Graphics 3000.

## Applications

- Brave: `/usr/bin/brave-browser`
- Xed: `/usr/bin/xed`

## Hermes

- Hermes executable: not installed/found at diagnostic time.

## Technical implications

- X11 is favorable for Linux GUI automation paths that rely on X11/AT-SPI/XTest.
- Hardware is resource-constrained for heavy local multimodal models; do not assume local inference viability without dedicated measurement.
- Do not modify NVIDIA drivers as part of reconnaissance; any driver change requires separate analysis and explicit human gate.
