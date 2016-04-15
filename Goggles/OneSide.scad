lensDiameter=50;
lensThickness=2;

theadDepth=1;

ledWidth=8;

totalDepth=lensThickness+lensThickness+ledWidth;


outerCaseThickness=1.2;
lipDiameter=2;



theadDiameterAdd=theadDepth*2;

if ((lipDiameter+.5) < ((theadDiameterAdd+outerCaseThickness)/2))
    echo("WARNING: lipDiameter should be larger than (theadDiameterAdd+outerCaseThickness)", (lipDiameter+.5)," < ",(theadDiameterAdd+outerCaseThickness)/2);

TWEAK=0.01;
TWEAK2=TWEAK*2;



//OuterCase();
//OuterThread();
2dArch(dIn=lensDiameter-theadDiameterAdd, dOut=lensDiameter, angle=1/(theadDepth*2)*360);


module OuterCase()
{
    outerCaseDiameter=lensDiameter+theadDiameterAdd;
    tz(totalDepth) _lip(outerCaseDiameter+outerCaseThickness, lipDiameter);
    
    difference()
    {
        cylinder(d=outerCaseDiameter+outerCaseThickness, h=totalDepth);
        tz(-TWEAK)
        cylinder(d=outerCaseDiameter, h=totalDepth+TWEAK2);
    }
}
module _lip(d, lipD)
{
difference()
{
    rotate_extrude()
        translate([(d-lipD)/2, 0, 0])
            circle(d=lipD);
    
    cubeNegateSize=d+lipD;
    translate([-cubeNegateSize/2, -cubeNegateSize/2, -lipD])
        cube([cubeNegateSize, cubeNegateSize, lipD]);
}
}



module OuterThread()
{
    angle=totalDepth/(theadDepth*2)*360;
    anglePerMm=1/(theadDepth*2)*360;
    linear_extrude(totalDepth, twist=angle)
        2dArch(dIn=lensDiameter-theadDiameterAdd, dOut=lensDiameter, angle=anglePerMm);
        //translate([(lensDiameter)/2,0,0])
        //square([theadDepth, theadDepth], center=true);
}
module 2dArch(dOut, dIn, angle)
{
    if (angle > 180) echo("ERROR: cannot be bigger than 180 degrees if doing threads");
    difference()
    {
        circle(d=dOut);
        circle(d=dIn);
        
        //subtraction of negative angle shits
        polygon(
    }
}





module tz(z)
{
    translate([0,0,z]) children();
}