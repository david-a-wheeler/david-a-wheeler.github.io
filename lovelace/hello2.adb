-- Print a simple message to demonstrate a trivial Ada program.
with Ada.Text_IO;
use Ada.Text_IO;  -- use clause - automatically search Ada.Text_IO.
procedure Hello2 is
begin
 Put_Line("Hello, world!"); -- Note: No longer has "Ada.Text_IO" in front.
end Hello2;
