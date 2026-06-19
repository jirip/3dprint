// Parametric soil watering spike for the end of a 10 mm ID hose.
// Pointy cone goes into the soil; many small side holes release water at root level.
// A barbed adapter at the top slides INTO the hose and grips it via ridges.
//
// Print orientation: barb end DOWN, tip UP — barbs are all sloped surfaces,
// no overhangs to worry about. BUT the bottom contact patch is only a thin
// ring (~7.9 mm OD with the bore opening in its center), so a brim is mandatory
// for bed adhesion on a 200 mm tall print. Use 5–8 mm brim in your slicer.
// No supports needed.

// ---------- Hose / adapter ----------
hose_id          = 10.0;   // hose inner diameter
barb_count       = 3;      // number of grip ridges
barb_od          = 11.2;   // barb outer diameter (slight interference vs hose ID)
barb_neck_od     = 9.4;    // smaller diameter between barbs (slips into hose)
barb_ring_h      = 1.8;    // height of each barb ridge
barb_pitch       = 4.5;    // distance between consecutive barb ring tops
adapter_lead_h   = 3.0;    // short smooth lead-in before the first barb
adapter_collar_h = 4.0;    // wider collar at the top of the adapter (hose stop)
adapter_collar_od = 14.0;  // collar OD — wider than hose ID so hose can't slide up
adapter_bore_d   = 4.5;    // water channel through the adapter — narrower than barbs to keep walls thick

// ---------- Cone (the spike) ----------
cone_length      = 120.0;  // total cone length (from base to tip)
cone_base_od     = 14.0;   // cone diameter at the wide (top) end — flush with collar
cone_tip_od      = 1.5;    // tip diameter (small but not a knife edge)

// ---------- Water passage ----------
// Tapered internal water channel that follows the cone, leaving a ~1.5 mm wall.
bore_d_at_base   = 6.0;    // bore diameter at the cone base (z=0)
bore_d_at_top    = 2.0;    // bore diameter at its top (just below the solid tip)
bore_top_z       = 90.0;   // z position where the bore ends; cone is solid above this

// ---------- Side holes ----------
// Cone-frame z runs 0 (wide base, at soil surface) -> cone_length (tip, deep in soil).
// First hole row is the shallowest; last row is the deepest (closest to tip).
hole_d              = 2.0;     // each side hole diameter
hole_rows           = 6;       // number of rows along the cone
hole_per_row        = 4;       // holes per row (evenly around the circumference)
hole_row_twist      = 30;      // each row twists this many degrees relative to previous
hole_shallowest_z   = 45.0;    // depth (from cone base) of the first/shallowest row
hole_deepest_z      = 85.0;    // depth of the last/deepest row (must be < bore_top_z)

$fn              = 96;

// ---------- Derived ----------
adapter_total_h  = adapter_lead_h + barb_count * barb_pitch + adapter_collar_h;

// ---------- Modules ----------

// Single barbed ring — wider belt with a taper down to the neck below it.
module barb_ring(z) {
    translate([0, 0, z])
        cylinder(d1 = barb_neck_od, d2 = barb_od, h = barb_ring_h);
    // sharp top, then ramp back to the neck for the next segment
    translate([0, 0, z + barb_ring_h])
        cylinder(d1 = barb_od, d2 = barb_neck_od, h = barb_pitch - barb_ring_h);
}

// The barbed insert (excluding the collar / cone above it). Origin at z=0,
// barb stack grows upward.
module barbed_insert() {
    // smooth lead-in nose so the user can start pushing into the hose
    cylinder(d1 = barb_neck_od - 1.5, d2 = barb_neck_od, h = adapter_lead_h);
    // n barbed rings stacked
    for (i = [0 : barb_count - 1]) {
        barb_ring(adapter_lead_h + i * barb_pitch);
    }
}

// Cone outer diameter at any z (linear taper between base and tip).
function cone_od_at(z) =
    cone_base_od + (cone_tip_od - cone_base_od) * z / cone_length;

// The cone above the collar, with side holes and a stopped tapered internal bore.
module spike_cone() {
    difference() {
        // Solid cone (wide at z=0, point at z=cone_length)
        cylinder(d1 = cone_base_od, d2 = cone_tip_od, h = cone_length);

        // Tapered water bore — narrows along the cone, stops short of the tip
        translate([0, 0, -0.1])
            cylinder(d1 = bore_d_at_base,
                     d2 = bore_d_at_top,
                     h = bore_top_z + 0.1);

        // Side holes: rows from shallowest_z to deepest_z, twisted around the axis
        for (row = [0 : hole_rows - 1]) {
            z = hole_shallowest_z
                + (hole_deepest_z - hole_shallowest_z) * row / (hole_rows - 1);
            r = cone_od_at(z) / 2;
            for (j = [0 : hole_per_row - 1]) {
                a = 360 * j / hole_per_row + row * hole_row_twist;
                rotate([0, 0, a])
                    translate([0, 0, z])
                        rotate([90, 0, 0])
                            // Long enough to pass through the cone and the bore.
                            cylinder(d = hole_d, h = r + 2);
            }
        }
    }
}

// Full assembly: barbed insert (bottom) -> collar -> cone (top)
module spike() {
    // Barbed insert (bottom of print — small footprint, prints first)
    barbed_insert();

    // Collar (hose stop) above the barbs
    translate([0, 0, adapter_lead_h + barb_count * barb_pitch])
        cylinder(d = adapter_collar_od, h = adapter_collar_h);

    // Cone above the collar
    translate([0, 0, adapter_total_h])
        spike_cone();

    // Drill the through-channel from the adapter base up through to meet the bore.
    // (We do this as a difference on the whole thing in the final assembly.)
}

// Final part: spike + internal channel from the very bottom to the cone bore.
difference() {
    spike();

    // Through-channel from bottom of barb up into the collar. Narrower than the
    // cone bore so the wall stays thick enough through the lead-in section
    // (where the outer diameter dips to ~7.9 mm). Expands into the cone bore above.
    translate([0, 0, -0.1])
        cylinder(d = adapter_bore_d,
                 h = adapter_total_h + 0.2);
}
