.global _start

.section .data
    prompt_msg:   .asciz "Enter the name of the file to be encrypted."
    prompt_len = . - prompt_msg

    key_file:     .asciz "password.txt"
    urandom_file: .asciz "/dev/urandom"

.section .bss
   .align 2
   filename:    .space 256
   buffer:      .space 2048
   key_buffer:  .space 2048

.section .text
_start:
      mov r0, #1
      ldr r1, =prompt_msg
      mov r2, #prompt_len
      mov r7, #4
      svc #0

      mov r0, #0
      ldr r1, =filename
      mov r2, #255
      mov r7, #3
      svc #0
      mov r5, r0

      cmp r5, #1
      blt _exit

      ldr r1, =filename
      sub r5, r5, #1
      mov r2, #0
      strb r2, [r1, r5]

      
      ldr r0, =filename
      mov r1, #0                  @ O_RDONLY
      mov r2, #0
      mov r7, #5
      svc #0

      cmp r0, #0
      blt _exit
      mov r4, r0

      mov r0, r4
      ldr r1, =buffer
      mov r2, #2048
      mov r7, #3
      svc #0
      mov r5, r0

      
      mov r0, r4
      mov r7, #6
      svc #0

      cmp r5, #0
      ble _exit

      ldr r0, =urandom_file
      mov r1, #0
      mov r2, #0
      mov r7, #5
      svc #0
      mov r6, r0

      mov r0, r6
      ldr r1, =key_buffer
      mov r2, r5
      mov r7, #3
      svc #0

      mov r0, r6
      mov r7, #6
      svc #0

      ldr r1, =buffer
      ldr r2, =key_buffer
      mov r3, #0

xor_loop:
    cmp r3, r5
    bge save_changes
    ldrb r8, [r1, r3]
    ldrb r9, [r2, r3]
    eor r8, r8, r9
    strb r8, [r1, r3]
    add r3, r3, #1
    b xor_loop

save_changes:
    
    ldr r0, =filename
    mov r1, #0101               @ O_WRONLY | O_CREAT | O_TRUNC (Dosyayi temizler)
    mov r2, #0644
    mov r7, #5
    svc #0
    mov r4, r0

    mov r0, r4
    ldr r1, =buffer
    mov r2, r5
    mov r7, #4
    svc #0

    mov r0, r4
    mov r7, #6
    svc #0

   ldr r0, =key_file
   mov r1, #0101
   mov r2, #0644
   mov r7, #5
   svc #0
   mov r4, r0

   mov r0, r4
   ldr r1, =key_buffer
   mov r2, r5
   mov r7, #4
   svc #0

   mov r0, r4
   mov r7, #6
   svc #0

_exit:
    mov r0, #0
    mov r7, #1
    svc #0
