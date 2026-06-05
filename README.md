# 3dprint

Parametric 3D-printable designs written in OpenSCAD.

## Projects

### Paper-pocket roulette wheel (`roulette.scad`)

A 150 mm spinning wheel with 12 deep circular pockets sized to hold folded
paper notes. Raised separator walls divide the sectors, the center is
recessed to save material, and a pyramidal pointer slots into the base.
Designed to spin on an M5 screw rather than a printed axle.

#### Bill of materials

- 1× M5×25 socket-head cap screw
- 1× M5 nyloc nut
- 2× M5 washers

#### Printed parts

Open `roulette.scad` in OpenSCAD, set the `part` variable, press F6, then export STL.

| Part      | Notes                                                          |
| --------- | -------------------------------------------------------------- |
| `wheel`   | Pocket-side up, 0.2 mm layers, 15–20% infill. ~28 mm tall.     |
| `base`    | Counterbore side down — screw-head recess prints cleanly.      |
| `pointer` | Foot down, tip up. Tapered pyramid; no supports needed.        |

Leave `part = "all"` for an exploded preview of every component.

#### Assembly

1. Drop the screw head into the counterbore on the **underside** of the base.
2. Slide a washer onto the shaft above the base hub.
3. Drop the wheel on — the shaft passes through with running clearance.
4. Second washer on top of the wheel.
5. Thread the nyloc nut into the recess on top. Tighten until the wheel spins
   freely without wobble.
6. Press the pointer's tab into the slot near the rim of the base. Glue if
   the fit is loose.

#### Tuning

If the M5 shaft is too loose or too tight in the wheel hole, adjust
`screw_clearance` (default 0.4 mm) and reprint just the wheel.

## License

MIT
