# 3dprint

Parametric 3D-printable designs written in OpenSCAD.

## Projects

### Hose-end watering spike (`hose_spike.scad`)

A 144 mm tall watering spike that plugs into the end of a 10 mm ID hose and
sticks into a plant's soil. A tapered internal bore feeds 24 small side holes
distributed between 45–85 mm depth so water is released at root level rather
than running off the surface. Prints without supports (all overhangs ≤ 38°
from vertical).

#### What you need

- 10 mm ID flexible hose
- Print with a brim (5–8 mm) for bed adhesion — the bottom contact patch is
  small. No supports.

#### Print settings

| Setting | Value |
| ------- | ----- |
| Orientation | Barb end down, tip up |
| Layer height | 0.2 mm |
| Infill | 30% (water pressure isn't high but layer adhesion matters for the bore) |
| Walls | 3 perimeters (the cone walls are thin near the tip — extra perimeters help) |
| Brim | 5–8 mm |
| Supports | None |

#### Assembly

Push the barbed end into the hose until the wider collar stops it. No clamp
needed for low-pressure drip irrigation; add a hose clamp for higher pressure.

Push the cone tip into the soil. The hose is on top, the holes deliver water
to the root zone underground.

#### Tuning

- **Hose ID different from 10 mm:** adjust `barb_neck_od` (~hose ID − 0.6) and
  `barb_od` (~hose ID + 1.2).
- **Want more / fewer holes:** change `hole_rows` and `hole_per_row`.
- **Want a shorter spike:** reduce `cone_length` AND `hole_deepest_z` (the
  deepest hole row must stay below `bore_top_z`).

---

### Paper-pocket roulette wheel (`roulette.scad`)

A 150 mm spinning wheel with 12 deep circular pockets sized to hold folded
paper notes. Raised separator walls divide the sectors, the center is a
shallow decorative bowl with a knurled hex-keyed knob you grip to spin the
wheel, and a tall pyramidal pointer slots into the base. Designed to spin
on an M5 screw rather than a printed axle.

#### Bill of materials

- 1× M5×25 socket-head cap screw
- 1× M5 nyloc nut (captured in a hex pocket on top of the wheel)
- 1× M5 washer (between the base hub and the wheel — acts as a thrust bearing)

#### Printed parts

Open `roulette.scad` in OpenSCAD, set the `part` variable, press F6, then export STL.

| Part      | Notes                                                          |
| --------- | -------------------------------------------------------------- |
| `wheel`   | Pocket-side up, 0.2 mm layers, 15–20% infill. ~28 mm tall.     |
| `base`    | Counterbore side down — screw-head recess prints cleanly.      |
| `pointer` | Foot down, tip up. Tapered pyramid; no supports needed.        |
| `knob`    | Peg down (small footprint). 0.2 mm layers, 25% infill.         |

Leave `part = "all"` for an exploded preview of every component.

#### Assembly

1. Drop the screw head into the counterbore on the **underside** of the base.
2. Slide the washer onto the shaft above the base hub (acts as a thrust bearing).
3. Drop the wheel on — the shaft passes through with running clearance.
4. Drop the nyloc nut into the **hex pocket** on top of the wheel. It can only
   sit one way (six orientations); rotate until it drops flush.
5. Hold the wheel still and tighten the screw from below with an Allen key.
   The hex pocket grips the nut so it can't spin. Tighten until the wheel
   still spins freely without wobble.
6. Drop the **knob** into the central bowl — its hex peg drops into the
   large hex socket above the nut. Optionally glue it in for permanence.
7. Press the pointer's tab into the slot near the rim of the base. Glue if
   the fit is loose.

#### Tuning

If the M5 shaft is too loose or too tight in the wheel hole, adjust
`screw_clearance` (default 0.4 mm) and reprint just the wheel.

## License

MIT
