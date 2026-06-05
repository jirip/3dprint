// Parametric paper-pocket roulette wheel.
// Hardware: M5x25 socket-head cap screw + M5 nyloc nut + 2x M5 washers.
// Render each part by setting `part` below, then F6 and export STL.

part = "all";   // "wheel" | "base" | "pointer" | "all"

// ---------- Wheel ----------
wheel_dia       = 150;
wheel_thickness = 10;
pocket_count    = 12;
pocket_dia      = 25;   // folded paper notes
pocket_depth    = 7;    // leaves 3 mm floor
rim_width       = 4;    // outer rim around pockets
hub_dia         = 30;   // solid center around the screw

// ---------- Base ----------
base_dia        = 170;
base_thickness  = 8;    // thicker to host counterbore + nut pocket clearance
washer_gap      = 1.2;  // raised hub height — wheel rides on washer, not base

// ---------- Hardware (M5x25) ----------
screw_shaft_d   = 5.0;
screw_clearance = 0.4;  // running fit through the wheel
screw_head_d    = 8.8;  // socket-head cap diameter (typ. 8.5, +tolerance)
screw_head_h    = 5.0;  // head height (typ. 5.0)
nut_af          = 8.0;  // M5 hex nut across-flats
nut_h           = 5.0;  // nyloc nut height incl. nylon insert
washer_od       = 10.0;
washer_th       = 1.0;

// ---------- Pointer ----------
pointer_len     = 28;
pointer_w       = 14;
pointer_h       = 6;

$fn             = 128;

// Derived
pocket_ring_r   = (wheel_dia/2) - rim_width - pocket_dia/2;
nut_pocket_d    = nut_af / cos(30) + 0.4;   // circumscribed circle + clearance
wheel_hole_d    = screw_shaft_d + screw_clearance;

// ---------- Modules ----------
module wheel() {
    difference() {
        cylinder(d = wheel_dia, h = wheel_thickness);

        // pockets
        for (i = [0 : pocket_count - 1]) {
            a = 360 * i / pocket_count;
            translate([pocket_ring_r * cos(a),
                       pocket_ring_r * sin(a),
                       wheel_thickness - pocket_depth])
                cylinder(d = pocket_dia, h = pocket_depth + 0.1);
        }

        // central screw hole (running fit)
        translate([0, 0, -0.1])
            cylinder(d = wheel_hole_d, h = wheel_thickness + 0.2);

        // recess on top so the upper washer + nut sit flush
        recess_d = max(washer_od, nut_pocket_d) + 1.0;
        recess_h = washer_th + nut_h + 0.5;
        translate([0, 0, wheel_thickness - recess_h])
            cylinder(d = recess_d, h = recess_h + 0.1);
    }
}

module base() {
    difference() {
        union() {
            cylinder(d = base_dia, h = base_thickness);
            // raised hub: wheel's bottom washer rides on this, not the base face
            translate([0, 0, base_thickness])
                cylinder(d = hub_dia, h = washer_gap);
        }

        // through-hole for the screw shaft
        translate([0, 0, -0.1])
            cylinder(d = screw_shaft_d + 0.3,
                     h = base_thickness + washer_gap + 0.2);

        // counterbore on the underside for the socket head — sits flat on table
        translate([0, 0, -0.1])
            cylinder(d = screw_head_d + 0.4, h = screw_head_h + 0.2);
    }
}

module pointer() {
    // Arrow sits at the wheel edge, mount stub glues into a drilled hole
    // (or just glue flat to the base).
    mount_stub_d = 5;
    mount_stub_h = 4;

    translate([0, 0, mount_stub_h])
        linear_extrude(pointer_h)
            polygon(points = [
                [-pointer_w/2,  0],
                [ pointer_w/2,  0],
                [ 0,            pointer_len]
            ]);
    cylinder(d = mount_stub_d, h = mount_stub_h);
}

// ---------- Layout ----------
if (part == "wheel")        wheel();
else if (part == "base")    base();
else if (part == "pointer") pointer();
else {
    // exploded preview
    base();
    translate([0, 0, base_thickness + washer_gap + 3]) wheel();
    translate([wheel_dia/2 + 15, 0, 0]) pointer();
}
