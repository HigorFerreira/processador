; HW 32 bits , 128 kbytes de memoria 
SECTION .data 
M: times 128000 db 0

; considerando em vetor 4 bytes onde  o reg eh o índice
Reg: times 5 dq 0
ZERO: db 0
NEG: db 0
CARRY: db 0
IP:  dd 0  ; indicara a próxima instrução a buscar
  
SECTION .text

global start

start:

; RSI atuará como IP  RDI Memoria
      Mov  RDi, M
infinito:
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
     je andx
     cmp al, 4
     je orx
     cmp al, 5
     je notx
     cmp al, 6
     je cmpx
     cmp al, 7
     je cmpx
     cmp al, 8
     je jcx
     cmp al, 9
     je jex
     cmp al, 0xa
     je jnzx
     cmp al, 0xb
     je jlx
     cmp al, 0xc
     je jgx
     cmp al, 0xd
     je jlex
     cmp al, 0xe
     je jgex
     cmp al, 0xf
     je jmpx
     ;.....
     Cmp AL,18 
     JE haltx 
      ; --- se não esta entre 00 e 18 invalida 
     JMP trata_inst_invalida_sai

;-------------------------------------decodifica 2 reg


;-------------------------------------- seta flag

;Helpers
      ;This helper makes an operation of the type X+Y*4 
      ;X has to be seted in rax
      ;Y has to be seted in rdx
      ;The result is returned in rbp
      ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
pointer_calc:
      push rax  ;Salvando o valor de rax que será modificado pela multiplicação

      mov rbp, 4   ;Colocando no rbp o valor a ser multiplicado
      mul bpl      ;Comando de multiplicação rax*4 = Y*4
                   ;Neste ponto o rax é 4 vezes o valor original
      
      push rdx     ;Salvando o valor de rdx que será modificado pela adição

      add rdx, rax ;Somando o ponteiro, rdx = rax*4  + rdx
      mov rbp, rdx ;Salvando o resultado que deverá ser retornado em rbp
      
      pop rdx     ;Recuperando o valor original de rdx
      pop rax     ;Recuperando o valor original de rax
      ret

;===========instruções

addx:  ; add 1 byte depois ...
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

exec_add_8:
      Mov rdx,Reg
      
      ;Implementing ------------> Mov cl, byte [rdx+rax*4]
      
      ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
      call pointer_calc
      Mov cl, byte [rbp]        ;Movendo o resultado do ponteiro
      
      ;Implementing ------------> Mov ch, byte [rdx+bx*4]
      push rax
      xor rax, rax
      mov ax, bx
      ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
      call pointer_calc
      ;mov ch, byte[rbp]   ================ ERRO
      pop rax

      Add cl, ch
      ;Implementing ------------> Mov byte [rdx+rax*4],cl
      ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
      call pointer_calc
      Mov byte [rbp],cl

      call FLAGS
      jmp inc_ip_add
;-----
exec_add_16:
      Mov rdx,Reg
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov cx, word [rbp]
      ;pointer_calc
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            pop rax
      Mov bx, word  [rbp]
      Add cx,bx
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov word [rbp],cx
      call FLAGS
      jmp inc_ip_add
exec_add_32:
      Mov rdx,Reg
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov ecx, dword [rbp]
      ;pointer_calc
            push rax
            xor rax, rax
            mov ax, bx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            pop rax
      Mov ebx, dword [rbp]
      Add ecx,ebx
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov [rbp],ecx
      call FLAGS 
inc_ip_add: 
      Add RSI,2
      Mov [IP], DWORD RSI
      Jmp infinito	
;------------------------------------------------------------
subx: 
; sub 1 byte depois ...
; instrução sub subtrai  dois registradores mesmo tamanho 
; obtem registrores
      Xor rax,rax ; zera
      Mov al, [RDI+RSI+1]
      call decode_2r
      cmp rcx,1 
      je exec_sub_8
      cmp rcx,2
      je  exec_sub_16
      cmp rcx,3
      je  exec_sub_32
      ; ERRO INVL REG 
      jmp trata_reg_invalido

exec_sub_8:
      Mov rdx,Reg
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov cl, byte [rbp]
      ;pointer_calc
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            pop rax
      ;Mov ch, byte [rbp]   ================ ERRO
      sub cl,ch
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov byte [rbp],cl
      call FLAGS
      jmp inc_ip_sub
;-----
exec_sub_16:
      Mov rdx,Reg
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov cx, word [rbp]
      ;pointer_calc
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            pop rax
      Mov bx, word[rbp]
      sub cx,bx
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov [rbp], cx
      call FLAGS
      jmp inc_ip_sub
exec_sub_32:
      Mov rdx,Reg
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov ecx, dword [rbp]
      ;pointer_calc
            push rax
            xor rax, rax
            mov ax, bx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            pop rax
      Mov ebx, dword [rbp]
      sub ecx,ebx
      ;pointer_calc
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
      Mov [rbp],ecx
      call FLAGS 
inc_ip_sub: 
      Add RSI,2
      Mov [IP],RSI
      Jmp infinito	

;< todas as outras>	
; --- flags
FLAGS:
      Jz zero1
      Mov al,0
      Jmp carry
zero1:
      Mov al,1
carry:
      Mov [zero],al
      Jc  carry1
      Mov al,0 
      Jmp negx
carry1:
      Mov al,1
negx:
      Mov [carry],al
      jl neg1
      mov al, 0
      mov  [NEG],al
      ret
neg1:
      mov al,1
      mov byte [NEG],al
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
      Mov rbx, 0xf  ; mascara 1111 binaria 
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
testa16:
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
testa32: ; 0,1, a  e B
     Cmp rax,0
     Je tesx2
     Cmp rax,1
     Je tesx2
     Cmp rax, 0xa     ;ah número? ou registrador?
     Je tesx2
     Cmp rax, 0xb     ;bh número? ou registrador?
     Je tesx2
;--- invalid
     Jmp erro_reg_sai
; primeiro eh 32
tesx2:
     Cmp rbx,0
     Je add_32
     Cmp rbx,1
     Je add_32
     Cmp rbx, 0ah       ;ah número? ou registrador?
     Je add_32
     Cmp rbx, 0bh       ;bh número? ou registrador?
     JNE erro_reg_sai 
 add_32:
      mov rcx, 3
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
   mov esi, dword[RDI+RSI+1]
   Mov [IP], esi
   Jmp infinito	
inc_jc_ip:
      Add RSI,5
      Mov [IP], dword RSI
      Jmp infinito

;.....

andx:
      xor rax, rax
      mov al, byte[rsi + rdi + 1]
      call decode_2r
      cmp cl, 1b
      je andx8
      cmp cl, 10b
      je andx16
      cmp cl, 11b
      je andx32
      ;Erro de registrador inválido
      jmp trata_reg_invalido
      andx8:
            mov rdx, Reg
           
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov ch, byte [rbp]
            pop rax

            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov cl, byte [rbp]
            ;AND OPERATION
            and cl, ch
            ;MOVING OPERATION RESULT FOR THE FIRST REGISTER
            mov [rbp], cl
            ;THIS OPERATION DOES NOT SET FLAGS
            jmp inc_ip_add
            
      andx16:
            mov rdx, Reg
           
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov cx, word [rbp]
            pop rax

            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov bx, word [rbp]
            ;AND OPERATION
            and bx, cx
            ;MOVING OPERATION RESULT FOR THE FIRST REGISTER
            mov [rbp], bx
            ;THIS OPERATION DOES NOT SET FLAGS
            jmp inc_ip_add
      andx32:
            mov rdx, Reg
           
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov ecx, dword [rbp]
            pop rax

            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov ebx, dword [rbp]
            ;AND OPERATION
            and ebx, ecx
            ;MOVING OPERATION RESULT FOR THE FIRST REGISTER
            mov [rbp], ebx
            ;THIS OPERATION DOES NOT SET FLAGS
            jmp inc_ip_add

orx:
      xor rax, rax
      mov al, byte[rsi + rdi + 1]
      call decode_2r
      cmp cl, 1b
      je orx8
      cmp cl, 10b
      je orx16
      cmp cl, 11b
      je orx32
      ;Erro de registrador inválido
      jmp trata_reg_invalido
      orx8:
            mov rdx, Reg
           
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov ch, byte [rbp]
            pop rax

            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov cl, byte [rbp]
            ;OR OPERATION
            or cl, ch
            ;MOVING OPERATION RESULT FOR THE FIRST REGISTER
            mov [rbp], cl
            ;THIS OPERATION DOES NOT SET FLAGS
            jmp inc_ip_add
            
      orx16:
            mov rdx, Reg
           
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov cx, word [rbp]
            pop rax

            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov bx, word [rbp]
            ;OR OPERATION
            or bx, cx
            ;MOVING OPERATION RESULT FOR THE FIRST REGISTER
            mov [rbp], bx
            ;THIS OPERATION DOES NOT SET FLAGS
            jmp inc_ip_add
      orx32:
            mov rdx, Reg
           
            push rax
            mov rax, rbx
            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov ecx, dword [rbp]
            pop rax

            ;Prototype: rbp <- (rax*4 + rdx) !alter rbp
            call pointer_calc
            mov ebx, dword [rbp]
            ;OR OPERATION
            or ebx, ecx
            ;MOVING OPERATION RESULT FOR THE FIRST REGISTER
            mov [rbp], ebx
            ;THIS OPERATION DOES NOT SET FLAGS
            jmp inc_ip_add

notx:
      xor rax,rax                   ;Zerando o registrador
      mov al, byte [RDI+RSI+1]      ;Obtendo os parâmetros da instrução

      ;O parâmetro deve ser zero nos primeiros 4 bits
      ;E nos 4 restantes deve conter o registrador

      mov bl, 0xf                   ;Máscara para testar se os 4 bits mais baixos são 0
      and bl, al
      cmp bl, 0                     ;Testando se os 4 bits mais baixos são 0
      jne trata_inst_invalida_sai

      shr al, 4         ;Obtendo o código do registrador

      cmp al, 6
      jl notx_exec16

      ;O registrador é de 8 bits
      mov rdx, [Reg]
      call pointer_calc  ;Cálculo da localização do dado do registrador na memória
      mov bl, byte [rbp]
      not bl
      mov [rbp], bl
      jmp notx_fim

      notx_exec16:
            cmp al, 2
            jl notx_exec32

            mov rdx, [Reg]
            call pointer_calc
            mov bx, word[rbp]
            not bx
            mov [rbp], bx
            jmp notx_fim
      
      notx_exec32:
            mov rdx, [Reg]
            call pointer_calc
            mov ebx, dword[rbp]
            not ebx
            mov [rbp], ebx

      notx_fim:
            jmp inc_ip_add

cmpx:
      jmp subx

jcx:
      xor rax, rax
      mov eax, dword [RDI+RSI+1] ;Obtendo o endereço de desvio

      xor rbx, rbx
      mov bl, byte [CARRY]            ;Obtendo a condição de carry

      cmp bl, 1                       ;Testando se o carry está setado
      push rax
      ret
      jmp inc_jc_ip                   ;Se não, o ciclo vai para a próxima instrução da máquina

jex:
      xor rax, rax
      mov eax, dword [RDI+RSI+1] ;Obtendo o endereço de desvio

      xor rbx, rbx
      mov bl, byte [ZERO]             ;Obtendo a condição de carry

      cmp bl, 1                       ;Testando se o zero está setado
      push rax                          
      ret                             ;Indo para o endereço de desvio se zero = 1
      jmp inc_jc_ip                   ;Se não, o ciclo vai para a próxima instrução da máquina

jnzx:
      xor rax, rax
      mov eax, dword [RDI+RSI+1] ;Obtendo o endereço de desvio

      xor rbx, rbx
      mov bl, byte [ZERO]             ;Obtendo a condição de carry

      cmp bl, 0                       ;Testando se o zero está setado
      push rax                          
      ret                             ;Indo para o endereço de desvio se zero = 1
      jmp inc_jc_ip                   ;Se não, o ciclo vai para a próxima instrução da máquina

jlx:
      xor rax, rax
      mov eax, dword [RDI+RSI+1] ;Obtendo o endereço de desvio

      xor rbx, rbx
      mov bl, byte [NEG]              ;Obtendo a condição de carry

      cmp bl, 1                       ;Testando se o neg está setado
      push rax                          
      ret                             ;Indo para o endereço de desvio se neg = 1
      jmp inc_jc_ip                   ;Se não, o ciclo vai para a próxima instrução da máquina

jgx:
      xor rax, rax
      mov eax, dword [RDI+RSI+1] ;Obtendo o endereço de desvio

      xor rbx, rbx
      mov bl, byte [NEG]              ;Obtendo a condição de carry

      cmp bl, 0                       ;Testando se o neg está setado
      push rax                          
      ret                             ;Indo para o endereço de desvio se neg = 1
      jmp inc_jc_ip                   ;Se não, o ciclo vai para a próxima instrução da máquina

jlex:
      xor rax, rax
      mov eax, dword [RDI+RSI+1] ;Obtendo o endereço de desvio

      xor rbx, rbx
      mov bl, byte [NEG]              ;Obtendo a condição de carry
      xor rcx, rcx
      mov cl, byte [ZERO]
      and bl, cl

      cmp bl, 1
      push rax
      ret
      jmp inc_jc_ip

jgex:
      xor rax, rax
      mov eax, dword [RDI+RSI+1] ;Obtendo o endereço de desvio

      xor rbx, rbx
      mov bl, byte [NEG]
      xor rcx, rcx
      mov cl, byte [ZERO]
      not cl
      and bl, cl

      cmp bl, 1
      push rax
      ret
      jmp inc_jc_ip

jmpx:
      xor rax, rax
      mov eax, dword [RDI+RSI+1]
      
      push rax
      ret



haltx:

trata_inst_invalida_sai:
trata_reg_invalido:
zero:

