#include <stdio.h>

int foo(int n)
{
        printf("world\n");
        return n;
}

int main(int argc, char *argv[])
{
        int n;

        printf("hello\n");
        
        n = 42;
        foo(n);
}
