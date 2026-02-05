/*
 * Basic arithmetic operations
 * Demonstrates operators and integer arithmetic
 */

#include <stdio.h>

int main(void) {
    int a = 10;
    int b = 3;

    // Basic operations
    int sum = a + b;
    int difference = a - b;
    int product = a * b;
    int quotient = a / b;      // Integer division
    int remainder = a % b;      // Modulo

    // Compound assignments
    int x = 5;
    x += 2;  // x = x + 2
    x *= 3;  // x = x * 3

    // Print results
    printf("a = %d, b = %d\n", a, b);
    printf("Sum: %d\n", sum);
    printf("Difference: %d\n", difference);
    printf("Product: %d\n", product);
    printf("Quotient: %d\n", quotient);
    printf("Remainder: %d\n", remainder);
    printf("x after operations: %d\n", x);

    return 0;
}
