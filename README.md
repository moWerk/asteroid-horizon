# asteroid-horizon

A precision spirit level and angle meter for [AsteroidOS](http://asteroidos.org/)

## Dot Mode

Hold your watch face-up to use the 2D spirit level. A crosshair scale shows
±5° to ±30° depending on the selected range, and a dot moves to represent the
current tilt across both axes simultaneously.

- **X axis label** (left, rotated) shows left/right tilt in degrees
- **Y axis label** (top) shows forward/back tilt in degrees
- **Axis locks** (right and bottom scale ends) constrain the dot to a single
  axis — useful for precise single-plane leveling. The active lock highlights
  with a green background and the current value follows the dot.
- **Snowflake ❄** (top-left) freezes all readings and the dot in place.
  Tap again to release. Horizon mode is blocked while frozen.
- **Range selector** (bottom-right) cycles the scale between ±5°, ±10°,
  ±15°, ±20°, and ±30°. Tick density adjusts automatically — 1° steps at
  ±5°, 2° steps at ±10°, 5° steps at wider ranges.
- **Tap the dot** to set the current orientation as zero. All values then
  show as delta from that reference and the dot turns red. Tap again to
  return to absolute mode. Horizon mode is blocked in delta mode.

## Horizon Mode

Tilt the watch past 60° and the display automatically switches to a rotating
horizon line showing roll angle. The scale rotates to stay aligned with
gravity. Tap the horizon line to return to dot mode by tilting back flat.

## Tips

- For water-scale precision, set the range to ±5°. A physical bubble level
  typically only indicates ±3°.
- Use delta mode to measure relative angles — place the watch on a reference
  surface, tap the dot to zero, then move to the surface you want to compare.
- Axis locks work in delta mode for single-plane relative measurements.
