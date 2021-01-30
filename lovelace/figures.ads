package Figures is
 -- Package to demonstrate Object Orientation.

type Point is
   record
      X, Y: Float;
   end record;

type Figure is tagged
   record
      Start : Point;
   end record;
function Area  (F: Figure) return Float;
function Perimeter (F:Figure) return Float;
procedure Draw (F: Figure);

type Circle is new Figure with
   record
      Radius: Float;
   end record;
function  Area (C: Circle) return Float;
function  Perimeter (C: Circle) return Float;
procedure Draw (C: Circle);

type Rectangle is new Figure with
   record
      Width: Float;
      Height: Float;
   end record;
function Area (R: Rectangle) return Float;
function Perimeter (R: Rectangle) return Float;
procedure Draw (R: Rectangle);

type Square is new Rectangle with null record;

end Figures;
