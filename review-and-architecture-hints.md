# Review and architecture hints: Horizon for SailfishOS

For anyone reviewing the `sailfishos` branch: where the code comes from, how it is laid out, what is worth reading and what is boilerplate.

## Where the code comes from

The app is the AsteroidOS watch app on `main`. This branch forks from it at `3339b36`, and its commits are the SailfishOS port. The reliable view of what the port changed:

    git diff 3339b36 sailfishos -- qml src rpm '*.pro' '*.desktop'

Many port edits carry a `SailfishOS:` comment, but not all of them. Each commit message says what changed, why, and what was not checked, and ends with an LLMGD line grading it.

The port was written by an LLM (Claude), directed and tested by the author, who has not read the code. Everything here is a prototype until a reviewer owns it. That is the point of this file.

## Architecture

- `qml/harbour-asteroid-horizon.qml`: the Silica `ApplicationWindow`. It sizes `Dims` from the screen width, then loads the app (`game/main.qml`). When the app goes to the background, the same item is moved into the cover and scaled down, so the home screen tile shows it live. The same shell is used in all eight ports.
- `qml/game/Dims.qml`, `Label.qml`, `HighlightBar.qml`, `Icon.qml`, `PageHeader.qml`, `ValueCycler.qml`, `IntSelector.qml`, `DeviceSpecs.qml` (whichever exist here): small stand-ins for AsteroidOS's `org.asteroid.controls` and `org.asteroid.utils`, so the watch QML runs unchanged where possible. Each is a few dozen lines.
- `qml/game/main.qml`: the app frame, the brightness (as in Pulsar) and the camera view: a `Camera` and a `VideoOutput` underneath the level's background, which fades out in horizon mode.
- `qml/game/LevelPage.qml` (about 500 lines): accelerometer smoothing, pitch and roll, the user zero, freeze, the axis locks, the range selector, and horizon mode (on above 60° of pitch, off below 50°).
- Packaging: pure QML, no binary. `Exec=sailfish-qml harbour-asteroid-horizon` (package `libsailfishapp-launcher`), the `.pro` is `TEMPLATE = aux` with plain `INSTALLS`, and the spec is `BuildArch: noarch` with an xz payload (rpm 4.14 on SailfishOS 3.4 can not unpack the zstd of newer SDKs).

## Read these first

1. `LevelPage.qml`, the angle maths (`pitch`, `roll`, `horizonRoll`) and the smoothing factor.
2. The camera in `main.qml`. It runs whenever the app is active, so the switch to horizon mode is instant; it is unloaded in the background. The `VideoOutput` uses no rotation, matching the stock camera app (`/usr/share/jolla-camera/camera.qml`).

## Skim

Stand-ins, icons, packaging.

## Worth questioning

- While the camera runs, SailfishOS pauses other audio (music in the browser, for example), even when the picture is not shown. The cost of instant switching is noted in the release text.
- `debugMode: true` in `LevelPage.qml` logs every accelerometer reading (30 per second) to the journal. It was inherited from the watch version.
- The brightness is restored only on a clean exit (as in Pulsar). `org.nemomobile.systemsettings` keeps it out of the Jolla Store.
- Permissions: `Sensors;Camera`. Camera alone would cover the sensors; both are listed for clarity.

## How it was tested

By the author, by playing it on a Jolla C2 (SailfishOS 5.1), the Jolla Tablet (4.6, x86) and a Jolla 1 (3.4, 32-bit ARM), with the same noarch package on all three. Before each handover, the LLM checked builds, package contents and start logs on those devices.

There are no automated tests; the on-device checks are listed in the commit messages.
