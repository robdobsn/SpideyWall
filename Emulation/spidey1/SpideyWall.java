import greenfoot.*;  // (World, Actor, GreenfootImage, Greenfoot and MouseInfo)

/**
 * Write a description of class SpideyWall here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class SpideyWall extends World
{

    /**
     * Constructor for objects of class SpideyWall.
     * 
     */
    public SpideyWall()
    {    
        // Create a new world with 600x400 cells with a cell size of 1x1 pixels.
        super(436, 628, 1); 

        prepare();
    }

    /**
     * Prepare the world for the start of the program. That is: create the initial
     * objects and add them to the world.
     */
    private void prepare()
    {
        LineTracer linetracer = new LineTracer();
        addObject(linetracer, 9, 618);
    }
}
