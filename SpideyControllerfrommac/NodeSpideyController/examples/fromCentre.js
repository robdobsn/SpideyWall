xCentre = 250;
yCentre = 375;
theGenIdx = 0;

getColour = function(x, y, genIdx) 
{
    var distFromCentre = Math.sqrt((x - xCentre) * (x - xCentre) + (y - yCentre) * (y - yCentre));
    colorIdx = distFromCentre + (100000 - genIdx) * 15;
    var colr = "#";
    var colAr = [];
    for (var i = 0; i <= 2; i++) 
    {
        colAr.push(Math.abs((Math.floor(colorIdx) + (i * 152)) % 256 - 128) + 30);
        colr += ("00" + colAr[i].toString(16)).substr(-2);
    }
    var colrStr = "rgba(" + colAr[0].toString() + "," + colAr[1].toString() + "," + colAr[2].toString() + ",1.0)";
    return colrStr;
};

draw = function()
{
    for (var ledIdx = 0; ledIdx < LEDS.length; ledIdx++)
    {
        led = LEDS[ledIdx];
        // led.colour = "#" + ("00" + podge.toString()).slice(-2) + "0402";
        led.colour = getColour(led.centre.x, led.centre.y, theGenIdx);
    
    }    
    show();
    theGenIdx++;
}