with Stack_Int, Text_IO; use Stack_Int, Text_IO;

procedure Test_Generic_Stack is
 -- Test the generic "Generic_Stack" using "Stack_Int" as an instantiation.
 -- If all is okay, print "No failures."

 Stack1, Stack2 : Stack;
 Dummy : Integer;

 Count_Of_Failures : Integer := 0;

 procedure Failure(Error_Message : in String) is
   -- call if there was a failure.
 begin
   Put("Failure: ");
   Put_Line(Error_Message);
   Count_Of_Failures := Count_Of_Failures + 1;
 end Failure;

 procedure Assert(Claim : in Boolean; Error_Message : in String) is
   -- If Claim is not true, print the error message.
 begin
   if not Claim then
     Failure(Error_Message);
   end if;
 end Assert;

begin
 -- Put the Stack type through a number of tests.

 Assert(Is_Empty(Stack1), "Stack does not start empty");
 Assert(Stack1 = Stack2,  "Stacks start different");

 Push(Stack1, 1);
 Push(Stack1, 2);
 Push(Stack1, 3);

 Assert(Stack1 /= Stack2,   "Stacks same after pushing");
 Assert(Length(Stack1) = 3, "Stack1 not length 3"); 
 Assert(Length(Stack2) = 0, "Stack2 not length 0"); 

 Swap(Stack1, Stack2);
 Assert(Length(Stack1) = 0, "Post-swap: Stack1 not length 0"); 
 Assert(Length(Stack2) = 3, "Post-swap: Stack2 not length 3"); 

 Swap(Stack1, Stack2);
 Assert(Length(Stack1) = 3, "Double swap: Stack1 not length 3"); 
 Assert(Length(Stack2) = 0, "Double swap: Stack2 not length 0"); 

 Stack2 := Stack1;
 Assert(Length(Stack2) = 3, "Stack2 not length 3 after assignment!"); 
 Assert(Stack1 = Stack2,    "Stacks differ after assignment");

 Pop(Stack1, Dummy);
 Assert(Dummy = 3, "Did't get 3 back from Stack1");
 Assert(Stack1 /= Stack2, "Stacks same after popping a value from Stack1");

 Pop(Stack1, Dummy);
 Assert(Dummy = 2, "Did't get 2 back from Stack1");

 Pop(Stack1, Dummy);
 Assert(Dummy = 1, "Did't get 1 back from Stack1");
 Assert(Is_Empty(Stack1), "Stack1 does not end up empty");
 Assert(not Is_Empty(Stack2), "Stack2 unexpectedly empty");
 Assert(Stack1 /= Stack2, "Stacks same after popping just Stack1");

 Pop(Stack2, Dummy);
 Assert(Dummy = 3, "Did't get 3 back from Stack2");
 Assert(Stack1 /= Stack2, "Stacks same after popping a value from Stack2");

 Pop(Stack2, Dummy);
 Assert(Dummy = 2, "Did't get 2 back from Stack2");

 Pop(Stack2, Dummy);
 Assert(Dummy = 1, "Did't get 1 back from Stack2");
 Assert(Is_Empty(Stack2), "Stack2 does not end up empty");
 Assert(Stack1 = Stack2, "Empty stacks differ");

 -- Empty an empty stack.
 Empty(Stack2);
 Assert(Is_Empty(Stack2), "Empty on Empty failed");

 -- Empty with one element.
 Push(Stack2, 1);
 Empty(Stack2);
 Assert(Is_Empty(Stack2), "Empty on one element failed.");

 -- Empty with two elements.
 Push(Stack2, 1);
 Push(Stack2, 2);
 Empty(Stack2);
 Assert(Is_Empty(Stack2), "Empty on two elements failed.");

 Push(Stack2, 12);
 Top(Stack2, Dummy);
 Assert(Dummy = 12, "Top failed.");
 Assert(Length(Stack2) = 1, "Top didn't leave one item on the stack.");

 Empty(Stack1);
 Assert(Is_Empty(Stack1), "Last Empty of Stack1 failed");
 Empty(Stack2);
 Assert(Is_Empty(Stack2), "Last Empty of Stack2 failed");

 -- All done.
 if (Count_Of_Failures = 0) then
   Put_Line("No failures.");
 else
   Put_Line("Failures Occurred.");
 end if;
end Test_Generic_Stack;
