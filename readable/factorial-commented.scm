 define factorial(n)         ; Parameters can be indented, but need not be
   if (n < 1)                ; Supports infix, prefix, &amp; function &lt;=(n 1)
       1                     ; This has no parameters, so it's an atom.
       n * factorial(n - 1)  ; Function(...) notation supported
