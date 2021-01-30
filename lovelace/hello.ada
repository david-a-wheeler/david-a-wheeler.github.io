
-- A "hello world" applet by Tucker Taft:

with java.applet.Applet; use java.applet.Applet;
with java.awt.Graphics; use java.awt.Graphics;
package Hello is
    type Hello_Obj is new Applet_Obj with null record;
    procedure paint(Obj : access Hello_Obj; g : Graphics_Ptr);
end Hello;

with interfaces.Java; use interfaces.Java; -- for "+" on strings
package body Hello is
    procedure paint(Obj : access Hello_Obj; g : Graphics_Ptr) is
    begin
        drawString(g, +"Hello, Java world!", x => 10, y => size(Obj).height/2);
    end paint;
end Hello;

