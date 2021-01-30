/*
 * Demonstrate that at least one Unix-like system's open() returns EINVAL
 * if the filename it's given is invalid.  This demonstrates that there is
 * a precedence for rejecting filenames with certain patterns, and for
 * the error value that is returned.
 *
 * Specifically, Fedora 10 (running Linux kernel version
 * 2.6.27.19-170.2.35.fc10.i686)'s open() returns EINVAL if a program
 * attempts to create a filename on a mounted MS-DOS system with characters
 * that are illegal on an MS-DOS filesystem. 
 *
 * Run this program, and setup, as root.
 *
 * Before running this program, set up as follows:
 * dd count=500 if=/dev/zero of=/tmp/test-mkfs
 * mkdosfs /tmp/test-mkfs
 * mkdir -p /mnt/test-mkfs
 * mount -t msdos -o loop /tmp/test-mkfs /mnt/test-mkfs/
 *
 * Then run the program. On Linux, this fails with:
 *  OPEN FAILED, errno=22
 *  EINVAL=22
 *  bad-filename-test: Invalid argument
 *
 * If you unmount the filesystem (e.g., "umount /dev/loop0") and re-run,
 * on a typical Linux system this will succeed:
 *  OPEN SUCCEEDED
 *
 */

#include <stdio.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <errno.h>


main()
{
  int fd;
  /* Try to create a file with a really hideous name: */
  fd = open("/mnt/test-mkfs/h$\004 *<", O_WRONLY | O_CREAT );
  if (fd == -1) {
    printf("OPEN FAILED, errno=%d\n", errno);
    printf("EINVAL=%d\n", (int) EINVAL, (int) EACCES);
    perror("bad-filename-test");
  } else {
    printf("OPEN SUCCEEDED\n");
    close(fd);
  }
}
