  with Ada.Finalization; use Ada.Finalization;

  generic
    type Item is private;  -- This is the data type to be stacked.

  package Generic_Stack is
    -- This implements a simple generic stack of Items.
    -- (C) 1996 David A. Wheeler.

    type Stack is new Controlled with private;
     -- Stack type. Assignment copies the contents of one Stack into another,
     -- and might copy each Item in the Stack.
     -- You can inherit from Stack and overload its controlled operations.
    type Stack_Access is access all Stack'Class;
     -- standard access type.
    function "="(Left : in Stack; Right : in Stack) return Boolean;
     -- Stacks are equal if lengths equal and each item in order is equal.
    procedure Swap(Left : in out Stack; Right : in out Stack);
     -- Swap the contents of the two stacks.

    procedure Push(S : in out Stack; I : in  Item);
    procedure Pop (S : in out Stack; I : out Item);
     -- Pop raises Constraint_Error if Is_Empty(Stack).
    procedure Top (S : in out Stack; I : out Item);
     -- Top copies, but does not Pop, the topmost element. 
     -- Top raises Constraint_Error if Is_Empty(Stack).
    procedure Empty(S : in out Stack); -- Empties the given Stack

    function Is_Empty(S : in Stack) return Boolean; -- True if Empty.
    function Length(S : in Stack) return Natural; -- returns 0 if Empty

    -- Permission is granted to use this package in any way you wish under
    -- the condition that the author (David A. Wheeler) is given credit.
    -- NO WARRANTIES, EITHER EXPRESS OR IMPLIED, APPLY.

  private 
    type Stack_Node;
    type Stack_Node_Access is access Stack_Node;
    type Stack is new Controlled with record
          Start : Stack_Node_Access;
        end record;
    procedure Adjust(Object : in out Stack);
    procedure Finalize(Object : in out Stack);
  end Generic_Stack;

