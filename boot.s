global _start

section .text
_start:
    call forward_pass

    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; exit code 0
    syscall
