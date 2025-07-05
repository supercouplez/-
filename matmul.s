global forward_pass

section .data
input:     dd 2.0, 1.0, 0.0, 3.0
hidden:    times 4 dd 0.0
output:    times 4 dd 0.0

layer1_weights:
    dd 0.1, 0.2, 0.3, 0.4,
       0.5, 0.6, 0.7, 0.8,
       0.9, 1.0, 1.1, 1.2,
       1.3, 1.4, 1.5, 1.6

layer2_weights:
    dd 0.1, 0.2, 0.3, 0.4,
       0.5, 0.6, 0.7, 0.8,
       0.9, 1.0, 1.1, 1.2,
       1.3, 1.4, 1.5, 1.6

section .text
forward_pass:
    finit

    xor rcx, rcx
.layer1_loop:
    cmp rcx, 4
    jge .layer2

    xor rdx, rdx     
    fldz             
.inner1:
    cmp rdx, 4
    jge .store_hidden

    fld dword [input + rdx*4]
    fld dword [layer1_weights + rcx*16 + rdx*4] 
    fmul                                     
    faddp st1, st0                         
    inc rdx
    jmp .inner1

.store_hidden:
    fstp dword [hidden + rcx*4]
    inc rcx
    jmp .layer1_loop

.layer2:
    xor rcx, rcx         
.layer2_loop:
    cmp rcx, 4
    jge .print

    xor rdx, rdx
    fldz
.inner2:
    cmp rdx, 4
    jge .store_out

    fld dword [hidden + rdx*4]
    fld dword [layer2_weights + rcx*16 + rdx*4]
    fmul
    faddp st1, st0
    inc rdx
    jmp .inner2

.store_out:
    fstp dword [output + rcx*4]
    inc rcx
    jmp .layer2_loop

.print:

    fld dword [output]
    sub rsp, 32
    fistp qword [rsp]
    mov rsi, rsp
    mov rdi, 1
    mov rdx, 4
    mov rax, 1
    syscall
    add rsp, 32

    ret
