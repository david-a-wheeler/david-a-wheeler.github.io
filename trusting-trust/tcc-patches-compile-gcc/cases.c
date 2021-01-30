/* ------------------------------------------------ */
/* cases.c - some tests for tinyc */

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <malloc.h>

#if defined __TINYC__ || defined __GNUC__\
 || defined __LCC__ || defined __DMC__
#define bool _Bool
#endif

#if defined _MSC_VER || defined __BORLANDC__
 #define long_long __int64
 #define LL(n) n##I64
#endif

#ifndef long_long
#define long_long long long
#define LL(n) n##LL
#endif

int some_fn(int x)
{
    return x;
}

int other_fn(int x)
{
    return x*2;
}

void case_1(void)
{
    // must use address of struct in ?:
    struct test { int a, b, c; };
    struct test t0 = {10,20,30};
    struct test t1 = {11,21,31};
    struct test tx = {0,0,0};
    int (*pfn)(int);
    int f = 0;

    tx = f==0 ? t0 : t1;
    printf("case_1.1: 10,20,30 -> %d,%d,%d\n", tx.a, tx.b, tx.c);

    pfn = f ? some_fn : other_fn;
    printf("case_1.2: other -> %s\n", 1==pfn(1)?"some":"other");
}

void case_2(void)
{
    // save_regs before cond-jump
    struct test { int a, b, c; };
    struct test t1 = {0,0,0};
    struct test *p = &t1;
    int f = 0;

    p->b = f==0 || some_fn(0);
    printf("case_2.1: 0 1 0 -> %d %d %d\n", p->a, p->b, p->c);

    p->c = !f || some_fn(0);
    printf("case_2.2: 0 1 1 -> %d %d %d\n", p->a, p->b, p->c);
}

void case_3(void)
{
    // bitfield assignments
    struct test { unsigned a:1, b:1, c:1, d:1; };
    struct test t1 = {0, 1, 0, 1};
    struct test *p = &t1;

    printf("case_3.1: 0101 -> %d%d%d%d\n", p->a, p->b, p->c, p->d);
    p->b = p->d = 0;
    p->a = p->c = 1;
    printf("case_3.2: 1010 -> %d%d%d%d\n", p->a, p->b, p->c, p->d);
}

void case_4(void)
{
    // stringify stuff
    // unresolved issue, tcc does either .1 or .2, but not both
    #define S(a) #a
    printf("case_4.1: \"long long\"  -> \"%s\"\n", S(long  long));
    printf("case_4.2: \"%s\" -> \"%s\"\n", "push%L0", S(push%L0));
    #undef S
}

void case_5(void)
{
    // static must be in global mem
    static void (*pfn)(void);
    printf("case_5: 0 -> %x\n", (unsigned)pfn);
}

void case_6(void)
{
#ifdef bool
    // casts: pointer to short/bool - float to bool
    void *p = (void *)3;
    double f = 0, g = 0.1;
    printf("case_6.1: 3 1 -> %d %d\n",
        (short)p, (bool)p); //warning
    printf("case_6.2: 0 1 0 1 -> %d %d %d %d\n",
        (bool)f, (bool)g, (bool)0.0, (bool)0.1);
#endif
}

void case_7(void)
{
    // incompatible assigment
    struct _s1 { int a, b, c; } *p1 = NULL;
    struct _s2 { int a, b, c; } *p2 = p1; //warning
    printf("case_7: 0 -> %x\n", p2);
}

void case_8(void)
{
#ifdef alloca
    // does alloca mess up the stack when used in a function call?
    // not with tcc, appearantly
    int n = 3;
    char *p = strcpy((char*)alloca(n), "56");
    printf("case_8: \"56\" -> \"%s\"\n", p);
#endif
}

void case_9(void)
{
    // function pointer indirection
    int (*pfn)(int) = some_fn;
    printf("case_9: %x (7,8) -> %x (%d,%d)\n",
        some_fn, *pfn, pfn(7), (******pfn)(8));
}

void case_10(void)
{
    // double -> ull cast
    double d = 2.4e18;
    unsigned long_long ull = d;
    unsigned long_long r = LL(100000000000);
    printf("case_10: %.0f -> %ld\n", d/r, (long)(ull/r));
}

int main(int argc, char **argv)
{
    case_1();
    case_2();
    case_3();
    case_4();
    case_5();
    case_6();
    case_7();
    case_8();
    case_9();
    case_10();
    return 0;
}

