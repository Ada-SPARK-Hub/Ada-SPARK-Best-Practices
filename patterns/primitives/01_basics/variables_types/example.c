/*
 * Variable declarations and basic types
 * Demonstrates type declarations and initialization
 */

#include <stdio.h>

int main(void) {
    // Integer types
    int x = 42;
    unsigned int count = 10;

    // Floating point
    float temperature = 98.6;
    double precise_value = 3.14159265359;

    // Character
    char letter = 'A';

    // Boolean (C99)
    _Bool is_valid = 1;

    // Print values
    printf("Integer: %d\n", x);
    printf("Unsigned: %u\n", count);
    printf("Float: %.1f\n", temperature);
    printf("Double: %.11f\n", precise_value);
    printf("Char: %c\n", letter);
    printf("Bool: %d\n", is_valid);

    return 0;
}
