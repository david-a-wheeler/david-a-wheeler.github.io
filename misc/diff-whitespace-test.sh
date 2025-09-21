#!/bin/bash

# Test script for diff -B and -w options with Unicode whitespace characters
# Usage: DIFF='busybox diff' ./diff-whitespace-test.sh (to test busybox)
#        ./diff-whitespace-test.sh (to test default diff)

DIFF="${DIFF:-diff}"

# Unicode whitespace characters (hex values)
whitespace_chars=(
    "9"    "A"    "B"    "C"    "D"    "20"   "85"   "A0"
    "1680" "2000" "2001" "2002" "2003" "2004" "2005" "2006"
    "2007" "2008" "2009" "200A" "2028" "2029" "202F" "205F"
    "3000"
)

# Character names for reference
char_names=(
    "TAB" "LF" "VT" "FF" "CR" "SPACE" "NEL" "NBSP"
    "OGHAM_SPACE" "EN_QUAD" "EM_QUAD" "EN_SPACE" "EM_SPACE" "THREE_PER_EM"
    "FOUR_PER_EM" "SIX_PER_EM" "FIGURE_SPACE" "PUNCTUATION_SPACE" "THIN_SPACE"
    "HAIR_SPACE" "LINE_SEP" "PARA_SEP" "NARROW_NBSP" "MEDIUM_MATH_SPACE" "IDEOGRAPHIC_SPACE"
)

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

echo "Testing diff command: $DIFF"
echo "Testing all 25 Unicode whitespace characters"
echo "=============================================="

# Generate test files with each whitespace character
for i in "${!whitespace_chars[@]}"; do
    hex="${whitespace_chars[$i]}"
    name="${char_names[$i]}"

    file1="$tmpdir/test_${hex}_1.txt"
    file2="$tmpdir/test_${hex}_2.txt"

    # Create files: one with whitespace char, one with regular space
    printf "line1\ntest\u${hex}word\nline3\n" > "$file1"
    printf "line1\ntest word\nline3\n" > "$file2"
done

# Test -w option on all whitespace characters
echo -e "\nTesting -w option with each Unicode whitespace character:"
echo "Character that -w treats as equivalent to space:"

w_equivalent=()
w_different=()

for i in "${!whitespace_chars[@]}"; do
    hex="${whitespace_chars[$i]}"
    name="${char_names[$i]}"

    file1="$tmpdir/test_${hex}_1.txt"
    file2="$tmpdir/test_${hex}_2.txt"

    if $DIFF -w "$file1" "$file2" >/dev/null 2>&1; then
        w_equivalent+=("U+${hex} (${name})")
    else
        w_different+=("U+${hex} (${name})")
    fi
done

echo "Equivalent to space with -w:"
for char in "${w_equivalent[@]}"; do
    echo "  ✓ $char"
done

echo -e "\nNOT equivalent to space with -w:"
for char in "${w_different[@]}"; do
    echo "  ✗ $char"
done

# Test -B option with blank lines containing each whitespace
echo -e "\n\nTesting -B option with blank lines containing each whitespace:"
echo "Characters that -B ignores in blank lines:"

b_ignored=()
b_not_ignored=()

for i in "${!whitespace_chars[@]}"; do
    hex="${whitespace_chars[$i]}"
    name="${char_names[$i]}"

    file1="$tmpdir/blank_${hex}_1.txt"
    file2="$tmpdir/blank_${hex}_2.txt"

    # Create files: both with blank lines, one empty, one with just whitespace char
    printf "line1\n\nline3\n" > "$file1"
    printf "line1\n\u${hex}\nline3\n" > "$file2"

    if $DIFF -B "$file1" "$file2" >/dev/null 2>&1; then
        b_ignored+=("U+${hex} (${name})")
    else
        b_not_ignored+=("U+${hex} (${name})")
    fi
done

echo "Ignored by -B in blank lines:"
for char in "${b_ignored[@]}"; do
    echo "  ✓ $char"
done

echo -e "\nNOT ignored by -B in blank lines:"
for char in "${b_not_ignored[@]}"; do
    echo "  ✗ $char"
done

# Test -B with multiple completely blank lines
echo -e "\n\nTesting -B with multiple completely blank lines:"
file1="$tmpdir/multiblank_1.txt"
file2="$tmpdir/multiblank_2.txt"

printf "line1\nline2\n" > "$file1"
printf "line1\n\n\n\nline2\n" > "$file2"

echo "Two lines vs same lines with 3 blank lines between:"
echo "Without -B:"
if $DIFF "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

echo "With -B:"
if $DIFF -B "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

# Test -Bw combination with whitespace-only lines
echo -e "\n\nTesting -Bw combination with whitespace-only lines:"

# Test 1: Lines with only spaces/tabs vs empty lines
file1="$tmpdir/bw_test1_1.txt"
file2="$tmpdir/bw_test1_2.txt"
printf "line1\n   \n\t\nline2\n" > "$file1"  # Lines with spaces and tabs only
printf "line1\nline2\n" > "$file2"           # No blank lines

echo "Lines with spaces/tabs vs no blank lines:"
echo "With -B only:"
if $DIFF -B "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

echo "With -w only:"
if $DIFF -w "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

echo "With -Bw:"
if $DIFF -Bw "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

# Test 2: Different amounts of whitespace in blank lines
file1="$tmpdir/bw_test2_1.txt"
file2="$tmpdir/bw_test2_2.txt"
printf "line1\n  \nline2\n" > "$file1"      # Line with 2 spaces
printf "line1\n\t\t\t\nline2\n" > "$file2"  # Line with 3 tabs

echo -e "\nBlank line with 2 spaces vs blank line with 3 tabs:"
echo "With -B only:"
if $DIFF -B "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

echo "With -w only:"
if $DIFF -w "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

echo "With -Bw:"
if $DIFF -Bw "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

file1="$tmpdir/bw_test4_1.txt"
file2="$tmpdir/bw_test4_2.txt"
printf "line1\nline2\n" > "$file1"
printf "line1\n\t\t\t\n  \n\t \n\nline2\n" > "$file2"

echo "With -Bw, different number of lines:"
if $DIFF -Bw "$file1" "$file2" >/dev/null 2>&1; then
    echo "  Files are identical"
else
    echo "  Files differ"
fi

# Summary
echo -e "\n\n=============================================="
echo "SUMMARY:"
echo "=============================================="
echo "-w option: ${#w_equivalent[@]}/25 whitespace chars treated as equivalent to space"
echo "-B option: ${#b_ignored[@]}/25 whitespace chars ignored in blank lines"
echo "-B with multiple blank lines: Completely empty lines are ignored"
echo "-Bw combination: Tests whether whitespace-only lines can be ignored when combined"
