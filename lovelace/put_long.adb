
with Ada.Strings.Unbounded, Text_IO, Ustrings;
use  Ada.Strings.Unbounded, Text_IO, Ustrings;

procedure Put_Long is
  -- Print "long" text lines
  Input : Unbounded_String;
begin
  while (not End_Of_File) loop
    Get_Line(Input);
    if Length(Input) > 10 then
      Put_Line(Input);
    end if;
  end loop;
end Put_Long;

