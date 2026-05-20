; Symbol array (pointers to key names, index = scancode)
sym_arr dw 0                ; scancode 00
        dw sym_esc          ; 01
        dw sym_1, sym_2, sym_3, sym_4, sym_5, sym_6, sym_7, sym_8, sym_9, sym_0
        dw sym_minus, sym_equal, sym_bksp, sym_tab, sym_q, sym_w, sym_e, sym_r
        dw sym_t, sym_y, sym_u, sym_i, sym_o, sym_p, sym_lbracket, sym_rbracket
        dw sym_enter, sym_ctrl, sym_a, sym_s, sym_d, sym_f, sym_g, sym_h, sym_j
        dw sym_k, sym_l, sym_semicolon, sym_quote, sym_backtick, sym_lshift
        dw sym_backslash, sym_z, sym_x, sym_c, sym_v, sym_b, sym_n, sym_m
        dw sym_comma, sym_period, sym_slash, sym_rshift, sym_prtsc, sym_alt
        dw sym_space, sym_capslk, sym_f1, sym_f2, sym_f3, sym_f4, sym_f5, sym_f6
        dw sym_f7, sym_f8, sym_f9, sym_f10, sym_numlk, sym_scrl, sym_home, sym_up
        dw sym_pgup, sym_minus_num, sym_left, sym_5_num, sym_right, sym_plus_num
        dw sym_end, sym_down, sym_pgdn, sym_ins, sym_del, sym_shift_f1, sym_shift_f2
        dw sym_shift_f3, sym_shift_f4, sym_shift_f5, sym_shift_f6, sym_shift_f7
        dw sym_shift_f8, sym_shift_f9, sym_shift_f10, sym_ctrl_f1, sym_ctrl_f2
        dw sym_ctrl_f3, sym_ctrl_f4, sym_ctrl_f5, sym_ctrl_f6, sym_ctrl_f7
        dw sym_ctrl_f8, sym_ctrl_f9, sym_ctrl_f10, sym_alt_f1, sym_alt_f2
        dw sym_alt_f3, sym_alt_f4, sym_alt_f5, sym_alt_f6, sym_alt_f7, sym_alt_f8
        dw sym_alt_f9, sym_alt_f10, sym_ctrl_prtsc, sym_ctrl_left, sym_ctrl_right
        dw sym_ctrl_end, sym_ctrl_pgdn, sym_ctrl_home, sym_alt_1, sym_alt_2
        dw sym_alt_3, sym_alt_4, sym_alt_5, sym_alt_6, sym_alt_7, sym_alt_8
        dw sym_alt_9, sym_alt_0, sym_alt_minus, sym_alt_equal, sym_ctrl_pgup
        dw sym_f11, sym_f12, sym_shift_f11, sym_shift_f12, sym_ctrl_f11, sym_ctrl_f12
        dw sym_alt_f11, sym_alt_f12, sym_ctrl_up, sym_ctrl_minus_num, sym_ctrl_5_num
        dw sym_ctrl_plus_num, sym_ctrl_down, sym_ctrl_ins, sym_ctrl_del, sym_ctrl_tab
        dw sym_ctrl_slash_num, sym_ctrl_star_num, sym_alt_home, sym_alt_up, sym_alt_pgup
        dw sym_alt_left, sym_alt_right, sym_alt_end, sym_alt_down, sym_alt_pgdn
        dw sym_alt_ins, sym_alt_del, sym_alt_slash_num, sym_alt_tab, sym_alt_enter_num
        dw sym_alt_enter, sym_alt_escape  ; up to FF, fill unused with 0

; Key name strings (null‑terminated)
sym_esc        db 'ESC;',0
sym_1          db '1;',0
sym_2          db '2;',0
sym_3          db '3;',0
sym_4          db '4;',0
sym_5          db '5;',0
sym_6          db '6;',0
sym_7          db '7;',0
sym_8          db '8;',0
sym_9          db '9;',0
sym_0          db '0;',0
sym_minus      db '-;',0
sym_equal      db '=;',0
sym_bksp       db 'BKSP;',0
sym_tab        db 'Tab;',0
sym_q          db 'Q;',0
sym_w          db 'W;',0
sym_e          db 'E;',0
sym_r          db 'R;',0
sym_t          db 'T;',0
sym_y          db 'Y;',0
sym_u          db 'U;',0
sym_i          db 'I;',0
sym_o          db 'O;',0
sym_p          db 'P;',0
sym_lbracket   db '[;',0
sym_rbracket   db '];',0
sym_enter      db 'Enter;',0
sym_ctrl       db 'Ctrl;',0
sym_a          db 'A;',0
sym_s          db 'S;',0
sym_d          db 'D;',0
sym_f          db 'F;',0
sym_g          db 'G;',0
sym_h          db 'H;',0
sym_j          db 'J;',0
sym_k          db 'K;',0
sym_l          db 'L;',0
sym_semicolon  db ';;',0
sym_quote      db "';",0
sym_backtick   db '`;',0
sym_lshift     db 'L SH;',0
sym_backslash  db '\\;',0
sym_z          db 'Z;',0
sym_x          db 'X;',0
sym_c          db 'C;',0
sym_v          db 'V;',0
sym_b          db 'B;',0
sym_n          db 'N;',0
sym_m          db 'M;',0
sym_comma      db ',;',0
sym_period     db '.;',0
sym_slash      db '/;',0
sym_rshift     db 'R SH;',0
sym_prtsc      db 'PtScr;',0
sym_alt        db 'Alt;',0
sym_space      db 'Spc;',0
sym_capslk     db 'CpsLk;',0
sym_f1         db 'F1;',0
sym_f2         db 'F2;',0
sym_f3         db 'F3;',0
sym_f4         db 'F4;',0
sym_f5         db 'F5;',0
sym_f6         db 'F6;',0
sym_f7         db 'F7;',0
sym_f8         db 'F8;',0
sym_f9         db 'F9;',0
sym_f10        db 'F10;',0
sym_numlk      db 'Num Lk;',0
sym_scrl       db 'Scrl Lk;',0
sym_home       db 'Home;',0
sym_up         db 'Up Arrow;',0
sym_pgup       db 'Pg Up;',0
sym_minus_num  db '- (num);',0
sym_left       db 'Left Arrow;',0
sym_5_num      db '5 (num);',0
sym_right      db 'Rt Arrow;',0
sym_plus_num   db '+ (num);',0
sym_end        db 'End;',0
sym_down       db 'Dn Arrow;',0
sym_pgdn       db 'Pg Dn;',0
sym_ins        db 'Ins;',0
sym_del        db 'Del;',0
sym_shift_f1   db 'SH F1;',0
sym_shift_f2   db 'SH F2;',0
sym_shift_f3   db 'SH F3;',0
sym_shift_f4   db 'SH F4;',0
sym_shift_f5   db 'SH F5;',0
sym_shift_f6   db 'SH F6;',0
sym_shift_f7   db 'SH F7;',0
sym_shift_f8   db 'SH F8;',0
sym_shift_f9   db 'SH F9;',0
sym_shift_f10  db 'SH F10;',0
sym_ctrl_f1    db 'Ctrl F1;',0
sym_ctrl_f2    db 'Ctrl F2;',0
sym_ctrl_f3    db 'Ctrl F3;',0
sym_ctrl_f4    db 'Ctrl F4;',0
sym_ctrl_f5    db 'Ctrl F5;',0
sym_ctrl_f6    db 'Ctrl F6;',0
sym_ctrl_f7    db 'Ctrl F7;',0
sym_ctrl_f8    db 'Ctrl F8;',0
sym_ctrl_f9    db 'Ctrl F9;',0
sym_ctrl_f10   db 'Ctrl F10;',0
sym_alt_f1     db 'Alt F1;',0
sym_alt_f2     db 'Alt F2;',0
sym_alt_f3     db 'Alt F3;',0
sym_alt_f4     db 'Alt F4;',0
sym_alt_f5     db 'Alt F5;',0
sym_alt_f6     db 'Alt F6;',0
sym_alt_f7     db 'Alt F7;',0
sym_alt_f8     db 'Alt F8;',0
sym_alt_f9     db 'Alt F9;',0
sym_alt_f10    db 'Alt F10;',0
sym_ctrl_prtsc db 'Ctrl PtScr;',0
sym_ctrl_left  db 'Ctrl Left;',0
sym_ctrl_right db 'Ctrl Rt;',0
sym_ctrl_end   db 'Ctrl End;',0
sym_ctrl_pgdn  db 'Ctrl PgDn;',0
sym_ctrl_home  db 'Ctrl Home;',0
sym_alt_1      db 'Alt 1;',0
sym_alt_2      db 'Alt 2;',0
sym_alt_3      db 'Alt 3;',0
sym_alt_4      db 'Alt 4;',0
sym_alt_5      db 'Alt 5;',0
sym_alt_6      db 'Alt 6;',0
sym_alt_7      db 'Alt 7;',0
sym_alt_8      db 'Alt 8;',0
sym_alt_9      db 'Alt 9;',0
sym_alt_0      db 'Alt 0;',0
sym_alt_minus  db 'Alt -;',0
sym_alt_equal  db 'Alt =;',0
sym_ctrl_pgup  db 'Ctrl PgUp;',0
sym_f11        db 'F11;',0
sym_f12        db 'F12;',0
sym_shift_f11  db 'SH F11;',0
sym_shift_f12  db 'SH F12;',0
sym_ctrl_f11   db 'Ctrl F11;',0
sym_ctrl_f12   db 'Ctrl F12;',0
sym_alt_f11    db 'Alt F11;',0
sym_alt_f12    db 'Alt F12;',0
sym_ctrl_up    db 'Ctrl Up;',0
sym_ctrl_minus_num db 'Ctrl - (num);',0
sym_ctrl_5_num db 'Ctrl 5 (num);',0
sym_ctrl_plus_num db 'Ctrl + (num);',0
sym_ctrl_down  db 'Ctrl Dn;',0
sym_ctrl_ins   db 'Ctrl Ins;',0
sym_ctrl_del   db 'Ctrl Del;',0
sym_ctrl_tab   db 'Ctrl Tab;',0
sym_ctrl_slash_num db 'Ctrl / (num);',0
sym_ctrl_star_num db 'Ctrl * (num);',0
sym_alt_home   db 'Alt Home;',0
sym_alt_up     db 'Alt Up;',0
sym_alt_pgup   db 'Alt PgUp;',0
sym_alt_left   db 'Alt Left;',0
sym_alt_right  db 'Alt Rt;',0
sym_alt_end    db 'Alt End;',0
sym_alt_down   db 'Alt Dn;',0
sym_alt_pgdn   db 'Alt PgDn;',0
sym_alt_ins    db 'Alt Ins;',0
sym_alt_del    db 'Alt Del;',0
sym_alt_slash_num db 'Alt / (num);',0
sym_alt_tab    db 'Alt Tab;',0
sym_alt_enter_num db 'Alt Enter (num);',0
sym_alt_enter  db 'Alt Enter;',0
sym_alt_escape db 'Alt ESC;',0


esym_rsh       db 'RSH+', 0
esym_lsh       db 'LSH+', 0
esym_ctrl       db 'CTRL+', 0
esym_alt       db 'ALT+', 0

