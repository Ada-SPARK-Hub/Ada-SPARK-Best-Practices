/*
 * Array operations with bounds checking
 * Demonstrates array declaration, initialization, and access
 */

#include <stdio.h>

#define ARRAY_SIZE 5

// Function to sum array elements
int sum_array(int arr[], int size) {
    int sum = 0;
    for (int i = 0; i < size; i++) {
        sum += arr[i];
    }
    return sum;
}

// Function to find maximum element
int find_max(int arr[], int size) {
    int max = arr[0];
    for (int i = 1; i < size; i++) {
        if (arr[i] > max) {
            max = arr[i];
        }
    }
    return max;
}

int main(void) {
    // Array declaration and initialization
    int numbers[ARRAY_SIZE] = {10, 25, 3, 47, 15};

    // Access elements
    printf("First element: %d\n", numbers[0]);
    printf("Last element: %d\n", numbers[ARRAY_SIZE - 1]);

    // Iterate and print
    printf("All elements: ");
    for (int i = 0; i < ARRAY_SIZE; i++) {
        printf("%d ", numbers[i]);
    }
    printf("\n");

    // Use functions
    int total = sum_array(numbers, ARRAY_SIZE);
    int maximum = find_max(numbers, ARRAY_SIZE);

    printf("Sum: %d\n", total);
    printf("Maximum: %d\n", maximum);

    return 0;
}
