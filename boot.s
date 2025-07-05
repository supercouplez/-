global _start
extern forward_pass
extern softmax_pass

section .text
_start:
    call forward_pass
    call softmax_pass

    mov rax, 60
    xor rdi, rdi
    syscall