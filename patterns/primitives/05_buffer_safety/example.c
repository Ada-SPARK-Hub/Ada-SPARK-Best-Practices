/*
 * Common C buffer overflow vulnerabilities
 * WARNING: These examples contain actual buffer overflow bugs!
 */

#include <stdio.h>
#include <string.h>

#define MAX_NAME_LEN 64
#define MAX_BUFFER 128

// Vulnerability 1: Unchecked array indexing
void set_score(int scores[], int index, int value) {
    scores[index] = value;  // ⚠️ No bounds checking!
}

// Vulnerability 2: String copy without bounds check
void copy_name(char *dest, const char *src) {
    strcpy(dest, src);  // ⚠️ Dangerous! No length check
}

// Vulnerability 3: Off-by-one error
void fill_buffer(char *buf, int size, char value) {
    for (int i = 0; i <= size; i++) {  // ⚠️ Should be i < size
        buf[i] = value;
    }
}

// Vulnerability 4: Unchecked user input
void read_into_buffer(char *buf, int max_size) {
    printf("Enter data: ");
    scanf("%s", buf);  // ⚠️ No limit on input size!
}

// Vulnerability 5: Buffer overlap in copy
void shift_data(char *buf, int size, int offset) {
    for (int i = 0; i < size - offset; i++) {
        buf[i] = buf[i + offset];  // ⚠️ Could access past end
    }
}

// Vulnerability 6: Integer overflow leads to buffer overflow
void allocate_and_fill(int count) {
    int buffer_size = count * sizeof(int);  // ⚠️ Could overflow!
    if (buffer_size > 0) {  // Won't catch overflow to negative
        int *buf = (int *)malloc(buffer_size);
        for (int i = 0; i < count; i++) {
            buf[i] = i;  // ⚠️ Writes past allocated memory if overflowed
        }
        free(buf);
    }
}

// SAFE version: Bounded string copy
void safe_copy_name(char *dest, const char *src, size_t dest_size) {
    strncpy(dest, src, dest_size - 1);
    dest[dest_size - 1] = '\0';  // Ensure null termination
}

int main(void) {
    // Example 1: Array overflow
    int scores[5] = {0};
    set_score(scores, 10, 100);  // ⚠️ Index 10 out of bounds!
    printf("This might crash or corrupt memory\n");

    // Example 2: String buffer overflow
    char name[MAX_NAME_LEN];
    const char *long_name = "This is a very long name that definitely exceeds sixty four characters!";
    copy_name(name, long_name);  // ⚠️ Overflow!

    // Example 3: Off-by-one
    char buffer[10];
    fill_buffer(buffer, 10, 'A');  // ⚠️ Writes 11 bytes into 10-byte buffer!

    // Example 4: Safe version
    char safe_name[MAX_NAME_LEN];
    safe_copy_name(safe_name, long_name, MAX_NAME_LEN);
    printf("Safe copy: %.20s...\n", safe_name);

    return 0;
}
