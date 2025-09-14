#!/bin/sh

# Test grep -C option variations - verify actual context lines displayed

GREP=${GREP:-grep}
SUMMARY=''

echo "Testing ${GREP} -C option variations..."

# Create test file with numbered lines
seq 1 50 > test_input.txt

# Helper function to count context lines around match
check_context() {
    pattern="$1"
    expected="$2"
    output="$3"

# Count lines before and after the match line (line 25)
    before=$(echo "$output" | sed -n '1,/^25$/p' | wc -l)
    after=$(echo "$output" | sed -n '/^25$/,$p' | wc -l)
    before=$(expr $before - 1)  # subtract the match line
    after=$(expr $after - 1)    # subtract the match line

    if [ "$before" -eq "$expected" ] && [ "$after" -eq "$expected" ]; then
        echo "  WORKS: Shows $before lines before and $after lines after"
        return 0
    else
        echo "  FAILS: Shows $before lines before and $after lines after (expected $expected)"
        return 1
    fi
}

echo "=== Testing ${GREP} -C patterns ==="

echo "Test 1: ${GREP} -C4 25 test_input.txt (ATTACHED argument)"
output=$(${GREP} -C4 25 test_input.txt 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$output" ]; then
    check_context "-C4" 4 "$output"
    SUMMARY="$SUMMARY ATTACHED"
else
    echo "  FAILS: Command failed or no output"
fi

echo "Test 2: ${GREP} -C 4 25 test_input.txt (SEPARATE argument)"
output=$(${GREP} -C 4 25 test_input.txt 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$output" ]; then
    check_context "-C 4" 4 "$output"
    SUMMARY="$SUMMARY SEPARATE"
else
    echo "  FAILS: Command failed or no output"
fi

echo "Test 3: ${GREP} -C -i 25 test_input.txt (OPTIONAL argument)"
output=$(${GREP} -C -i 25 test_input.txt 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$output" ]; then
    # This tests if -C accepts -i as its argument and searches for pattern "test_input.txt"
    lines=$(echo "$output" | wc -l)
    echo "  WORKS: -C argument optional, returns $lines lines"
    SUMMARY="$SUMMARY OPTIONAL"
else
    echo "  FAILS: Command failed or requires numeric argument"
fi

echo "Test 4: ${GREP} -C8 -i 25 test_input.txt (Safety check)"
output=$(${GREP} -C8 -i 25 test_input.txt 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$output" ]; then
    check_context "-C8 -i" 8 "$output"
else
    echo "  FAILS: Command failed or no output"
fi

printf '%s\n' "${SUMMARY# }"

# Clean up
rm -f test_input.txt

echo "=== Test complete ==="
