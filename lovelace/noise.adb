with Babble, Ustrings;
use  Babble, Ustrings;
 
procedure Noise is
  Babble_1 : Babbler;  -- Create a task.
  Babble_2 : Babbler;  -- Create another task.
begin
  -- At this point we have two active tasks, but both of them
  -- are waiting for a "Start" message. So, send them a Start.
  Babble_1.Start(U("Hi, I'm Babble_1"), 10);
  Babble_2.Start(U("And I'm Babble_2"), 6);
end Noise;

