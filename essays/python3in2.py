#!/usr/bin/python

from __future__ import print_function, unicode_literals
from __future__ import absolute_import, division

try:
   xrange = xrange
   # Python 2
   print("Python 2")
except:
   xrange = range
   print("Python 3")


print("Hello","x","there")
print(1/2)

