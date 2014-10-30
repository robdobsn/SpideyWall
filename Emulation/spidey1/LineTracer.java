import greenfoot.*;  // (World, Actor, GreenfootImage, Greenfoot and MouseInfo)
import java.awt.Color;

/**
 * Write a description of class LineTracer here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class LineTracer extends Actor
{
    /**
     * Act - do whatever the LineTracer wants to do. This method is called whenever
     * the 'Act' or 'Run' button gets pressed in the environment.
     */
    Color padColor = new Color(230,230,230);
    Color lineColor = new Color(20,20,20);
    int dx = 1;
    int dy = 0;
    
    boolean foundEdge = false;
    
    public void act()
    {
        Color clr = getWorld().getBackground().getColorAt(getX(), getY());
        // If the 
        if (!clr.equals(padColor))
        {
            getWorld().getBackground().setColorAt(getX(), getY(), lineColor);
            goLeft();
        }
        else
        {
            setLocation(getX() + 1, getY());
        }
        
        getWorld().getBackground().setColor(Color.white);
        getWorld().getBackground().fillRect(100, 0, 350, 10);
        getWorld().getBackground().setColor(Color.black);
        getWorld().getBackground().drawString("clr = " + clr + " " + dx + " " + dy, 100, 10);
    }    
  
    void goLeft()
    {
        int x = getX();
        int y = getY();
        int tdx = dx;
        int tdy = dy;
        int wid = getWorld().getBackground().getWidth();
        int hig = getWorld().getBackground().getHeight();

        // If at edge turn right
        if (x == 0)
        {
            if (y == 0)
            {
                tdx = 1;
                tdy = 0;
            }
            else
            {
                tdy = -1;
                tdx = 0;
            }
        }
        else if (x == wid-1)
        {
            if (y == hig-1)
            {
                tdx = -1;
                tdy = 0;
            }
            else
            {
                tdy = 1;
                tdx = 0;
            }
        }
        else if (y == 0)
        {
            tdy = 1;
            tdx = 0;
        }
        else if (x == wid-1)
        {
            if (y == hig-1)
            {
                tdx = -1;
                tdy = 0;
            }
            else
            {
                tdy = 1;
                tdx = 0;
            }
        }
        
        int i = 0;
        for (i = 0; i < 3; i++)
        {
            if (tdx == 1)
            {
                tdx = 0;
                tdy = -1;
            }
            else if ((tdx == 0) && (tdy == -1))
            {
                tdx = -1;
                tdy = 0;
            }
            else if (tdx == -1)
            {
                tdx = 0;
                tdy = 1;
            }
            else if ((tdx == 0) && (tdy == 1))
            {
                tdx = 1;
                tdy = 0;
            }
                    
            Color nxtPix = getWorld().getBackground().getColorAt(x+tdx, y+tdy);
            if (!(nxtPix.equals(padColor) || nxtPix.equals(lineColor)))
            {
                break;
            }
        }

        dx = tdx;
        dy = tdy;
        setLocation(x+tdx, y+tdy);

    }
    
}
