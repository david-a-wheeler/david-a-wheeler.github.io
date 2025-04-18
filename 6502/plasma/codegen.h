#define EDASM   1
void emit_flags(int flags);
int optimization(int level);
void pushya(void);
void vsp_save(void);
void vsp_restore(void);
void emit_header(void);
void emit_comment(char *s);
void emit_asm(char *s);
void emit_idlocal(char *name, int value);
void emit_idglobal(int value, int size, char *name);
void emit_idfunc(int value, char *name);
void emit_idconst(char *name, int value);
int emit_data(int vartype, int consttype, long constval, int constsize);
void emit_codetag(int tag);
void emit_const(int cval);
void emit_lb(void);
void emit_lw(void);
void emit_llb(int index);
void emit_llw(int index);
void emit_lab(int tag);
void emit_law(int tag);
void emit_sb(void);
void emit_sw(void);
void emit_slb(int index);
void emit_slw(int index);
void emit_dlb(int index);
void emit_dlw(int index);
void emit_sab(int tag);
void emit_saw(int tag);
void emit_dab(int tag);
void emit_daw(int tag);
void emit_call(int tag, int cparams);
void emit_ical(int cparams);
void emit_localaddr(int index);
void emit_globaladdr(int tag, int type);
void emit_globaladdrofst(int tag, int offset, int type);
void emit_indexbyte(void);
void emit_indexword(void);
int emit_unaryop(int op);
int emit_op(t_token op);
void emit_brtru(int tag);
void emit_brfls(int tag);
void emit_brgt(int tag);
void emit_brlt(int tag);
void emit_brne(int tag);
void emit_jump(int tag);
void emit_dup(void);
void emit_over(void);
void emit_drop(void);
void emit_leave(int framesize);
void emit_def(int defopt);
void emit_enter(int framesize, int cparams);
void emit_start(void);
void emit_exit(void);
