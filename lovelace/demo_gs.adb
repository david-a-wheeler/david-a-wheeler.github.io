
with Stack_Int;
use  Stack_Int;

procedure Demo_GS is
 -- Demonstrate the use of the Generic_Stack package by using a
 -- Stack of Integers.

 Stack1, Stack2 : Stack;
 Dummy : Integer;
begin
 Push(Stack1, 1); -- Put 1 onto Stack1.
 Push(Stack1, 2); -- Put 2 onto the Stack1.
 Stack2 := Stack1; -- Copy stack1's contents into stack2.
 Pop(Stack2, Dummy); -- Dummy is now 2.
 Pop(Stack2, Dummy); -- Dummy is now 1.
 --  Now Stack2 is empty and Stack1 has two items.
end Demo_GS;
