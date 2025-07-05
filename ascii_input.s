global ascii_to_input
extern input          ; <== ini wajib agar bisa akses input dari matmul.s

section .data
ascii_text: db "ABCD"

section .text
ascii_to_input:
    mov rcx, 0
.next_char:
    cmp rcx, 4
    jge .done

    movzx eax, byte [ascii_text + rcx]  ; ambil 1 byte
    cvtsi2ss xmm0, eax                  ; convert ke float
    movss [input + rcx*4], xmm0         ; simpan ke input

    inc rcx
    jmp .next_char

.done:
    ret