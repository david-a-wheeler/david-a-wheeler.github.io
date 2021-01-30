#!/bin/env python
# smart-alphanumeric-sort: Demo the "smart alphanumeric" comparison algorithm.
# (C) Copyright 2004-12-15 David A. Wheeler
# See my web page for more: http://www.dwheeler.com
#
# The "smart alphanumeric sort" comparison algorithm lets you sort
# values that have both digits and non-digits in them in a useful manner.
# It attempts to emulate how a human might sort identifiers that aren't
# simply numbers.
# It's particularly useful for sorting part numbers, version numbers,
# document section numbers, legal references ("10 USC 5"), IP addresses,
# and filenames with version tags, date markers, or consecutive numeric
# markers (such as those used by some digital cameras).
#
# Similar work by: http://sourcefrog.net/projects/natsort/
# "Natural order string comparison", with references to others.
#
# The problem this algorithm solves is that
# typical alphanumeric sorting produces results that are odd to many
# people for many situations.  For example, an alphanumeric sort would take
# ['A-11', 'A-5', 'A-10', 'A-1'], sort it, and produce:
#    ['A-1', 'A-10', 'A-11', 'A-5'].
# Notice that 'A-10' is between A-1 and A-5!
#
# In contrast, the smart-alphanumeric-sort/comparison algorithm
# described here produces:
#    ['A-1', 'A-5', 'A-10', 'A-11'].
# Notice that A-5 is between A-1 and A-10, like many would expect.
#
# Since it incorporates an alphanumeric sort, this algorithm also has all the
# normal alphanumeric sort options such as strict ASCII/Unicode order,
# traditional fold-English-case (A-Z are considered equal to a-z),
# and lexigraphic order.  Note that this last option is locale-dependent,
# because different cultures sort alphabetic characters differently.
# The implementation here uses strict ASCII/Unicode order, and I
# recommend that as a useful default, but other implementations
# could support other or all of those options.
#
# This algorithm is not a replacement for a numeric sort if your data has
# negative numbers with "-" signs, separators, floating point values,
# or "+" signs that are not always used.
# In particular, it's not at all a replacement if you have floating point
# values; "1.2" will sort before "1.12", and that's by design
# (because subversion 12 of 1 really IS larger than subversion 2).
# It does, however, work as a numeric sort if you only
# have non-negative integers, and it works for arbitrary length values.
# It also works when sorting non-negative floating point numbers, IF
# all numbers include the decimal point and exactly the same number of
# digits after the decimal point (e.g., "1.20", "1.11" works, but
# it produces "1.2, "1.11" because 2 is less than 11).
#
# HOW IT WORKS:
# This compares two values by comparing them character-by-character, as
# a traditional alphabetic sort, unless BOTH values have a digit
# (0 through 9) in the equivalent place.
# If one hits a digit, and the other doesn't, the value with
# the digit is considered smaller, and comparison ends.
# Otherwise the set of digits starting there, for both values,
# is considered as a unit and compared as an integer.
# To compare as an integer, simply group all digits (0-9), and
# ignore leading zeros (if we didn't, "04" would be larger than "4").
# Then, if one set of digits has more characters than the
# other, that set is larger.  If the two sets have the same length,
# they're compared alphabetically (this means arbitrary-length numbers can be
# handled).  If they're still considered the same, but they have a different
# number of leading zeros, the "number" with more leading zeros is
# considered larger.   If they're still equal, then the comparison
# continues starting with the corresponding characters after the numbers.
# If, after doing this repeatedly, one or both values run out of characters,
# then the string with more characters in it is larger
# (this means that a string with zero length is smaller than anything else).
# Otherwise, they're equal.
#
# Obviously, you could create many variants to this algorithm.
# I've tried to define a very specific algorithm, so that different
# implementations could be used to generate data and produce
# the same answer (so they could be directly compared).
#
# A particularly debatable part of the algorithm is how it handles
# leading zeros.  Normally leading zeros are ignored.  This turns
# out to be really helpful; because of the problems of traditional sorting,
# people often insert leading zeros, but then they sometimes exceed what
# they planned; ignoring leading zeros handles this very gracefully.
# Thus, 'A-0001', 'A-9999', 'A-10000' sorts just like you'd expect.
#
# An even more debatable part is that, when the numbers are identical,
# the 'number' with more leading zeros is considered larger.
# Leading zeros in numbers are typically usually only used to fill out for
# traditional sorting, and you wouldn't expect to have two numbers
# differ only by leading zeros.  In this case, it's quite possible that
# the leading zero has some meaning other than its traditional numeric
# value, and that in fact the leading zero has real meaning.
# If it has real meaning, then it should NOT be considered equal!
# By considering the number of leading zeros as relevant in this
# one special case, potentially very different values are
# clearly sorted as being different.
#
# This algorithm implements a few variations on the theme, that I
# used for experimentation.  Feel free to experiment as well.
#
# This is the result of a lot of experimentation.
# One key question is how to handle initial zeros in the numbers;
# other is how to handle the various whitespace characters.
#
# This strips initial and final whitespace of values before comparison,
# and treat 1+ whitespace characters (including nonbreaking space, newline,
# carriage return, tab, space, etc.) the same as 1 space.
# After all, humans would have trouble differentiating
# them, so let's sort them as though that wasn't relevant.
#
# IDEA: every time there's a transition between number/non-number,
# should that be treated like a space?  After all, some
# people wouldn't perceive of a difference between
# "10 USC 5" and "10USC5", though other spaces would be perceived
# ("5 10" != "510, and "A B" != "AB").
#
# Requirements:
# * Must not require review of dataset to determine heuristics
# * Must be able to sort chapter headings (1, 1.1, 1.1.1, ... 1.1.9, 1.1.10).
# * Must be flexible - useful for many kinds of data, with little tweaking
# * Must sort 'like a human would'

digits = '0123456789'

drop_leading_zeros    = True
leading_zeros_trump   = False
leading_zeros_tiebreak = False
compress_whitespace = True

print 'drop_leading_zeros: ', drop_leading_zeros
print 'leading_zeros_trump: ', leading_zeros_trump
print 'leading_zeros_tiebreak: ', leading_zeros_tiebreak
print 'strip_values: ', strip_values

# The following is NOT an optimal implementation;
# its purpose is to demonstrate the results, as well as to support
# experimentation.
# It's the result of much experimentation.
def smart_alphanumeric_cmp(x,y):
    """Compare x,y; returns -1 if x<y, 0 if x==y, 1 if x>y"""
    # Strip left & right ends of strings, and replace all sequences of
    # one or more whitespace characters with a single space character:
    if compress_whitespace:
        x = " ".join(x.split())
        y = " ".join(y.split())
    # Returns 1 if x>y, 0 if x==y, -1 if x<y.
    lenx = len(x)
    leny = len(y)
    xposition = 0 # Current position being examined in x.
    yposition = 0 # Current position being examined in y.
    while xposition < lenx and yposition < leny:
        xchar = x[xposition]
        ychar = y[yposition]
        xcharisdigit = xchar in digits
        ycharisdigit = ychar in digits
        if (not xcharisdigit) and (not ycharisdigit):
            # CHANGE THIS to get case folding or locale-dependent sorting:
            if xchar != ychar: return cmp(xchar, ychar)
            # Characters are equal, we'll fall through and try the next one
        elif xcharisdigit and not ycharisdigit: return -1 # Number < non-number
        elif ycharisdigit and not xcharisdigit: return 1  # Number < non-number
        else:  # Do "numeric" comparison.
            startx = xposition
            if drop_leading_zeros:
                while startx < lenx and x[startx] == '0': # Skip leading 0s.
                    startx += 1
            endx = startx
            while endx < lenx and x[endx] in digits: # find last digit.
                endx += 1
            # We've found x's digits; now find y's digits.
            starty = yposition
            if drop_leading_zeros:
                while starty < leny and y[starty] == '0': # Skip leading 0s.
                    starty += 1
            endy = starty
            while endy < leny and y[endy] in digits: # find last digit.
                endy += 1
            if leading_zeros_trump: # More leading zeros => SMALLER
                if (startx - xposition) != (starty - yposition):
                    # print "Compare: x", x[startx:endx], "x  with ", (startx-xposition), "zeros; versus y", y[starty:endy], "y with ", (starty-yposition), " zeros; compare is", (-1 * cmp(startx - xposition, starty - yposition))
                    return -1 * cmp(startx - xposition, starty - yposition)
            # We now have the x and y ranges of digits, ignoring leading zeros
            # (values endx and endy point "one beyond" end position).
            # If different length, longer > shorter (e.g., '10' > '2'):
            if (endx - startx) != (endy - starty):
                return cmp(endx - startx, endy - starty)
            # They're equal length, so compare the digits alphabetically.
            # This works as a numeric sort because in ASCII, Unicode, etc.,
            # the digits are sorted numerically to start with ('1' > '0').
            compare = cmp(x[startx:endx],y[starty:endy])
            if compare != 0: return compare
            # Special case: if the numbers otherwise compare as equal,
            # but the number of leading zeros is different, consider the
            # number with more leading zeros as SMALLER.
            if leading_zeros_tiebreak:
                if (startx - xposition) != (starty - yposition):
                    return -1 * cmp(startx - xposition, starty - yposition)
            # The numbers are equal; fall through to try the next characters.
        xposition += 1  # Move to next character.
        yposition += 1  # Move to next character.
    # Every character tested was equal, and one string has ended:
    if   lenx > leny: return  1 # Longer string considered larger
    elif leny > lenx: return -1 # Longer string considered larger
    return 0 # The strings are identical.




# First, a few quick tests to make sure it's reasonable.
# Remember, cmp returns -1 if x<y, 0 if x==y, 1 if x>y

assert smart_alphanumeric_cmp('0','1') == -1
assert smart_alphanumeric_cmp('1','0') == 1
assert smart_alphanumeric_cmp('0','0') == 0
assert smart_alphanumeric_cmp('A','B') == -1
assert smart_alphanumeric_cmp('A','AA') == -1
assert smart_alphanumeric_cmp('A1','A2') == -1
assert smart_alphanumeric_cmp('A0','A1') == -1
assert smart_alphanumeric_cmp('A2','A10') == -1
assert smart_alphanumeric_cmp('1.2.1','1.2.2') == -1
assert smart_alphanumeric_cmp('1.2.1','1.10.1') == -1
# assert smart_alphanumeric_cmp(' A ', 'A') == 0

print 'Here are some examples of sorted results:'

test = ['A', 'B', 'D', 'C']
test.sort(smart_alphanumeric_cmp)
print test

test = ['A', 'Al', 'All', 'Alo', 'Ala', 'Abner', 'Abs']
test.sort(smart_alphanumeric_cmp)
print test


test = ['A-11', 'A-5', 'A-10', 'A-1']
test.sort(smart_alphanumeric_cmp)
print test

test = ['A-11', 'B-2', 'A-5', 'A-10', 'A-1', 'A-1-5', 'A-10-2', 'A-1-42', \
         'A-10-15']
test.sort(smart_alphanumeric_cmp)
print test

test = ['A-5', 'A-1-5']
test.sort(smart_alphanumeric_cmp)
print test

# Note: This works differently if you ignore leading zeros.
test = ['A-005', 'A-6', 'A-4']
test.sort(smart_alphanumeric_cmp)
print test

test = ['A-005', 'A-5', 'A-10', 'A-1']
test.sort(smart_alphanumeric_cmp)
print test


# Things don't work well if there's a decimal point and a varying
# number of digits after the "."/",". You need a real numerical sorting
# algorithm for that.  See GNU sort for how to do that with character compares.
test = ['0.90', '1.00', '1.20', '1.01', '1.001', '1.1']
test.sort(smart_alphanumeric_cmp)
print test

# But this DOES work well if the number of digits after the decimal point
# is always kept the same.
test = ['0.90', '1.00', '1.20', '1.01', '1.10', '1.02', '1.11', '1.21', '1.19',
        '1.90', '2.00', '0.00']
test.sort(smart_alphanumeric_cmp)
print test

test = ['0.9', '0.1', '1', '1.1', '0.99', '1.12', '1.04', '1.12315413123',
        '1.2', '2', '1.90', '2.00', '0.00']
test.sort(smart_alphanumeric_cmp)
print test

test = ['1.1.1', '1.0', '0.9.9', '0.9.9a', '1.1.1-aac', '1.2', \
        '1.1.9', '1.1.10', '1.20', '1.18', '1.8', '1.10', '1.10.1', '2']
test.sort(smart_alphanumeric_cmp)
print test

test = ['A-1', 'AB-2', 'B-1', 'AA-1']
test.sort(smart_alphanumeric_cmp)
print test

# Spreadsheet cell ids work too
test = ['A1', 'A2', 'B1', 'AA1', 'AA2', 'AA9', 'AA10']
test.sort(smart_alphanumeric_cmp)
print test

test = ['', '000', '0', 'a', 'A', '004', '4']
test.sort(smart_alphanumeric_cmp)
print test

test = [' x ', 'x']
test.sort(smart_alphanumeric_cmp)
print test

# Not intended for this use.  Negative numbers get grouped together
# after the unsigned and '+' signed values, and are sorted
# in ascending order ignoring the '-' sign:
# test = ['-1', '-2', '-10', '0', '1', '2', '10', '11', '+1', '+5', '+10']
# test.sort(smart_alphanumeric_cmp)
# print test

