global _start
extern forward_pass
extern softmax_pass
extern ascii_to_input

section .text
_start:
    call ascii_to_input
    call forward_pass
    call softmax_pass

    mov rax, 60
    xor rdi, rdi
    syscall