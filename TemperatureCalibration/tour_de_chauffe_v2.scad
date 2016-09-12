//NOT TESTED for non cubes... should work for variable height (X=Y), but no guarantee.

// You must modify the gcode you generate! (Cura has TweakAtX plugin, not sure about other slicers)
DoYouUnderstandYouMustModifyTheGCodeThisMakes=123; // [123:What?, 7:Yes I understand]

NumberOfBlocks = 7;
Labels=["206","208","210","212","214","216","218"];
ReverseLabelOrder=0; //[0:False, 1:True]
Reverse=ReverseLabelOrder == 1;

// NOT guaranteed to work for all combinations (simply have not tested it)
BlockSize=[10,10,10];
WallThickness=1.2;
TopOfTriangleThickness=2;

TowerBase=[30,30,3];


FontFace=2;// [0:Arial Bold,1:Liberation Sans,2:Open Sans,3:Montserrat,4:Dosis,5:Orbitron]
FontFacesInCustomizer=["Arial:style=Bold","Liberation Sans",
    "Open Sans:style=Bold",
    "Montserrat:style=Bold","Dosis:style=Bold","Orbitron:style=Bold"]; //TODO add more
Font=FontFacesInCustomizer[FontFace];

FontDepth=0.5;

//Increase the default facet number to produce smoother curves
fn_override = 0; //[0:Default, 24:Better (24), 50:High quality (50), 100:Super HQ (100)]
$fn = fn_override;

/* [Hidden] */

TWEAK=0.01;
TWEAK2=TWEAK*2;


//My disclamer strategy...
if (DoYouUnderstandYouMustModifyTheGCodeThisMakes == 7)
difference()
{
    union()
    {
        for (i = [1:NumberOfBlocks])
        {
            blockIndexer = Reverse ? NumberOfBlocks-i : i-1;
            translate([0,0,BlockSize[2] * (i-1)])
                block(Labels[blockIndexer], BlockSize);
            echo(Labels[blockIndexer], "starts at",BlockSize[2] * (i-1)+TowerBase[2]);
        }
        
        //Base
        towerXOffset = (TowerBase[0]-BlockSize[0])/2;
        towerYOffset = (TowerBase[1]-BlockSize[1])/2;
        translate([-towerXOffset,-towerYOffset,-TowerBase[2]+TWEAK])
            cube(TowerBase);
    }

    for (i = [1:NumberOfBlocks-1])
    {
        translate([-TWEAK,0,i*BlockSize[2]]) rotate([0,90,0])
            cylinder(d=1,h=BlockSize[0]+TWEAK2, $fn=getCustomFn(30));
    }
}
else
{
    rotate([90,-90,0])
    linear_extrude(2)
        union(){
        text("Learn/confirm you know how to modify", 10);
            translate([0,-12,0])
        text("the temp when generating the gcode", 10);}
}

$fn_override = $fn;
function getCustomFn(base) = max(base, $fn_override);


module block(label, size)
{
    blockHeight=BlockSize[2];
    fontSizePct=0.4;
    fontXOffsetPct=0.05;
    fontZOffsetPct=0.3;
    
    difference()
    {
        union()
        {
            cube(size);
        }
        
        union()
        {
            centerXYOffset = WallThickness;
            centerCutX=size[0]-WallThickness*2;
            centerCutY=size[1]-WallThickness*2;
            centerCutZ=size[2]-TopOfTriangleThickness; //Not used for center cut...
            
            //Center cutout
            translate([centerXYOffset, centerXYOffset, -TWEAK])
                cube([centerCutX, centerCutY, size[2]+TWEAK2]);
            //Temp label
            translate([blockHeight * fontXOffsetPct, FontDepth, blockHeight * fontZOffsetPct]) rotate([90,0,0])
                linear_extrude(FontDepth+TWEAK)
                //text(label, font=Font, size=blockHeight * fontSizePct);
                text(str(label), blockHeight * fontSizePct, Font);
                //text(label, size=font_size, halign="center");
            
            //Side 1: Hole
            //  Same size as centerCutoutPct
            translate([size[0]-(centerXYOffset)-TWEAK, size[1]*.5, size[2]*.5]) rotate([0,90,0])
                cylinder(d=min(centerCutX, centerCutY), h=size[0], $fn=getCustomFn(24));
            
            //Side2: Arch/Slant
            radius=9;
            paddingSize=(size[0]-radius)/2;
            translate([radius+paddingSize,size[1] - (centerXYOffset)-TWEAK,paddingSize])
                rotate([90,0,180])
                archslantThing(radius, size[1]);
            
            //Size 3: Triangle
            //  Same size as centerCutoutPct
            //  NOT equilateral, h=6, w=6
            translate([(centerXYOffset)+TWEAK,size[1]/2,size[2]-(size[2]-centerCutZ)/2]) rotate([-90,0,90])
                triangle(centerCutZ, centerCutX, size[0]);
        }
    }
}

module triangle(height, base, depth)
{
    linear_extrude(height)
        //polygon(points=[[-base/2,-height/2],[base/2,-height/2],[0,height/2]]);
        polygon(points=[[-base/2,0],[base/2,0],[0,height]]);
}
module archslantThing(radius, height)
{
    //bottom flat=4.5
    //28 degree slope toward top
    yOffset=-0.5;
    difference()
    {
        translate([0,yOffset,0])
        cylinder(r=radius, h=height);
        
        translate([-radius,-radius+yOffset,-TWEAK])
            cube([radius*2+TWEAK2,radius-yOffset,height+TWEAK2]);
        translate([radius/2,0,0])
        rotate([0,0,28])
        translate([-radius*1.5,0,-TWEAK])
            cube([radius*1.5,radius*1.5,height+TWEAK2]);
    }
}