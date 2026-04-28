#include<types.h>
#include <lib.h>
#include<syscall.h>

int sys_read(int fd, void *buf, size_t nbytes){
    // check if fd does not contain 0 (stdin) return error (-1)
    if(fd != 0)
        return -1;

    // cast the buf pointer to create a charcters pointer
    char * char_buf = (char *)buf;

    // cycle every character in the file array 
    // and store it int the char_buf array via getch
    for(size_t i = 0; i < nbytes; i++)
        char_buf[i] = getch();

    // return written bytes
    return nbytes;
}

int sys_write(int fd, const void *buf, size_t nbytes){
    // check if fd does not contain 1 (stdout) or 2 (stderr) return error (-1)
    if (fd != 1 && fd !=2)
        return -1;

    // cast the buf pointer to create a charcters pointer
    char * char_buf = (char *)buf;

    // cycle every character in the char_buf array and print it via putch
    for(size_t i = 0; i < nbytes; i++)
        putch(char_buf[i]);

    // return written bytes
    return nbytes;
}