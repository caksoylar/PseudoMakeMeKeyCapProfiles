union() {
  translate([ 8.5, -1, 0.0])cube([4, 2, 2]);
  translate([29.5, -1, 0.0])cube([4, 2, 2]);
  translate([50.5, -1, 0.0])cube([4, 2, 2]);
  translate([71.5, -1, 0.0])cube([4, 2, 2]);
  import("newstem/DES_R3_tol0.stl");
  translate([21, 0, 0])import("newstem/DES_T1L_tol0.025.stl");
  translate([42, 0, 0])import("newstem/DES_R3H_tol0.05.stl");
  translate([63, 0, 0])import("newstem/DES_T1R_tol0.075.stl");
  translate([84, 0, 0])import("newstem/DES_R5x_tol0.1.stl");
};
