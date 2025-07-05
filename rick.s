global ascii_to_input
extern input

section .bss
input_buffer: resb 4

section .text
ascii_to_input:
    mov     eax, 0          
    mov     edi, 0          
    mov     rsi, input_buffer
    mov     edx, 4          

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