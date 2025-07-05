global forward_pass
global output
global input

section .data
input:     dd 2.0, 1.0, 0.0, 3.0
hidden:    times 4 dd 0.0
output:    times 4 dd 0.0

layer1_weights:
    dd -0.3,  0.2, -0.5,  0.4
    dd  0.7, -0.6,  0.3, -0.8
    dd  0.1,  0.2,  0.9,  0.1
    dd -0.4,  0.0,  0.5,  0.6

layer2_weights:
    dd 1.0, 0.0, 0.0, 0.0     
    dd 0.0, 1.0, 0.0, 0.0     
    dd 0.0, 0.0, 1.0, 0.0
    dd 0.0, 0.0, 0.0, 1.0      

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

    mov rax, rcx
    shl rax, 4

    mov rbx, rdx
    shl rbx, 2

    add rax, rbx      
    fld dword [layer1_weights + rax]

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
    jge .done

    xor rdx, rdx
    fldz
.inner2:
    cmp rdx, 4
    jge .store_out

    fld dword [hidden + rdx*4]

    mov rax, rcx
    shl rax, 4

    mov rbx, rdx
    shl rbx, 2

    add rax, rbx
    fld dword [layer2_weights + rax]

    fmul
    faddp st1, st0
    inc rdx
    jmp .inner2

.store_out:
    fstp dword [output + rcx*4]
    inc rcx
    jmp .layer2_loop
.done:
ret
