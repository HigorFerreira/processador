; HW 32 bits , 128 kbytes de memoria 
.data 
M: times 128000 db 0

; considerando em vetor 4 bytes onde  o reg eh o índice
Reg: times 5 dq 0
ZERO: db 0
NEG: db 0
CARRY: db 0
IP:  dd 0  ; indicara a próxima instrução a buscar
  

; RSI atuara como IP  RDI Memoria
      Mov  RDi, M
Infinito:
     Mov RSI,[IP]
     ; obtem instrução 
     Mov AL, Byte [RDI+RSI]
     Cmp AL, 0 
     JE   addx
     Cmp AL, 1 
     JE  subx
     Cmp AL, 2
     Je andx 
     ;.....
     cmp al, 3
     je orx
     ;.....
     Cmp AL,18 
     JE haltx 
      ; --- se não esta entre 00 e 18 invalida 
     JMP trata_inst_invalida_sai

;-------------------------------------decodifica 2 reg


;-------------------------------------- seta flag

;Helpers
      ;This helper makes an operation of the type X+Y*4 
      ;X has to be seted in r8
      ;Y has to be seted in r9
      ;The result is returned in r8
      ;Prototype: r8 <- (r8 + r9*4) !alter r15, r8
pointer_calc:
      push rax  ;Salvando o valor de rax que será modificado pela multiplicação
      mov rax, r9
      mov r15b, 4 ;Colocando no r15b o valor a ser multiplicado
      mul r15b    ;Comando de multiplicação rax*4 = Y*4
                  ;Neste ponto o rax é 4 vezes o valor original
      add r8, rax ;Somando o ponteiro, r8 = X+Y*4
      pop rax     ;Recuperando o valor original de rax
      ret

;===========instruções

Addx:  ; add 1 byte depois ...
; instrução add soma dois registradores mesmo tamanho 
; obtem registrores

      Xor rax,rax ; zera
      Mov al, byte [RDI+RSI+1]
      call decode_2r
      cmp rcx,1 
      je exec_add_8
      cmp rcx,2
      je  exec_add_16
      cmp rcx,3
      je  exec_add_32
      ; ERRO INVL REG 
      jmp trata_reg_invalido

Exec_add_8:
      Mov rdx,Reg
      
      ;Implementing ------------> Mov cl, byte [rdx+rax*4]
      mov r8, rdx
      mov r9, rax
      ;r8 <- (r8 + r9*4) !alter r15, r8
      call pointer_calc
      Mov cl, byte [r8]        ;Movendo o resultado do ponteiro
      
      ;Implementing ------------> Mov ch, byte [rdx+bx*4]
      mov r8, rdx
      xor r9, r9
      mov r9w, bx
      ;r8 <- (r8 + r9*4) !alter r15, r8
      call pointer_calc
      mov ch, byte[r8]

      Add cl,ch
      ;Implementing ------------> Mov byte [rdx+rax*4],cl
      mov r8, rdx
      mov r9, rax
      call pointer_calc
      Mov byte [r8],cl

      call flags
      jmp inc_ip_add
;-----
Exec_add_16:
      Mov rdx,Reg
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov cx, word [r8]
      ;pointer_calc
            mov r8, rdx
            mov r9, rbx
            call pointer_calc
      Mov bx, word  [r8]
      Add cx,bx
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov word [r8],cx
      call flags
      jmp inc_ip_add
Exec_add_32:
      Mov rdx,Reg
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov ecx, dword [r8]
      ;pointer_calc
            mov r8, rdx
            xor r9, r9
            mov r9w, bx
            call pointer_calc
      Mov ebx, dword [r8]
      Add ecx,ebx
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov dword [r8],ecx
      call flags 
inc_ip_add: 
      Add RSI,2
      Mov dword  [IP],RSI
      Jmp infinito	
;------------------------------------------------------------
Subx: 
; sub 1 byte depois ...
; instrução sub subtrai  dois registradores mesmo tamanho 
; obtem registrores
      Xor rax,rax ; zera
      Mov al, [RDI+RSI+1]
      call decode_2r
      cmp rcx,1 
      je exec _sub_8
      cmp rcx,2
      je  exec_sub_16
      cmp rcx,3
      je  exec_sub_32
      ; ERRO INVL REG 
      jmp trata_reg_invalido

Exec_sub_8:
      Mov rdx,Reg
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov cl, byte [r8]
      ;pointer_calc
            mov r8, rdx
            mov r9, rbx
            call pointer_calc
      Mov ch, byte [r8]
      sub cl,ch
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov byte [r8],cl
      call flags
      jmp inc_ip_sub
;-----
Exec_sub_16:
      Mov rdx,Reg
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov cx, word [r8]
      ;pointer_calc
            mov r8, rdx
            mov r9, rbx
            call pointer_calc
      Mov bx, word  [r8]
      sub cx,bx
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov byte [r8],cx
      call flags
      jmp inc_ip_sub
Exec_sub_32:
      Mov rdx,Reg
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov ecx, byte [r8]
      ;pointer_calc
            mov r8, rdx
            xor r9, r9
            mov r9w, bx
            call pointer_calc
      Mov ebx, byte [r8]
      sub ecx,ebx
      ;pointer_calc
            mov r8, rdx
            mov r9, rax
            call pointer_calc
      Mov byte [r8],ecx
      call flags 
inc_ip_sub: 
      Add RSI,2
      Mov dword  [IP],RSI
      Jmp infinito	

< todas as outras>	
; --- flags
Flags:
      Jz zero1
      Mov al,0
      Jmp carry
Zero1:
      Mov al,1
Carry:
      Mov byte [zero],al
      Jc  carry1
      Mov al,0 
      Jmp neg
Carry1:
      Mov al,1
Neg:
      Mov byte [carry],al
      jl neg1
      mov al, 0
      mov  byte [neg],al
      ret
neg1:
      mov al,1
      mov byte [neg],al
      ret 

decode_2r:
; IN AL  2 regs 
; OUT  R0 RAX 
;      R1 RBX 
;      RCx=0  err 
;         1  8 bts,  2 16 bts  , 3 32 bits 


; na parte alta de ah esta o reg destino e na parte baixa o origem separa.
; descobre se é 8,16 ou 32 bits
; separa 
      Mov rbx, fh  ; mascara 1111 binaria 
      And rbx, rax  ; separou destino
; shift dir 4 em rax separa origem 
      Shr rax,4  
; verifica se 8 bits 06<=rax<=09 
     Cmp rax,6 
     Jl testa16
     Cmp rax,9 
     Jg testa32 
; --- primeiro eh 8 segundo deve ser 
     Cmp rbx, 6
     Jl erro_reg_sai
     Cmp rbx, 9
     Jg erro_reg_sai 
; --- os dois são 8 bits e códigos estão em RAX e RBX
      mov rcx, 	1 
      ret 
testa 16:
 ; 16 bits no intervalo 02 a 05
     Cmp rax,2
     Jl testa32
     Cmp rax,5
     Jg testa32
; --- primeiro 16 
     Cmp rbx, 2
     Jl   erro_reg_sai
     Cmp rbx, 5
     Jg erro_reg_sai 
; --- os dois são 16 bits e códigos estão em RAX e RBX
      mov rcx, 2
      ret 
;==== 32 
Testa32: ; 0,1, a  e B
     Cmp rax,0
     Je tesx2
     Cmp rax,1
     Je tesx2
     Cmp rax,ah
     Je tesx2
     Cmp rax, bh
     Je tesx2
;--- invalid
     Jmp erro_reg_sai
; primeiro eh 32
Tesx2:
     Cmp rbx,0
     Je add_32
     Cmp rbx,1
     Je add_32
     Cmp rbx, ah
     Je add_32
     Cmp rbx, bh
     JNE erro_reg_sai 
 add_32:
       mov rcx,3 	1 
      ret 
;-erro 
erro_reg_sai:
    mov rcx, 0 
    ret

;----------------------jumpers 
;-08-0fh 
jcarryx:
; RSI=IP RDI=M 
JNC inc_jc_ip
; desvia
   mov RSI, dword[RDI+RSI+1]
   Mov dword  [IP],RSI
   Jmp infinito	
inc_jc_ip:
      Add RSI,5
      Mov dword  [IP],RSI
      Jmp infinito

;.....	

orx: