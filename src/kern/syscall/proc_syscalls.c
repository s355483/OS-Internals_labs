#include<types.h>
#include <current.h>
#include<thread.h>

void sys__exit(int exitcode){
    // save exit code inside current thread
    curthread->t_exitcode = exitcode;

    // kill the thread
    thread_exit();
}