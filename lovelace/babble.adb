with Ustrings;   use Ustrings;

package body Babble is

 task body Babbler is
   Babble : Unbounded_String;
   Maximum_Count : Natural;
 begin
   accept Start(Message : Unbounded_String; Count : Natural) do
       Babble := Message;      -- Copy the rendezvous data to
       Maximum_Count := Count; -- local variables.
   end Start;
   for I in 1 .. Maximum_Count loop
     Put_Line(Babble);
     delay 1.0;       -- Wait for one second.
   end loop;
   -- We're done, exit task.
 end Babbler;

end Babble;
