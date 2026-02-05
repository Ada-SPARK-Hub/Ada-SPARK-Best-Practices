/*
 * Function parameter modes
 * Demonstrates pass by value and pass by reference
 */

#include <stdio.h>

// Pass by value (C default)
int increment(int x) {
    x = x + 1;  // Modifies local copy only
    return x;
}

// Pass by reference using pointers
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// Multiple output values via pointers
void divide_with_remainder(int dividend, int divisor, int *quotient, int *remainder) {
    *quotient = dividend / divisor;
    *remainder = dividend % divisor;
}

int main(void) {
    // Test increment (pass by value)
    int x = 5;
    int result = increment(x);
    printf("Original x: %d, Result: %d\n", x, result);  // x unchanged

    // Test swap (pass by reference)
    int a = 10, b = 20;
    printf("Before swap: a=%d, b=%d\n", a, b);
    swap(&a, &b);
    printf("After swap: a=%d, b=%d\n", a, b);

    // Test multiple outputs
    int quot, rem;
    divide_with_remainder(17, 5, &quot, &rem);
    printf("17 / 5 = %d remainder %d\n", quot, rem);

    return 0;
}
