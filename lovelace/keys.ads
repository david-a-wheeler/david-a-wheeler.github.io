 package Keys is
   type Key is private;
   Null_Key : constant Key;         -- a deferred constant.
   procedure Get_Key(K : out Key);  -- Get a new Key value.
   function "<"(X, Y : in Key) return Boolean; -- True if X requested
                                                  -- before Y was
 private                                -- start package's private part.
   Max_Key  : constant := 2 ** 16 - 1;  -- A private constant.
   type Key is range 0 .. Max_Key;      -- Completed type definition.
   Null_Key : constant Key := 0;        -- Completed constant.
 end Keys;
