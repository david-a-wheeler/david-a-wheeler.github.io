with Text_IO; use Text_IO;
with Ada.Characters.Handling; use Ada.Characters.Handling;

procedure Yes_No is
  Response : Character;
begin
  Put("Would you like me to say Hello?");
  Get(Response);  -- Get first character.
  if (To_Lower(Response) = 'y') then
    Put("Hello!");
  else
    Put("Okay, I won't.");
  end if;
end Yes_No;
