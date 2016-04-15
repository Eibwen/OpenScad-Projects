$fn=50;

lensDiameter=50;
lensThickness=2;

theadDepth=1;
threadThickness=2;

ledWidth=8;

totalDepth=lensThickness+lensThickness+ledWidth; //top and bottom lens


outerCaseThickness=1.2;
lipToHoldGlass=1;



theadDiameterAdd=theadDepth*2;

//if ((lipDiameter+.5) < ((theadDiameterAdd+outerCaseThickness)/2))
//    echo("WARNING: lipDiameter should be larger than (theadDiameterAdd+outerCaseThickness)", (lipDiameter+.5)," < ",(theadDiameterAdd+outerCaseThickness)/2);

TWEAK=0.001;
TWEAK2=TWEAK*2;



OuterCase();
OuterThread();
//2dArch(dIn=lensDiameter-theadDiameterAdd, dOut=lensDiameter, angle=1/(theadDepth*2)*360);

//DEBUGGING lipToHoldGlass
//translate([-lensDiameter/2,0,11])
//    cube([1,1,1]);



module OuterCase()
{
    outerCaseInnerDiameter=lensDiameter+theadDiameterAdd;
    lipDiameter=lipToHoldGlass+theadDepth+(outerCaseThickness/2);
    %tz(totalDepth) _lip(outerCaseInnerDiameter+outerCaseThickness, lipDiameter);
    
    difference()
    {
        cylinder(d=outerCaseInnerDiameter+outerCaseThickness, h=totalDepth);
        tz(-TWEAK)
        cylinder(d=outerCaseInnerDiameter, h=totalDepth+TWEAK2);
    }
    
    //Hold TOP lens in place (so threads don't mess with it)
    lensTolerance=.2;
    color("lightblue") tz(totalDepth-lensThickness-TWEAK)
    difference()
    {
        cylinder(d=lensDiameter+lensTolerance+theadDepth*2, h=lensThickness);
        tz(-TWEAK)
        cylinder(d=lensDiameter+lensTolerance, h=lensThickness+TWEAK2);
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
    threadRatio=1/2.5; //Figure this will give enough room to work maybe TODO TWEAK THIS
    
    angle=totalDepth*threadRatio/(threadThickness)*360;
    anglePerMm=threadRatio*360;
    echo(anglePerMm);
    linear_extrude(totalDepth, twist=angle)
        2dArch(dOut=lensDiameter+theadDiameterAdd, dIn=lensDiameter, angle=anglePerMm);
        //This way could make a stretched out elipse that would give round threads
}
module 2dArch(dOut, dIn, angle)
{
    if (angle > 180) echo("ERROR: cannot be bigger than 180 degrees if doing threads");
    difference()
    {
        circle(d=dOut);
        circle(d=dIn);
        
        //subtraction of negative angle shits
        _pacman(angle, dOut/2);
    }
}
module _pacman(angle, minRadius)
{
    //Using this method to make it simpler, since this is designed to just be a mask
    //  For other uses change 30 to 1 or less
    stepSize=30;
    radius=minRadius/cos(30/2);
    points = [ for (i = [0 : 30 : 360-angle]) [radius*sin(i), radius*cos(i)] ];
    allPoints = concat([[0,0]], points, [[radius*sin(360-angle), radius*cos(360-angle)]]);
    polygon(allPoints);
}





module tz(z)
{
    translate([0,0,z]) children();
}