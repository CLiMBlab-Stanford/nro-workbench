# nro Workbench runtime

This repository builds the Connectome Workbench runtime used by nro for native
scene viewing and headless rendering. The image contains Workbench's Linux GUI,
Qt runtime, Mesa software renderer, X11 client libraries, fonts, and the
corresponding Workbench source archive.

The image does not contain study data. Bind project paths into the container at
their original absolute locations so paths stored in Workbench scenes continue
to resolve.

## Images

Release tags publish Linux x86-64 images to:

```text
ghcr.io/climblab-stanford/nro-workbench:VERSION
```

Production consumers should select the image by OCI digest rather than by its
mutable tag.

## Display forwarding

The image defaults to Mesa software rendering. For an SSH-forwarded display,
pass the current `DISPLAY` value and mount a readable Xauthority file. Local
Unix-socket displays additionally need `/tmp/.X11-unix` mounted into the
container. nro supplies these arguments through its viewer broker.

Example:

```bash
apptainer exec --cleanenv \
  --env DISPLAY="$DISPLAY",XAUTHORITY=/run/nro/xauthority \
  --bind "$XAUTHORITY:/run/nro/xauthority:ro" \
  --bind /data:/data \
  workbench.sif \
  wb_view /data/example.scene
```

## Upstream software and source

The image uses the official Connectome Workbench 2.2.1 Linux archive and
includes the corresponding source revision under `/usr/share/source`. The
archive checksum and source revision are declared in `Containerfile`.

Connectome Workbench is developed by Washington University School of Medicine:

- <https://github.com/Washington-University/workbench>
- <https://www.humanconnectome.org/software/get-connectome-workbench>

Workbench's source repository documents the licenses that apply to Workbench
and its bundled third-party components. The resulting executables include
GPLv3-or-later code.
