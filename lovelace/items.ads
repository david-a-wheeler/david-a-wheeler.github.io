--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Occupants;
use  Occupants;

package Items is
 type Item     is new Occupant with private;
 type Item_Access       is access Item'Class;
 function May_I_Get(Direct_Object : access Item;
                    Agent : access Occupant'Class) return Boolean;

private
 type Item     is new Occupant with null record;

end Items;

--
-- Permission to use, copy, modify, and distribute this software and its
-- documentation for any purpose and without fee is hereby granted,
-- provided that the above copyright and authorship notice appear in all
-- copies and that both that copyright notice and this permission notice
-- appear in supporting documentation.
-- 
-- The ARA makes no representations about the suitability of this software
-- for any purpose.  It is provided "as is" without express
-- or implied warranty.
-- 
