# asteroid-horizon

A precision spirit level and angle meter for [AsteroidOS](http://asteroidos.org/)

## Dot Mode

Hold your watch face-up to use the 2D spirit level. A crosshair scale shows
±5° to ±30° depending on the selected range, and a dot moves to represent the
current tilt across both axes simultaneously.

- **X axis label** (left, rotated) shows left/right tilt in degrees
- **Y axis label** (top) shows forward/back tilt in degrees

![shot-horizon1](https://github.com/user-attachments/assets/475edaaf-b009-463e-acd3-43880ca01896)

- **Axis locks** (right and bottom scale ends) constrain the dot to a single
  axis — useful for precise single-plane leveling. The active lock highlights
  with a green background and the current value follows the dot.
  
  ![shot-horizon3](https://github.com/user-attachments/assets/f8fc9f23-795b-49c8-a69e-d29ab53d7c8c)
  
- **Range selector** (bottom-right) cycles the scale between ±5°, ±10°,
  ±15°, ±20°, and ±30°. Tick density adjusts automatically — 1° steps at
  ±5°, 2° steps at ±10°, 5° steps at wider ranges.
  
  ![shot-horizon2](https://github.com/user-attachments/assets/f2406699-17d9-402c-9042-c5f95a1dd13a)

- **Tap the dot** to set the current orientation as zero. All values then
  show as delta from that reference and the dot turns red. Tap again to
  return to absolute mode. Horizon mode is blocked in delta mode.
  
  ![shot-horizon4](https://github.com/user-attachments/assets/1699b849-985b-40c8-bc6f-0165375527f7)
    
- **Snowflake ❄** (top-left) freezes all readings and the dot in place.
  Tap again to release. Horizon mode is blocked while frozen.


## Horizon Mode

Tilt the watch past 60° and the display automatically switches to a rotating
horizon line showing roll angle. The scale rotates to stay aligned with
gravity. Tap the horizon line to return to dot mode by tilting back flat.

![shot-horizon5](https://github.com/user-attachments/assets/73e20fe8-0c4f-4594-bf57-60d0971218c1)


## Tips

- The display will stay on during the app usage! Do not forget to close it when done.
- For water-scale precision, set the range to ±5°. A physical bubble level
  typically only indicates ±3°.
- Use delta mode to measure relative angles — place the watch on a reference
  surface, tap the dot to zero, then move to the surface you want to compare.
- Axis locks work in delta mode for single-plane relative measurements.
