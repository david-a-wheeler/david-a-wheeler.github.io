--
-- Copyright (C) 1996 Ada Resource Association (ARA), Columbus, Ohio.
-- Author: David A. Wheeler
--

with Creatures;
use  Creatures;

package Monsters is
 type Monster is new Creature with private;
 type Monster_Access    is access Monster'Class;
private
 type Monster is new Creature with null record;
end Monsters;

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
