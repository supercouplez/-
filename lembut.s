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

    fld dword [output]         ; st0 = output[0]
    mov rcx, 1
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
    fstp st0
    fst dword [sum_exp]        

    ; ========== Hitung exp(output[i] - max) ==========
    xor rcx, rcx
.exp_loop:
    cmp rcx, 4
    jge .sum_exp

    fld dword [output + rcx*4]
    fld dword [sum_exp]
    fsubp st1, st0             ; st0 = output[i] - max
    call exp_approx
    fst dword [exp_tmp + rcx*4]
    inc rcx
    jmp .exp_loop

.sum_exp:
    fldz
    mov rcx, 0
.sum_loop:
    cmp rcx, 4
    jge .normalize
    fld dword [exp_tmp + rcx*4]
    faddp st1, st0
    inc rcx
    jmp .sum_loop

.normalize:
    fst dword [sum_exp]
    mov rcx, 0
.norm_loop:
    cmp rcx, 4
    jge .argmax
    fld dword [exp_tmp + rcx*4]
    fld dword [sum_exp]
    fdivp st1, st0
    fst dword [softmax + rcx*4]
    inc rcx
    jmp .norm_loop

; ========== Argmax ==========
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

; ========== Print token ==========
.print_token:
    mov rax, 1
    mov rdi, 1
    mov rsi, tokens
    add rsi, rbx
    mov rdx, 1
    syscall
    ret

; ========== Approximate exp(x) ==========
exp_approx:
    ; exp(x) ≈ 1 + x + x^2/2 + x^3/6
    fld st0         ; x
    fld st0         ; x, x
    fmul            ; x^2
    fld st1         ; x, x^2, x
    fmul            ; x^3

    fld1            ; 1.0
    fild dword [two] ; 2.0
    fdiv st2, st0   ; x^2 / 2
    fild dword [six] ; 6.0
    fdiv st1, st0   ; x^3 / 6

    fld st3         ; x
    fadd st1, st0   ; + x
    fadd st1, st0   ; + x^2/2
    fadd st1, st0   ; + x^3/6

    fstp st0        ; bersihkan stack
    fstp st0
    fstp st0
; Optional debug print softmax vector (16 byte float)
    mov rax, 1
    mov rdi, 1
    lea rsi, [softmax]
    mov rdx, 16
    syscall
    ret

section .data
two: dd 2
six: dd 6