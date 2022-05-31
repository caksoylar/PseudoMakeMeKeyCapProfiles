use <scad-utils/morphology.scad> // for cheaper minkowski
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <sweep.scad>
use <skin.scad>

// Choc Chord version Chicago Stenographer

keycap(
  keyID   = 1,           // change profile refer to KeyParameters Struct
  cutLen  = 0,           // Don't change. for chopped caps
  Stem    = true,        // turn on shell and stems
  StemRot = 0,           // change stem orientation by deg
  Dish    = true,        // turn on dish cut
  crossSection  = false, // center cut to check internal
  homeDot = false,       // turn on homedots
  Legends = false
);

// -Parameters
wallthickness = 1.1; // 1.75 for mx size, 1.1
topthickness = 2.5;  // 2 for phat 3 for chicago
stepsize = 50;       // resolution of Trajectory
step = 2;            // resolution of ellipses
fn = 32;             // resolution of Rounded Rectangles: 60 for output
layers = 40;         // resolution of vertical Sweep: 50 for output

// ---Stem param
slop    = 0.3;
stemWid = 8;
stemLen = 6;
stemCrossHeight = 1.8;
extra_vertical = 0.6;
stemLayers = 50; // resolution of stem to cap top transition

// injection param
draftAngle = 0; // degree  note:Stem Only
// TODO: Add wall thickness transition?

keyParameters =
[
//BotWid, BotLen, TWDif, TLDif, keyh, WSft, LSft, XSkew, YSkew, ZSkew, WEx, LEx, CapR0i, CapR0f, CapR1i, CapR1f, CapREx, StemEx
  // Regular keys
  [17.20,  16.00,   5.6,     5,  4.9,    0,   .0,     5,    -0,    -0,   2, 2.5,    .10,      2,     .10,      3,     2,      2], // Chicago Steno R2/R4
  [17.20,  16.00,   5.6,     5,  4.5,    0,   .0,     0,    -0,    -0,   2, 2.5,    .10,      3,     .10,      3,     2,      2], // Chicago Steno R3 flat

  // Thumb
  [17.20,  16.00,  4.25,  3.25,  5.0,  -.5,  0.0,    -3,    -3,    -0,   2,   2,    .10,      2,     .10,      2,     2,      2], // Thumb 1
  [15.65,   26.4,   5.5,  3.25,  4.9,  -.5,  0.0,    -3,    -2,    -2,   2,   2,     .3,      2,      .3,    2.5,     2,      2], // Thumb 1.5
  [15.65,   35.8,  4.25,  3.25,  4.9, -.25,  0.0,  -2.5,    -4,    -2,   2,   3,     .3,      2,      .3,    2.5,     2,      2], // Thumb 2.0
];

dishParameters = // dishParameter[keyID][ParameterID]
[
//FFwd1, FFwd2, FPit1, FPit2,  DshDep, DshHDif, FArcIn, FArcFn, FArcEx, BFwd1, BFwd2, BPit1, BPit2, BArcIn, BArcFn, BArcEx
  // Regular keys
  [ 4.5,     4,     7,   -50,       7,     1.7,     11,     17,      2,   4.5,     4,     2,   -35,     11,     15,      2], // Chicago Steno R2/R4
  [ 4.5,     4,     5,   -40,       7,     1.7,     11,     15,      2,   4.5,     4,     5,   -40,     11,     15,      2], // Chicago Steno R3 flat

// FFwd1, FFwd2, FPit1, FPit2, DshDep, DshHDif, FArcIn, FArcFn, FArcEx, BFwd1, BFwd2, BPit1, BPit2, BArcIn, BArcFn, BArcEx, FTani, FTanf, BTani, BTanf, TanEX, PhiInit, PhiFin
  // Thumb
  [    5,   5.5,     0,   -40,      7,     1.7,     16,     18,      2,   5.5,   3.5,     5,   -50,     16,     18,      2,     5,  3.75,     2,  3.75,     2,     199,    210], // T1
  [   10,   4.5,     0,   -40,      7,     1.7,     16,     15,      2,    10,   3.5,     5,   -50,     16,     18,      2,     3,  3.75,   .75,  3.75,     2,     200,    210], // 1.5u
  [ 14.5,   4.5,     4,   -40,      7,     1.7,     16,     18,      2,  14.5,   4.5,     2,   -35,     16,     23,      2,     3,  3.75,   .75,  3.75,     2,     200,    210], // 2.0u
];

function BottomWidth(keyID)  = keyParameters[keyID][0];
function BottomLength(keyID) = keyParameters[keyID][1];
function TopWidthDiff(keyID) = keyParameters[keyID][2];
function TopLenDiff(keyID)   = keyParameters[keyID][3];
function KeyHeight(keyID)    = keyParameters[keyID][4];
function TopWidShift(keyID)  = keyParameters[keyID][5];
function TopLenShift(keyID)  = keyParameters[keyID][6];
function XAngleSkew(keyID)   = keyParameters[keyID][7];
function YAngleSkew(keyID)   = keyParameters[keyID][8];
function ZAngleSkew(keyID)   = keyParameters[keyID][9];
function WidExponent(keyID)  = keyParameters[keyID][10];
function LenExponent(keyID)  = keyParameters[keyID][11];
function CapRound0i(keyID)   = keyParameters[keyID][12];
function CapRound0f(keyID)   = keyParameters[keyID][13];
function CapRound1i(keyID)   = keyParameters[keyID][14];
function CapRound1f(keyID)   = keyParameters[keyID][15];
function ChamExponent(keyID) = keyParameters[keyID][16];
function StemExponent(keyID) = keyParameters[keyID][17];

function FrontForward1(keyID) = dishParameters[keyID][0];
function FrontForward2(keyID) = dishParameters[keyID][1];
function FrontPitch1(keyID)   = dishParameters[keyID][2];
function FrontPitch2(keyID)   = dishParameters[keyID][3];
function DishDepth(keyID)     = dishParameters[keyID][4];
function DishHeightDif(keyID) = dishParameters[keyID][5];
function FrontInitArc(keyID)  = dishParameters[keyID][6];
function FrontFinArc(keyID)   = dishParameters[keyID][7];
function FrontArcExpo(keyID)  = dishParameters[keyID][8];
function BackForward1(keyID)  = dishParameters[keyID][9];
function BackForward2(keyID)  = dishParameters[keyID][10];
function BackPitch1(keyID)    = dishParameters[keyID][11];
function BackPitch2(keyID)    = dishParameters[keyID][12];
function BackInitArc(keyID)   = dishParameters[keyID][13];
function BackFinArc(keyID)    = dishParameters[keyID][14];
function BackArcExpo(keyID)   = dishParameters[keyID][15];
function ForwardTanInit(keyID)= dishParameters[keyID][16];
function ForwardTanFin(keyID) = dishParameters[keyID][17];
function BackTanInit(keyID)   = dishParameters[keyID][18];
function BackTanFin(keyID)    = dishParameters[keyID][19];
function TanArcExpo(keyID)    = dishParameters[keyID][20];
function TransitionAngleInit(keyID) = dishParameters[keyID][21];
function TransitionAngleFin(keyID)  = dishParameters[keyID][22];

function FrontTrajectory(keyID) =
  [
    trajectory(forward = FrontForward1(keyID), pitch =  FrontPitch1(keyID)), // more param available: yaw, roll, scale
    trajectory(forward = FrontForward2(keyID), pitch =  FrontPitch2(keyID))  // You can add more traj if you wish
  ];

function BackTrajectory (keyID) =
  [
    trajectory(backward = BackForward1(keyID), pitch = -BackPitch1(keyID)),
    trajectory(backward = BackForward2(keyID), pitch = -BackPitch2(keyID)),
  ];

// ------- function defining Dish Shapes

function ellipse(a, b, d = 0, rot1 = 0, rot2 = 360) = [for (t = [rot1:step:rot2]) [a*cos(t)+a, b*sin(t)*(1+d*cos(t))]]; // Centered at a apex to avoid inverted face

function DishShape(a, b, phi = 270, theta = 0, r) =
  concat(
    ellipse(a, b, d = 0, rot1 = 90, rot2 = phi),
    [for (t = [step:step*2:theta])let(sig = atan(a*cos(phi)/-b*sin(phi)))
      [ r*cos(-atan(-a*cos(phi)/b*sin(phi))-t)
       +a*cos(phi)
       -r*cos(sig)
       +a,

       r*sin(-atan(-a*cos(phi)/b*sin(phi))-t)
      +b*sin(phi)
      +r*sin(sig)]
    ],

	theta > 0 ? [[a, b*sin(phi)-r*sin(theta)*2]] : [] // boundary vertex to clear ends
  );

function oval_path(theta, phi, a, b, c, deform = 0) = [
 a*cos(theta)*cos(phi), // x
 c*sin(theta)*(1+deform*cos(theta)), //
 b*sin(phi),
];

path_trans2 = [for (t=[0:step:180])   translation(oval_path(t, 0, 10, 15, 2, 0))*rotation([0, 90, 0])];

// --------------Function definng Cap
function CapTranslation(t, keyID) =
  [
    ((1-t)/layers*TopWidShift(keyID)),   // X shift
    ((1-t)/layers*TopLenShift(keyID)),   // Y shift
    (t/layers*KeyHeight(keyID))    // Z shift
  ];

function InnerTranslation(t, keyID) =
  [
    ((1-t)/layers*TopWidShift(keyID)),   // X shift
    ((1-t)/layers*TopLenShift(keyID)),   // Y shift
    (t/layers*(KeyHeight(keyID)-topthickness))    // Z shift
  ];

function CapRotation(t, keyID) =
  [
    ((1-t)/layers*XAngleSkew(keyID)),   // X shift
    ((1-t)/layers*YAngleSkew(keyID)),   // Y shift
    ((1-t)/layers*ZAngleSkew(keyID))    // Z shift
  ];

function CapTransform(t, keyID) =
  [
    pow(t/layers, WidExponent(keyID))*(BottomWidth(keyID) -TopWidthDiff(keyID)) + (1-pow(t/layers, WidExponent(keyID)))*BottomWidth(keyID),
    pow(t/layers, LenExponent(keyID))*(BottomLength(keyID)-TopLenDiff(keyID)) + (1-pow(t/layers, LenExponent(keyID)))*BottomLength(keyID)
  ];
function CapRoundness(t, keyID) =
  [
    pow(t/layers, ChamExponent(keyID))*(CapRound0f(keyID)) + (1-pow(t/layers, ChamExponent(keyID)))*CapRound0i(keyID),
    pow(t/layers, ChamExponent(keyID))*(CapRound1f(keyID)) + (1-pow(t/layers, ChamExponent(keyID)))*CapRound1i(keyID)
  ];

function CapRadius(t, keyID) = pow(t/layers, ChamExponent(keyID))*ChamfFinRad(keyID) + (1-pow(t/layers, ChamExponent(keyID)))*ChamfInitRad(keyID);

function InnerTransform(t, keyID) =
  [
    pow(t/layers, WidExponent(keyID))*(BottomWidth(keyID) -TopLenDiff(keyID)-wallthickness*2) + (1-pow(t/layers, WidExponent(keyID)))*(BottomWidth(keyID) -wallthickness*2),
    pow(t/layers, LenExponent(keyID))*(BottomLength(keyID)-TopLenDiff(keyID)-wallthickness*2) + (1-pow(t/layers, LenExponent(keyID)))*(BottomLength(keyID)-wallthickness*2)
  ];

function StemTranslation(t, keyID) =
  [
    ((1-t)/stemLayers*TopWidShift(keyID)),   // X shift
    ((1-t)/stemLayers*TopLenShift(keyID)),   // Y shift
    stemCrossHeight+.1 + (t/stemLayers*(KeyHeight(keyID)- topthickness - stemCrossHeight-.1))    // Z shift
  ];

function StemTransform(t, keyID) =
  [
    pow(t/stemLayers, StemExponent(keyID))*(BottomWidth(keyID) -TopLenDiff(keyID)-wallthickness*2) + (1-pow(t/stemLayers, StemExponent(keyID)))*(stemWid - 2*slop),
    pow(t/stemLayers, StemExponent(keyID))*(BottomLength(keyID)-TopLenDiff(keyID)-wallthickness*2) + (1-pow(t/stemLayers, StemExponent(keyID)))*(stemLen - 2*slop)
  ];

function StemRadius(t, keyID) = pow(t/stemLayers, 3)*3 + (1-pow(t/stemLayers, 3))*1;
  // Stem Exponent

function FTanRadius(t, keyID) = pow(t/stepsize, TanArcExpo(keyID))*ForwardTanInit(keyID) + (1-pow(t/stepsize, TanArcExpo(keyID)))*ForwardTanFin(keyID);
function BTanRadius(t, keyID) = pow(t/stepsize, TanArcExpo(keyID))*BackTanInit(keyID)    + (1-pow(t/stepsize, TanArcExpo(keyID)))*BackTanFin(keyID);

// /----- KEY Builder Module
module keycap(keyID = 0, cutLen = 0, crossSection = false, Dish = true, Stem = false, thumb = false, StemRot = 0, homeDot = false, Legends = false) {

  // Set Parameters for dish shape
  FrontPath = quantize_trajectories(FrontTrajectory(keyID), steps = stepsize, loop=false);
  BackPath  = quantize_trajectories(BackTrajectory(keyID),  steps = stepsize, loop=false);

  // Scaling initial and final dim tranformation by exponents
  function FrontDishArc(t) =  pow((t)/(len(FrontPath)), FrontArcExpo(keyID))*FrontFinArc(keyID) + (1-pow(t/(len(FrontPath)), FrontArcExpo(keyID)))*FrontInitArc(keyID);
  function BackDishArc(t)  =  pow((t)/(len(FrontPath)), BackArcExpo(keyID))*BackFinArc(keyID)   + (1-pow(t/(len(FrontPath)), BackArcExpo(keyID)))*BackInitArc(keyID);

  
  FrontCurve = [ for(i=[0:len(FrontPath)-1]) transform(FrontPath[i], thumb ? DishShape(a = DishDepth(keyID), b = FrontDishArc(i), phi = TransitionAngleInit(keyID), theta = 60, r = FTanRadius(i, keyID))
                                                                           : DishShape(a = DishDepth(keyID), b = FrontDishArc(i))) ];
  BackCurve  = [ for(i=[0:len(BackPath)-1])  transform(BackPath[i],  thumb ? DishShape(a = DishDepth(keyID), b = BackDishArc(i),  phi = TransitionAngleInit(keyID), theta = 60, r = BTanRadius(i, keyID))
                                                                           : DishShape(a = DishDepth(keyID), b = BackDishArc(i))) ];

  // builds
  difference(){
    union(){
      difference(){
        skin([for (i=[0:layers-1]) transform(translation(CapTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(CapTransform(i, keyID), b = CapRoundness(i, keyID), fn=fn))]); // outer shell

        // Cut inner shell
        if(Stem){
          translate([0, 0, -.001])skin([for (i=[0:layers-1]) transform(translation(InnerTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(InnerTransform(i, keyID), b = CapRoundness(i, keyID), fn=fn))]);
        }
      }
      if(Stem){
        rotate([0, 0, StemRot]){
          choc_stem(draftAng = draftAngle);
          translate([0, 0, -.001])skin([for (i=[0:stemLayers-1]) transform(translation(StemTranslation(i, keyID)), rounded_rectangle_profile(StemTransform(i, keyID), fn=fn, r=StemRadius(i, keyID)))]); // outer shell
        }
      }
    }

    // Cuts
    // Fonts
    if(cutLen != 0){
      translate([sign(cutLen)*(BottomLength(keyID)+CapRound0i(keyID)+abs(cutLen))/2, 0, 0])
        cube([BottomWidth(keyID)+CapRound1i(keyID)+1, BottomLength(keyID)+CapRound0i(keyID), 50], center = true);
    }
    if(Legends){
      #rotate([-XAngleSkew(keyID), YAngleSkew(keyID), ZAngleSkew(keyID)])translate([-1, -5, KeyHeight(keyID)-2.5])linear_extrude(height = 1)text( text = "ver2", font = "Constantia:style=Bold", size = 3, valign = "center", halign = "center" );
    }
    // Dish Shape
    if(Dish){
      translate([-TopWidShift(keyID), .0001-TopLenShift(keyID), KeyHeight(keyID)-DishHeightDif(keyID)])rotate([0, -YAngleSkew(keyID), 0])rotate([0, -90+XAngleSkew(keyID), 90-ZAngleSkew(keyID)])skin(FrontCurve);
      translate([-TopWidShift(keyID), -TopLenShift(keyID), KeyHeight(keyID)-DishHeightDif(keyID)])rotate([0, -YAngleSkew(keyID), 0])rotate([0, -90+XAngleSkew(keyID), 90-ZAngleSkew(keyID)])skin(BackCurve);
    }
    if(crossSection) {
      translate([0, -25, -.1])cube([15, 50, 15]);
    }
  }

  // Homing dot
  if(homeDot){
    if(thumb){
      translate([0, 0, KeyHeight(keyID)-DishHeightDif(keyID)-.25])sphere(d = 1);
    } else {
      translate([ 2, -4.5, KeyHeight(keyID)-DishHeightDif(keyID)+.15])sphere(d = 1);
      translate([-2, -4.5, KeyHeight(keyID)-DishHeightDif(keyID)+.15])sphere(d = 1);
    }
  }
}

// ------------------stems
$fn = fn;

module choc_stem(draftAng = 5) {
  stemHeight = 3.1;
  dia = .15;
  wids = 1.2/2;
  lens = 2.9/2;
  module Stem() {
    difference(){
      translate([0, 0, -stemHeight/2])linear_extrude(height = stemHeight)hull(){
        translate([wids-dia, -3/2])circle(d=dia);
        translate([-wids+dia, -3/2])circle(d=dia);
        translate([wids-dia, 3/2])circle(d=dia);
        translate([-wids+dia, 3/2])circle(d=dia);
      }

    // cuts
      translate([3.9, 0])cylinder(d1=7+sin(draftAng)*stemHeight, d2=7, 3.5, center = true, $fn = 64);
      translate([-3.9, 0])cylinder(d1=7+sin(draftAng)*stemHeight, d2=7, 3.5, center = true, $fn = 64);
    }
  }

  translate([5.7/2, 0, -stemHeight/2+2])Stem();
  translate([-5.7/2, 0, -stemHeight/2+2])Stem();
}

// ----- helper functions
function rounded_rectangle_profile(size=[1, 1], r=1, fn=32) = [
	for (index = [0:fn-1])
		let(a = index/fn*360)
			r * [cos(a), sin(a)]
			+ sign_x(index, fn) * [size[0]/2-r, 0]
			+ sign_y(index, fn) * [0, size[1]/2-r]
];

function elliptical_rectangle(a = [1, 1], b =[1, 1], fn=32) = [
    for (index = [0:fn-1]) // section right
     let(theta1 = -atan(a[1]/b[1])+ 2*atan(a[1]/b[1])*index/fn)
      [b[1]*cos(theta1), a[1]*sin(theta1)]
    + [a[0]*cos(atan(b[0]/a[0])), 0]
    - [b[1]*cos(atan(a[1]/b[1])), 0],

    for(index = [0:fn-1]) // section Top
     let(theta2 = atan(b[0]/a[0]) + (180 -2*atan(b[0]/a[0]))*index/fn)
      [a[0]*cos(theta2), b[0]*sin(theta2)]
    - [0, b[0]*sin(atan(b[0]/a[0]))]
    + [0, a[1]*sin(atan(a[1]/b[1]))],

    for(index = [0:fn-1]) // section left
     let(theta2 = -atan(a[1]/b[1])+180+ 2*atan(a[1]/b[1])*index/fn)
      [b[1]*cos(theta2), a[1]*sin(theta2)]
    - [a[0]*cos(atan(b[0]/a[0])), 0]
    + [b[1]*cos(atan(a[1]/b[1])), 0],

    for(index = [0:fn-1]) // section Top
     let(theta2 = atan(b[0]/a[0]) + 180 + (180 -2*atan(b[0]/a[0]))*index/fn)
      [a[0]*cos(theta2), b[0]*sin(theta2)]
    + [0, b[0]*sin(atan(b[0]/a[0]))]
    - [0, a[1]*sin(atan(a[1]/b[1]))]
]/2;

function sign_x(i, n) =
	i < n/4 || i > n-n/4  ?  1 :
	i > n/4 && i < n-n/4  ? -1 :
	0;

function sign_y(i, n) =
	i > 0 && i < n/2  ?  1 :
	i > n/2 ? -1 :
	0;
