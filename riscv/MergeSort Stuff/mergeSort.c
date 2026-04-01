#include <stdio.h>

int main() {

    void merge_sort(int a[], int length); // merge sort function
    void merge_sort_rec(int a[], int left, int right);
    void merge_sorted_arrays(int a[], int left, int middle, int right);



    int arr[] = {12, 3, 6, 7, 5, 2, 9, 1};
    int length = 10;

    merge_sort(arr, length);

    for (int i = 0; i < length; i++) {
        printf("%d ", arr[i]);
        printf("\n");
    }

    return 0;
}

void merge_sort(int a[], int length) {

    merge_sort_rec(a, 0, length - 1);
}

void merge_sort_rec(int a[], int left, int right) {

    if (left < right) {

    int middle = 1 + (right - 1) / 2;

    merge_sort_rec(a, left, middle);
    merge_sort_rec(a, middle + 1, right);

    merge_sorted_arrays(a, left, middle, right);
    }
}

void merge_sorted_arrays(int a[], int left, int middle, int right) {

    int left_length = middle - left + 1;
    int right_length = right - middle;

    int temp_left_array[left_length];
    int temp_right_array[right_length];

    int i, j, k;

    for (i = 0; i < left_length; i++) {
        temp_left_array[i] = a[left + i];
    }

    for (i = 0; i < right_length; i++) {
        temp_right_array[i] = a[middle + 1 + i];
    }

    for (int i = 0, j = 0, k = left; k <= right; k++) {

        if ((i < left_length) && (j >= right_length || temop_left_array[i] <= temp_right_array[j])) {
            a[k] = temp_left_array[i];
            i++;
        } else {
            a[k] = temp_right_array[j];
            j++;
        }
    }
}
