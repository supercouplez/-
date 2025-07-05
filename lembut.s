global softmax_pass
extern output

section .data
softmax: times 4 dd 0.0
exp_tmp: times 4 dd 0.0
sum_exp: dd 0.0
tokens:  db "ABCD"
two:     dq 2.0
six:     dq 6.0

section .text
softmax_pass:
    finit

    fld dword [output]
    xor rcx, rcx
    inc rcx
.find_max:
    cmp rcx, 4
    jge .store_max
    fld dword [output + rcx*4]
    fcomip st0, st1
    ja .update_max
    fstp st0
    inc rcx
    jmp .find_max
.update_max:
    fstp st1
    inc rcx
    jmp .find_max
.store_max:
    fstp dword [sum_exp]

    ; ===== exp(output[i] - max) =====
    xor rcx, rcx
.exp_loop:
    cmp rcx, 4
    jge .sum_exp
    fld dword [output + rcx*4]
    fld dword [sum_exp]
    fsubp st1, st0
    call exp_approx
    fstp dword [exp_tmp + rcx*4]
    inc rcx
    jmp .exp_loop

.sum_exp:
    fldz
    xor rcx, rcx
.sum_loop:
    cmp rcx, 4
    jge .normalize
    fld dword [exp_tmp + rcx*4]
    faddp st1, st0
    inc rcx
    jmp .sum_loop

.normalize:
    fstp dword [sum_exp]
    xor rcx, rcx
.norm_loop:
    cmp rcx, 4
    jge .argmax
    fld dword [exp_tmp + rcx*4]
    fld dword [sum_exp]
    fdivp st1, st0
    fstp dword [softmax + rcx*4]
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
    fcomip st0, st1
    ja .update_argmax
    fstp st0
    jmp .argmax_loop
.update_argmax:
    fstp st1
    mov rbx, rcx
    jmp .argmax_loop

.print_token:
    ; (Optional) print softmax vector
    ; mov rax, 1
    ; mov rdi, 1
    ; lea rsi, [softmax]
    ; mov rdx, 16
    ; syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, tokens
    add rsi, rbx
    mov rdx, 1
    syscall
    ret

exp_approx:
    fld st0            ; x
    fld st0            ; x, x
    fmul               ; x²
    fld st1            ; x, x², x
    fmul               ; x³

    fld1               ; 1
    fld st3            ; x
    fadd               ; 1 + x

    fld qword [two]
    fdiv st2, st0      ; x² / 2
    fld qword [six]
    fdiv st1, st0      ; x³ / 6

    faddp st1, st0     ; + x²/2
    faddp st1, st0     ; + x³/6

    ret