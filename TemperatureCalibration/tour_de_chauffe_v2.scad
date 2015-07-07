//NOT TESTED for non cubes... should work for variable height (X=Y), but no guarantee.

// You must modify the gcode you generate! (Cura has TweakAtX plugin, not sure about other slicers)
DoYouUnderstandYouMustModifyTheGCodeThisMakes=123; // [123:What?, 456:Yes I understand]

NumberOfBlocks = 7;
Labels=["206","208","210","212","214","216","218"];
ReverseLabelOrder=0; //[0:False, 1:True]
Reverse=ReverseLabelOrder == 1;

// NOT guaranteed to work for all combinations (simply have not tested it)
BlockSize=[10,10,10];


FontFace=0;// [0:Arial Bold,1:Liberation Sans]
FontFacesInCustomizer=["Arial:style=Bold","Liberation Sans"]; //TODO add more
Font=FontFacesInCustomizer[FontFace];

/* [Hidden] */

TWEAK=0.01;
TWEAK2=TWEAK*2;


difference()
{
    for (i = [1:NumberOfBlocks])
    {
        //My disclamer strategy...
        if (DoYouUnderstandYouMustModifyTheGCodeThisMakes == 456)
        translate([0,0,BlockSize[2] * (i-1)])
            block(Reverse ? Labels[NumberOfBlocks-i-1] : Labels[i-1], BlockSize);
        echo(Labels[i-1]);
    }

    for (i = [1:NumberOfBlocks-1])
    {
        translate([-TWEAK,0,i*BlockSize[2]]) rotate([0,90,0])
            cylinder(d=1,h=BlockSize[0]+TWEAK2, $fn=getCustomFn(30));
    }
}

$fn_override = $fn;
function getCustomFn(base) = max(base, $fn_override);


module block(label, size)
{
    blockHeight=BlockSize[2];
    fontSizePct=0.4;
    fontXOffsetPct=0.05;
    fontZOffsetPct=0.3;
    
    centerCutoutPct=0.6;
    
    difference()
    {
        union()
        {
            cube(size);
        }
        
        union()
        {
            centerXYOffset = (1-centerCutoutPct) / 2;
            centerCutX=size[0]*centerCutoutPct;
            centerCutY=size[1]*centerCutoutPct;
            centerCutZ=size[2]*centerCutoutPct; //Not used for center cut...
            
            //Center cutout
            translate([size[0]*centerXYOffset, size[1]*centerXYOffset, -TWEAK])
                cube([centerCutX, centerCutY, size[2]+TWEAK2]);
            //Temp label
            translate([blockHeight * fontXOffsetPct, 0, blockHeight * fontZOffsetPct]) rotate([90,0,0])
                text(label, font=Font, size=blockHeight * fontSizePct);
            
            //Side 1: Hole
            //  Same size as centerCutoutPct
            translate([size[0]-(size[0]*centerXYOffset)-TWEAK, size[1]*.5, size[2]*.5]) rotate([0,90,0])
                cylinder(d=min(centerCutX, centerCutY), h=size[0]);
            
            //Side2: Arch/Slant
            radius=9;
            paddingSize=(size[0]-radius)/2;
            translate([radius+paddingSize,size[1] - (size[1]*centerXYOffset)-TWEAK,paddingSize])
                rotate([90,0,180])
                archslantThing(radius, size[1]);
            
            //Size 3: Triangle
            //  Same size as centerCutoutPct
            //  NOT equilateral, h=6, w=6
            translate([(size[0]*centerXYOffset)+TWEAK,size[1]/2,size[2]-(size[2]-centerCutZ)/2]) rotate([-90,0,90])
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