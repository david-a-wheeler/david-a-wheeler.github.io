
void error(s)
char *s;
{
puts("Error:");
puts(s);
}

void fatal(s)
char *s;
{
puts("FATAL ");
error(s);
abort();
}


