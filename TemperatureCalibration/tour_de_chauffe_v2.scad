//NOT TESTED for non cubes... should work for variable height (X=Y), but no guarantee.

NumberOfBlocks = 7;
Labels=["206","208","210","212","214","216","218"];
Reverse=false;

BlockSize=[10,10,10];

Font="Arial:style=Bold"; //["Arial:style=Bold","Liberation Sans"]

TWEAK=0.01;
TWEAK2=TWEAK*2;


for (i = [1:NumberOfBlocks])
{
    translate([0,0,BlockSize[2] * (i-1)])
        block(Reverse ? Labels[NumberOfBlocks-i-1] : Labels[i-1], BlockSize);
    echo(Labels[i-1]);
}

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
