global softmax_pass
extern output

section .data
softmax: times 4 dd 0.0
exp_tmp: times 4 dd 0.0
sum_exp: dd 0.0
tokens:  db "ABCD"

section .text
softmax_pass:
    finit
    xor rcx, rcx

.calc_exp_loop:
    cmp rcx, 4
    jge .sum_exp

    fld dword [output + rcx*4]
    call exp_approx
    fst dword [exp_tmp + rcx*4]
    inc rcx
    jmp .calc_exp_loop

.sum_exp:
    fldz
    xor rcx, rcx               
.sum_loop:
    cmp rcx, 4
    jge .norm_softmax
    fld dword [exp_tmp + rcx*4]
    faddp st1, st0
    inc rcx
    jmp .sum_loop

.norm_softmax:
    fst dword [sum_exp]
    xor rcx, rcx
.norm_loop:
    cmp rcx, 4
    jge .argmax
    fld dword [exp_tmp + rcx*4]
    fld dword [sum_exp]
    fdivp st1, st0
    fst dword [softmax + rcx*4]
    inc rcx
    jmp .norm_loop

.argmax:
    xor rcx, rcx
    xor rbx, rbx
    fld dword [softmax]

.argmax_loop:
    inc rcx
    cmp rcx, 4
    jge .print_token
    fld dword [softmax + rcx*4]
    fcomi st0, st1
    ja .update_max
    fstp st0
    jmp .argmax_loop

.update_max:
    fstp st0
    fld dword [softmax + rcx*4]
    mov rbx, rcx
    jmp .argmax_loop

.print_token:
    mov rax, 1
    mov rdi, 1
    mov rsi, tokens
    add rsi, rbx
    mov rdx, 1
    syscall
    ret

exp_approx:
    
    fld st0             
    fld st0             
    fmul st0, st1       
    fld st0             
    fmul st0, st1       

    fld1                
    fld st3
    faddp st1, st0

    fld1
    faddp st1, st0

    fld st2
    fld1
    fld1
    faddp st1, st0
    fdiv
    faddp st1, st0

    fld st2
    fld1
    fld1
    fld1
    faddp st1, st0
    fdiv
    faddp st1, st0

    fxch st2
    fstp st0
    fstp st0
    ret