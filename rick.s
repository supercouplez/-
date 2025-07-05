global ascii_to_input
extern input

section .text
ascii_to_input:
    
    mov     rax, 0          
    mov     rdi, 0          
    mov     rsi, input_buffer
    mov     rdx, 4          

    xor     rcx, rcx
.convert_loop:
    cmp     rcx, 4
    jge     .done

    movzx   eax, byte [input_buffer + rcx] 
    cvtsi2ss xmm0, eax                   
    movss   [input + rcx*4], xmm0          
    inc     rcx
    jmp     .convert_loop

.done:
    ret

section .bss
input_buffer: resb 4