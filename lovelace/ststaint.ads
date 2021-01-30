with Generic_Stack, Stack_Int;
 -- Instantiate a Stack of Stacks of Integers.

package Stack_Stack_Int is new Generic_Stack(Stack_Int.Stack);
