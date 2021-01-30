  with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Babble is

  task type Babbler is
    entry Start(Message : Unbounded_String; Count : Natural);
  end Babbler;

end Babble;
