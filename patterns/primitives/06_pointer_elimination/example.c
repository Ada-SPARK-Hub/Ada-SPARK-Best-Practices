/*
 * Pointer patterns and their elimination
 * Shows common C pointer usage and safer alternatives
 */

#include <stdio.h>
#include <string.h>

// Pattern 1: Output parameters via pointers
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// Pattern 2: Multiple return values via pointers
void div_mod(int dividend, int divisor, int *quotient, int *remainder) {
    *quotient = dividend / divisor;
    *remainder = dividend % divisor;
}

// Pattern 3: Array modification via pointer
void increment_all(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        arr[i]++;
    }
}

// Pattern 4: Pointer arithmetic for array access
int sum_range(int *arr, int start, int end) {
    int sum = 0;
    int *ptr = arr + start;  // Point to start
    int *end_ptr = arr + end;  // Point to end

    while (ptr <= end_ptr) {
        sum += *ptr;
        ptr++;  // Move to next element
    }
    return sum;
}

// Pattern 5: String manipulation with pointers
int string_length(const char *str) {
    const char *p = str;
    while (*p != '\0') {
        p++;
    }
    return p - str;  // Pointer subtraction
}

// Pattern 6: Passing struct by pointer for efficiency
typedef struct {
    int x;
    int y;
} Point;

int manhattan_distance(const Point *p1, const Point *p2) {
    int dx = p1->x - p2->x;
    int dy = p1->y - p2->y;
    return (dx >= 0 ? dx : -dx) + (dy >= 0 ? dy : -dy);
}

int main(void) {
    // Test swap
    int a = 5, b = 10;
    printf("Before swap: a=%d, b=%d\n", a, b);
    swap(&a, &b);
    printf("After swap: a=%d, b=%d\n", a, b);

    // Test div_mod
    int quot, rem;
    div_mod(17, 5, &quot, &rem);
    printf("17 / 5 = %d remainder %d\n", quot, rem);

    // Test increment_all
    int arr[] = {1, 2, 3, 4, 5};
    increment_all(arr, 5);
    printf("After increment: ");
    for (int i = 0; i < 5; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    // Test sum_range
    int total = sum_range(arr, 1, 3);  // Sum indices 1-3
    printf("Sum of indices 1-3: %d\n", total);

    // Test string_length
    const char *str = "Hello";
    printf("Length of '%s': %d\n", str, string_length(str));

    // Test manhattan_distance
    Point p1 = {0, 0};
    Point p2 = {3, 4};
    printf("Manhattan distance: %d\n", manhattan_distance(&p1, &p2));

    return 0;
}
