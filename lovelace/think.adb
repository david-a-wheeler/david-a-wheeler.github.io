 with Ada.Float_Text_IO;
 use Ada.Float_Text_IO;
 procedure Think is
   A, B : Float := 0.0; -- A and B initially zero; note the period.
   I, J : Integer := 1;
 begin
   A := B + 7.0;
   I := J * 3;
   B := Float(I) + A;
   Put(B);
 end Think;
