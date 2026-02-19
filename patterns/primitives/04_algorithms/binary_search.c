/*
 * Binary Search Algorithm
 * Classic example needing loop invariants for correctness proof
 */

#include <stdio.h>
#include <stdbool.h>

// Binary search in sorted array
// Returns index if found, -1 if not found
int binary_search(int arr[], int size, int target) {
    int left = 0;
    int right = size - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;  // Avoid overflow

        if (arr[mid] == target) {
            return mid;  // Found
        }
        else if (arr[mid] < target) {
            left = mid + 1;  // Search right half
        }
        else {
            right = mid - 1;  // Search left half
        }
    }

    return -1;  // Not found
}

// Simpler but overflow-prone version
int binary_search_naive(int arr[], int size, int target) {
    int left = 0;
    int right = size - 1;

    while (left <= right) {
        int mid = (left + right) / 2;  // ⚠️ Could overflow if left+right > INT_MAX

        if (arr[mid] == target) {
            return mid;
        }
        else if (arr[mid] < target) {
            left = mid + 1;
        }
        else {
            right = mid - 1;
        }
    }

    return -1;
}

// Helper: Check if array is sorted
bool is_sorted(int arr[], int size) {
    for (int i = 0; i < size - 1; i++) {
        if (arr[i] > arr[i + 1]) {
            return false;
        }
    }
    return true;
}

int main(void) {
    int arr[] = {1, 3, 5, 7, 9, 11, 13, 15, 17, 19};
    int size = sizeof(arr) / sizeof(arr[0]);

    printf("Array: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    printf("Is sorted: %s\n", is_sorted(arr, size) ? "yes" : "no");

    // Test searches
    int targets[] = {7, 19, 1, 10, 20, -5};
    int num_targets = sizeof(targets) / sizeof(targets[0]);

    for (int i = 0; i < num_targets; i++) {
        int target = targets[i];
        int index = binary_search(arr, size, target);

        if (index >= 0) {
            printf("Found %d at index %d\n", target, index);
        } else {
            printf("%d not found\n", target);
        }
    }

    return 0;
}
