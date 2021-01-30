with Text_IO, Ada.Integer_Text_IO;
use  Text_IO, Ada.Integer_Text_IO;
procedure Print_Squares is
 X : Integer;
begin
 loop
  Get(X);
 exit when X = 0;
  Put(X * X);
  New_Line;
 end loop;
end Print_Squares;
