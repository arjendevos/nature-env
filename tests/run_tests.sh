#!/bin/bash
# run_tests.sh - Build and run all nature-env tests
set -e

cd "$(dirname "$0")"

# Create symlinks to library source files
ln -sf ../main.n lib.n
ln -sf ../parser.n parser.n
ln -sf ../utils.n utils.n

TESTS=(
    test_basic
    test_quotes
    test_expansion
    test_comments
    test_export
    test_escape
    test_marshal
    test_load
    test_edge_cases
    test_helpers
)

PASSED=0
FAILED=0
ERRORS=""

for test in "${TESTS[@]}"; do
    echo ""
    echo "=== Building ${test} ==="
    if nature build -o "${test}" "${test}.n" 2>&1; then
        echo "=== Running ${test} ==="
        if ./"${test}" 2>&1; then
            PASSED=$((PASSED + 1))
        else
            FAILED=$((FAILED + 1))
            ERRORS="${ERRORS}\n  - ${test} (runtime failure)"
        fi
        rm -f "./${test}"
    else
        FAILED=$((FAILED + 1))
        ERRORS="${ERRORS}\n  - ${test} (build failure)"
    fi
done

# Clean up
rm -f fixtures/write_test.env lib.n parser.n utils.n

echo ""
echo "==============================="
echo "  Results: ${PASSED} passed, ${FAILED} failed"
if [ $FAILED -gt 0 ]; then
    echo -e "  Failures:${ERRORS}"
    echo "==============================="
    exit 1
else
    echo "  All tests passed!"
    echo "==============================="
fi
