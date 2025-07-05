global _start

section .text
_start:
    call forward_pass

    mov rax, 60         
    xor rdi, rdi
    syscall
