#include <stdio.h>

/* Demos that sprintf's "%.*s" format does NOT prevent buffer overflow */


#define BUFSIZE 3

main() {
 char buf[10];
 buf[0] = 'x';
 /* Before I'd used "BUFSIZ" and that messed up the test! */
 sprintf(buf, "%.*s", sizeof(buf)-1, "this-is-a-demo");
 printf("The string using .* is: %s\n", buf);

 buf[0] = '\0';
 sprintf(buf, "%.3s", "this-is-a-demo");
 printf("The string using .3 is: %s\n", buf);
}
