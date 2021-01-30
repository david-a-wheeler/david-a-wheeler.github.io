/* bin2text - Read binary data (stdin), output 1 byte/line as text (stdout) */
/* by David A. Wheeler */
/* Compile using: gcc bin2text.c -o bin2text */

#include <stdio.h>

main() {
    int c;
    while ((c = getchar()) != EOF) {
        printf("%02x", c & 0xff);
        if ( (((unsigned) c) > 0x20) && (((unsigned) c) <= 0x7e)) {
            printf(" = %c", c );
        }
        printf("\n");
    }
}
