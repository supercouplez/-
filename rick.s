global ascii_to_input
extern input

section .data
ascii_text: db "ABCD"

section .text
ascii_to_input:
    mov rcx, 0
.next_char:
    cmp rcx, 4
    jge .done

    movzx eax, byte [ascii_text + rcx]
    cvtsi2ss xmm0, eax
    movss [input + rcx*4], xmm0

    inc rcx
    jmp .next_char

.done:
    ret
