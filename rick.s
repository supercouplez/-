global ascii_to_input
extern input

section .bss
input_buffer: resb 4

section .text
ascii_to_input:
    
    mov rax, 0          
    mov rdi, 0          
    mov rsi, input_buffer
    mov rdx, 4
    syscall

    xor rcx, rcx
.convert_loop:
    cmp rcx, 4
    jge .done

    movzx eax, byte [input_buffer + rcx] 
    sub eax, 65               
    cvtsi2ss xmm0, eax
    movss [input + rcx*4], xmm0
    inc rcx
    jmp .convert_loop

.done:
    ; print input[0]
    mov rax, 1         ; syscall write
    mov rdi, 1         ; stdout
    lea rsi, [input]   ; pointer ke input[0]
    mov rdx, 4         ; 1 float (4 byte)
    syscall

mov rax, 1
mov rdi, 1
lea rsi, [input]
mov rdx, 16
syscall
    ret