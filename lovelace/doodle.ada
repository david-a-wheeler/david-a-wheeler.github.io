
-- "Doodle" by David A. Wheeler

with java.applet.Applet; use java.applet.Applet;
with java.awt.Graphics; use java.awt.Graphics;
with java.awt.Event; use java.awt.Event;
with java.util.Vector; use java.util.Vector;

package Doodle is
  type Doodle_Obj is new Applet_Obj with private;
  type Doodle_Ptr is access all Doodle_Obj'Class;

  procedure init(Obj : access Doodle_Obj);
  function  mouseDown(Obj : access Doodle_Obj; e : Event_Ptr;
                      x : Integer ; y : Integer) return Boolean;
  function  mouseDrag(Obj : access Doodle_Obj; evt : Event_Ptr;
                      x : Integer ; y : Integer) return Boolean;
  procedure paint(Obj : access Doodle_Obj; g : Graphics_Ptr);

private
  type Doodle_Obj is new Applet_Obj with record
     -- Last position drawn:
     Last_X, Last_Y  : Integer := 0;
     -- Store all lines drawn so they can be redrawn:
     Starting_Points, Ending_Points : Vector_Ptr := null;
  end record;
end Doodle;



with interfaces.Java;  use interfaces.Java; -- for "+" on strings
with java.awt.Point; use java.awt.Point;
with java.lang; use java.lang;  -- Defines "Object"

package body Doodle is

  procedure init(Obj : access Doodle_Obj) is
  begin
    -- Initialize applet by setting up vector of start and end points.
    Obj.Starting_Points := new_Vector(100, 100); -- Constructor.
    Obj.Ending_Points   := new_Vector(100, 100);
  end init;

  function mouseDown(Obj : access Doodle_Obj; e : Event_Ptr;
                     x : Integer ; y : Integer) return Boolean is
    -- Memorize where the button was pressed for later use.
  begin
    Obj.Last_X := X;
    Obj.Last_Y := Y;
    return True;  -- "true" means we've handled mouseDown.
  end mouseDown;

  function mouseDrag(Obj : access Doodle_Obj; evt : Event_Ptr;
                     x : Integer ; y : Integer) return Boolean is
    Graphic_Image      : Graphics_Ptr := getGraphics(Obj);
    Starting_Point : Point_Ptr := new_Point(Obj.Last_X, Obj.Last_Y);
    Ending_Point   : Point_Ptr := new_Point(x, y);
    -- Draw a line from last to current point, then store information.
  begin
    drawLine(Graphic_Image, Obj.Last_X, Obj.Last_Y, x, y);
    -- Store the ending position in case the dragging continues.
    Obj.Last_X := x;
    Obj.Last_Y := y;
    -- Store the line drawn so it can be repainted.
    addElement(Obj.Starting_Points, Object_Ptr(Starting_Point));
    addElement(Obj.Ending_Points,   Object_Ptr(Ending_Point));
    return True;  -- "true" means we've handled mouseDrag.
  end mouseDrag;

  procedure paint(Obj : access Doodle_Obj; g : Graphics_Ptr) is
    Starting_Point, Ending_Point : Point_Ptr := null;
      -- Redraw the doodling.
  begin
    for I in 0 .. size(Obj.Starting_Points) - 1 loop
      Starting_Point := Point_Ptr(elementAt(Obj.Starting_Points, I));
      Ending_Point   := Point_Ptr(elementAt(Obj.Ending_Points, I));
      drawLine(g, Starting_Point.x, Starting_Point.y,
                  Ending_Point.x, Ending_Point.y);
    end loop;
  end paint;

end Doodle;

