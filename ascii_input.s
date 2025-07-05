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

    movzx rax, byte [ascii_text + rcx] ; ambil ASCII char
    cvtsi2ss xmm0, eax                 ; int → float
    movss [input + rcx*4], xmm0        ; simpan ke input[rcx]

    inc rcx
    jmp .next_char

.done:
    ret