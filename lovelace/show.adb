with Ada.Command_Line, Text_IO, Ada.Strings.Unbounded, Ustrings;
use  Ada.Command_Line, Text_IO, Ada.Strings.Unbounded, Ustrings;

procedure Show is
-- Take each command line argument as a filename and display
-- each file, indented.

  procedure Show_File(Filename : String) is
  -- Open "Filename" and display it, indented.
    File : File_Type;
    Input : Unbounded_String;
  begin
      Put("Printing file ");
      Put_Line(Filename);
      Open(File, In_File, Filename);

      while (not End_Of_File(File)) loop
        Get_Line(File, Input);
        Put(' ');          -- indent.
        Put_Line(Input);
      end loop;
      Close(File);
  end Show_File;

begin -- procedure Show
  if Argument_Count = 0 then
    Put_Line(Current_Error, "Error - No file names given.");
    Set_Exit_Status(Failure);
  else
    -- Open each file and show it.
    for Arg in 1 .. Argument_Count loop
      Show_File(Argument(Arg));
    end loop;
  end if;
end Show;
