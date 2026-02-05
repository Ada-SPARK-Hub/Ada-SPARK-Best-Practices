/*
 * Simple function definitions and calls
 * Demonstrates basic function syntax
 */

#include <stdio.h>

// Function to add two integers
int add(int a, int b) {
    return a + b;
}

// Function to compute absolute value
int abs_value(int x) {
    if (x < 0) {
        return -x;
    }
    return x;
}

// Function with no return value (void)
void print_greeting(void) {
    printf("Hello from a function!\n");
}

int main(void) {
    int result1 = add(5, 3);
    int result2 = abs_value(-42);

    printf("5 + 3 = %d\n", result1);
    printf("abs(-42) = %d\n", result2);

    print_greeting();

    return 0;
}
