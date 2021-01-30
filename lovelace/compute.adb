-- Demonstrate a trivial procedure, with another nested inside.
with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
 
procedure Compute is

 procedure Double(Item : in out Integer) is
 begin -- procedure Double.
   Item := Item * 2;
 end Double;

 X : Integer := 1;   -- Local variable X of type Integer.

begin -- procedure Compute
 loop
  Put(X);
  New_Line;
  Double(X);
 end loop;
end Compute;
