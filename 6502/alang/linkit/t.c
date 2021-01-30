

struct s_a;

typedef struct s_a  aaaaaa7lalala;
typedef struct s_a *aaaaaap;

struct s_a {
 int a;
};

static aaaaaa7lalala should_be_okay;

main()
{
 should_be_okay.a = 2;
}

