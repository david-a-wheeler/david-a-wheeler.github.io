
with Ada.Strings.Unbounded, Ustrings,
      Text_IO, Ada.Integer_Text_IO;
use  Ada.Strings.Unbounded, Ustrings,
      Text_IO, Ada.Integer_Text_IO;

procedure Unbound is -- Demonstrate Unbounded_String.
  Input : Unbounded_String;
  Stop  : constant Unbounded_String := To_Unbounded_String("stop");
begin
  Put_Line("Please type 'stop' to end this program.");

  loop
    New_Line;
    Put_Line("Please type in a line:");
    Get_Line(Input);

  exit when (Input = Stop);

    Put("You just typed in:"); Put_Line(Input);

    Put("This input line contains ");
    Put(Length(Input));
    Put_Line(" characters.");

    for I in reverse 1 .. Length(Input) loop
      Put(Element(Input, I));
    end loop;
    New_Line;

  end loop;
end Unbound;
