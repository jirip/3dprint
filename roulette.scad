// Parametric paper-pocket roulette wheel.
// Hardware: M5x25 socket-head cap screw + M5 nyloc nut + 1x M5 washer.
// Render each part by setting `part` below, then F6 and export STL.

part = "all";   // "wheel" | "base" | "pointer" | "knob" | "all"

// ---------- Wheel ----------
wheel_dia        = 150;
wheel_thickness  = 28;   // 25 mm pocket + 3 mm floor
pocket_count     = 12;
pocket_dia       = 25;   // folded paper notes
pocket_depth     = 25;   // deep pockets
rim_width        = 4;    // outer rim around pockets
hub_dia          = 30;   // solid center around the screw
sep_wall_w       = 2.4;  // thickness of separator wall between pockets
sep_wall_h       = 3;    // how tall the separator stands above pocket rim
center_relief_d  = 85;   // diameter of decorative top bowl
center_relief_h  = 12;   // depth of top bowl

// Material in the center is saved via slicer infill (~15%) — printing the
// underside flat is the cleanest path. No internal cavities needed.

// ---------- Knob (separate part, hex-keyed into wheel) ----------
// A short knurled control knob that drops into a hex socket in the wheel center.
// Two stacked hex pockets in the wheel: large one for the knob, smaller one
// below for the nyloc nut. Each is keyed against rotation independently.
knob_socket_af   = 12.0;  // hex socket across-flats (wheel side)
knob_socket_h    = 6.0;   // socket depth (knob peg height into wheel)
knob_socket_clearance = 0.3;  // total clearance on AF — easy slide-in
knob_dia         = 22.0;  // top knurled body diameter
knob_height      = 44.0;  // body height above the wheel surface
knob_groove_count = 16;   // number of knurling grooves
knob_groove_w    = 1.6;   // groove width (cuts)
knob_groove_d    = 1.0;   // groove depth into the body
knob_dome_h      = 3.0;   // hemispherical top dome height

// ---------- Base ----------
base_dia         = 170;
base_thickness   = 8;    // thicker to host counterbore + nut pocket clearance
washer_gap       = 1.2;  // raised hub height — washer sits on hub, wheel rides on washer

// ---------- Hardware (M5x25 socket-head cap screw) ----------
// Head is ROUND (cylindrical) — hex socket cut into its top for an Allen key.
// Nut is HEX across-flats — gets a hex pocket so it can't spin while tightening.
screw_shaft_d    = 5.0;
screw_clearance  = 0.4;  // running fit through the wheel
screw_head_d     = 8.5;  // socket-head cap diameter (round)
screw_head_h     = 5.0;  // head height
nut_af           = 8.0;  // M5 hex nut across-flats
nut_h            = 5.0;  // nyloc nut height incl. nylon insert

// ---------- Pointer ----------
// Pyramidal arrow: wide rectangular foot tapering up to a thin tip.
// Slot-mounts into the base near the rim, pointing inward.
pointer_foot_w   = 22;   // foot width (tangential to wheel)
pointer_foot_l   = 9;    // foot length (radial) — must fit in base overhang ring (10 mm)
pointer_height   = 40;   // total height above base
pointer_tip_w    = 3;    // top tip width
pointer_tip_l    = 3;    // top tip length
pointer_tab_w    = 10;   // mounting tab width
pointer_tab_l    = 6;    // mounting tab length (radial)
pointer_tab_h    = 5;    // tab depth into base slot
pointer_tab_interference = 0.15;  // tab is this much LARGER than slot per axis -> press fit
pointer_radial_offset = 1;  // tip shift toward wheel center, in mm (must be < pointer_foot_l/2 - pointer_tip_l/2)

$fn              = 128;

// ---------- Derived ----------
pocket_ring_r    = (wheel_dia/2) - rim_width - pocket_dia/2;
wheel_hole_d     = screw_shaft_d + screw_clearance;

// Pointer slot center: in the base overhang ring, between wheel edge and base edge.
// Wheel rim = 75, base rim = 85, overhang ring is 10 mm wide.
// Place slot at radius 80 — keeps ~2 mm of base material on the outside of the slot
// and the inner edge of the foot sits just outside the wheel rim.
pointer_slot_r   = (wheel_dia/2 + base_dia/2) / 2;   // = 80 mm

// ---------- Wheel ----------
module wheel() {
    difference() {
        union() {
            // main disc
            cylinder(d = wheel_dia, h = wheel_thickness);

            // raised separator walls between pockets (12 radial ridges)
            for (i = [0 : pocket_count - 1]) {
                // wall sits between pocket i and pocket i+1, so angle = midpoint
                a = 360 * i / pocket_count + 360 / pocket_count / 2;
                rotate([0, 0, a])
                    translate([0, -sep_wall_w/2, wheel_thickness])
                        cube([wheel_dia/2 - 0.5, sep_wall_w, sep_wall_h]);
            }
        }

        // pockets
        for (i = [0 : pocket_count - 1]) {
            a = 360 * i / pocket_count;
            translate([pocket_ring_r * cos(a),
                       pocket_ring_r * sin(a),
                       wheel_thickness - pocket_depth])
                cylinder(d = pocket_dia, h = pocket_depth + sep_wall_h + 0.1);
        }

        // Central decorative bowl on top (85 mm wide, 12 mm deep)
        translate([0, 0, wheel_thickness - center_relief_h])
            cylinder(d = center_relief_d, h = center_relief_h + sep_wall_h + 0.1);

        // central screw hole (running fit) — full height including separator zone
        translate([0, 0, -0.1])
            cylinder(d = wheel_hole_d,
                     h = wheel_thickness + sep_wall_h + 0.2);

        // Inside the bowl, layered downward from the bowl floor:
        //   1) Hex socket for the KNOB peg (couples knob to wheel rotationally)
        //   2) Hex pocket for the NYLOC NUT (captures the nut against rotation)
        // Both are hex but with different across-flats so they don't interfere.
        knob_socket_af_cut = knob_socket_af + knob_socket_clearance;
        nut_pocket_af      = nut_af + 0.3;
        nut_recess_h       = nut_h + 0.4;

        // Knob hex socket (carved from the bowl floor downward)
        translate([0, 0, wheel_thickness - center_relief_h - knob_socket_h])
            rotate([0, 0, 30])
                cylinder(d = knob_socket_af_cut / cos(30),
                         h = knob_socket_h + 0.05,
                         $fn = 6);

        // Nut hex pocket (below the knob socket)
        translate([0, 0, wheel_thickness - center_relief_h - knob_socket_h - nut_recess_h])
            rotate([0, 0, 30])
                cylinder(d = nut_pocket_af / cos(30),
                         h = nut_recess_h + 0.05,
                         $fn = 6);
    }
}

// ---------- Base ----------
module base() {
    difference() {
        union() {
            cylinder(d = base_dia, h = base_thickness);
            // raised central hub — the washer sits on this; wheel rides on the washer
            translate([0, 0, base_thickness])
                cylinder(d = hub_dia, h = washer_gap);
        }

        // through-hole for the screw shaft
        translate([0, 0, -0.1])
            cylinder(d = screw_shaft_d + 0.3,
                     h = base_thickness + washer_gap + 0.2);

        // Round counterbore on the underside for the socket-head cap screw.
        // The head is held by the Allen key while you tighten the nut from above —
        // no rotational capture needed here.
        translate([0, 0, -0.1])
            cylinder(d = screw_head_d + 0.4, h = screw_head_h + 0.3);

        // pointer mounting slot — rectangular press-fit pocket in the base overhang.
        // Slot is 2 * pointer_tab_interference SMALLER than the tab on each axis,
        // so the tab compresses into the slot for a true interference fit.
        translate([pointer_slot_r, 0, base_thickness - pointer_tab_h])
            cube([pointer_tab_l - 2 * pointer_tab_interference,
                  pointer_tab_w - 2 * pointer_tab_interference,
                  pointer_tab_h + 0.1],
                 center = true);
    }
}

// ---------- Knob ----------
// Knurled grip knob with a hex peg that drops into the wheel's central hex
// socket. Glue or press-fit; no screw through it (the screw + nut are below).
module knob() {
    // Hex peg (bottom) — slight undersize relative to the wheel socket cut so
    // it slides in cleanly. The cut already includes clearance; print at nominal.
    peg_clearance = 0.15;          // shave a touch off the peg too
    rotate([0, 0, 30])
        cylinder(d = (knob_socket_af - peg_clearance) / cos(30),
                 h = knob_socket_h,
                 $fn = 6);

    // Body with knurling — round cylinder minus N vertical slots
    translate([0, 0, knob_socket_h])
        difference() {
            union() {
                cylinder(d = knob_dia, h = knob_height - knob_dome_h);
                // Hemisphere dome on top
                translate([0, 0, knob_height - knob_dome_h])
                    scale([1, 1, knob_dome_h / (knob_dia / 2)])
                        difference() {
                            sphere(d = knob_dia);
                            // chop bottom half so it's a dome
                            translate([0, 0, -knob_dia/2])
                                cube([knob_dia + 2, knob_dia + 2, knob_dia],
                                     center = true);
                        }
            }
            // Knurling grooves around the body — rectangular notches that
            // extend from just inside the surface to past it. The cube starts
            // at radius (r - groove_depth) and extends outward past the rim.
            for (i = [0 : knob_groove_count - 1]) {
                a = 360 * i / knob_groove_count;
                rotate([0, 0, a])
                    translate([knob_dia/2 - knob_groove_d,
                               -knob_groove_w/2,
                               -0.1])
                        cube([knob_groove_d + 1.0,
                              knob_groove_w,
                              knob_height + 0.2]);
            }
        }
}

// ---------- Pointer ----------
// Wide rectangular base tapering up to a thin tip — slots into the base.
module pointer() {
    // Mounting tab (extends down)
    translate([0, 0, -pointer_tab_h])
        cube([pointer_tab_l, pointer_tab_w, pointer_tab_h], center = true);

    // Tapered body — hull from foot rectangle to tip rectangle.
    // The tip is shifted inward (negative x) so the arrow leans toward the wheel.
    hull() {
        translate([0, 0, 0.01])
            cube([pointer_foot_l, pointer_foot_w, 0.02], center = true);
        translate([-(pointer_foot_l/2 - pointer_tip_l/2 - pointer_radial_offset),
                   0,
                   pointer_height])
            cube([pointer_tip_l, pointer_tip_w, 0.02], center = true);
    }
}

// ---------- Layout ----------
if (part == "wheel")        wheel();
else if (part == "base")    base();
else if (part == "pointer") pointer();
else if (part == "knob")    knob();
else {
    // exploded preview
    base();
    translate([0, 0, base_thickness + washer_gap + 3]) wheel();
    // knob shown seated in the wheel (peg into hex socket, body up out of bowl)
    translate([0, 0, base_thickness + washer_gap + 3
                     + wheel_thickness - center_relief_h - knob_socket_h + 0.5])
        knob();
    translate([pointer_slot_r, 0, base_thickness]) pointer();
}
