  with Unchecked_Deallocation;

  package body Generic_Stack is

    type Stack_Node is record
           Data : Item;
           Next : Stack_Node_Access;
        end record;

    procedure Free is new Unchecked_Deallocation(Stack_Node, Stack_Node_Access);


    procedure Swap(Left : in out Stack; Right : in out Stack) is
      Old_Left_Start : Stack_Node_Access := Left.Start;
      -- Implement by swapping access values to starting point.
    begin
      Left.Start := Right.Start;
      Right.Start := Old_Left_Start;
    end Swap;

    procedure Push(S : in out Stack; I : in  Item) is
      New_Node : Stack_Node_Access := new Stack_Node;
    begin
      New_Node.Data := I;
      New_Node.Next := S.Start;
      S.Start := New_Node;
    end Push;

    procedure Pop (S : in out Stack; I : out Item) is
      Node_To_Remove : Stack_Node_Access := S.Start;
    begin
     if Is_Empty(S) then
       raise Constraint_Error;
     end if;
     I := S.Start.Data;
     S.Start := S.Start.Next;
     Free(Node_To_Remove);
    end Pop;

    procedure Top (S : in out Stack; I : out Item) is
    begin
     if Is_Empty(S) then
       raise Constraint_Error;
     end if;
     I := S.Start.Data;
    end Top;

    procedure Empty(S : in out Stack) is
      Node_To_Remove : Stack_Node_Access := S.Start;
      Next_Node_To_Remove : Stack_Node_Access;
    begin
      S.Start := null; -- Remove the connection to the data.
      -- Now Delete every Stack_Node from the old Stack.
      while Node_To_Remove /= null loop
        Next_Node_To_Remove := Node_To_Remove.Next;
        Node_To_Remove.Next := null;
        Free(Node_To_Remove);
        Node_To_Remove := Next_Node_To_Remove;
      end loop;
    end Empty;

    function Is_Empty(S : in Stack) return Boolean is
    begin
      if S.Start = null then
        return True;
      else
        return False;
      end if;
    end Is_Empty;

    function "="(Left : in Stack; Right : in Stack) return Boolean is
      Left_Node  : Stack_Node_Access := Left.Start;
      Right_Node : Stack_Node_Access := Right.Start;
    begin
      while (Left_Node /= null) and (Right_Node /= null) loop
        if Left_Node.Data /= Right_Node.Data then
          return False;  -- Data differs.
        end if;
        Left_Node  := Left_Node.Next;
        Right_Node := Right_Node.Next;
      end loop;
      --Check to see if both stacks are the same length by verifying
      --that both are null (to exit the loop at least one must be null)

      return Left_Node = Right_Node;
    end "=";


    function Length(S : in Stack) return Natural is
      Count : Natural := 0;
      Current : Stack_Node_Access := S.Start;
    -- This subprogram counts the length "on demand". If requesting
    -- a stack length on non-short-stacks is a common operation,
    -- it would be better to cache this information in the Stack type.
    begin
      while Current /= null loop
        Count := Count + 1;
        Current := Current.Next;
      end loop;
      return Count;
    end Length;

  -- Because "Stack" was defined as a descendent of Controlled, we
  -- have the operations Initialize, Adjust (for assignment) and
  -- Finalize; we can override whichever ones we wish.

  -- We won't override Initialize, because the default initialization
  -- is fine. The default initialization sets the access values to null,
  -- which our implementation will interpret as an empty stack.
  -- We do, however, want to override Adjust and Finalize.

  procedure Adjust(Object : in out Stack) is
    Current_Source_Node      : Stack_Node_Access := Object.Start;
    First_Destination_Node   : Stack_Node_Access;
    Current_Destination_Node : Stack_Node_Access;
  -- Override "Adjust". The default assignment statement just copies
  -- the contents of "Stack", which would produce two access values
  -- pointing to the same data elements.
  -- This Adjust procedure makes separate copies of each data element.
  -- Since we're copying all internal data this is called a "deep copy".
  -- This is a naive approach to assignment -- we could optimize this
  -- to copy only "when necessary".
  begin
    if Current_Source_Node /= null then
      -- There are data elements, let's copy them. Treat first one specially.
      First_Destination_Node := new Stack_Node;
      First_Destination_Node.Data := Current_Source_Node.Data;
      Current_Destination_Node := First_Destination_Node;
      
      -- Copy all of the data nodes after the first one.
      while Current_Source_Node.Next /= null loop
        Current_Destination_Node.Next := new Stack_Node;
        Current_Destination_Node.Next.Data := Current_Source_Node.Next.Data;
        -- We've copied the data; let's move to the next node.
        Current_Source_Node := Current_Source_Node.Next;
        Current_Destination_Node := Current_Destination_Node.Next;
      end loop;
      Current_Destination_Node.Next := null;
      Object.Start := First_Destination_Node;
    end if;
  end Adjust;

  procedure Finalize(Object : in out Stack) is
  -- Override default subprogram to free all the nodes
  -- containing the data.
  begin
    Empty(Object);
  end Finalize;

  end Generic_Stack;

