
with Text_IO;
use  Text_IO;

procedure Make_Hi is
  New_File : File_Type;
begin
  Create(New_File, Out_File, "hi");
  Put_Line(New_file, "Hi, this is a test!");
  Close(New_File);
end Make_Hi;
