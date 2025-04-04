; --- constantes do sistema ---
dados_tempo    equ     28h     ; endereço para temporizador
tam_display    equ     4       ; dígitos no display
cont_veiculos  equ     45h     ; contagem de carros

; --- flags de controle ---
emergencia     bit     24h.0   ; flag de emergência
muitos_carros  bit     24h.1   ; flag de muitos carros

; --- configuração de hardware ---
semaforo_verde   equ    P1.0    ; luz verde
semaforo_amarelo equ    P1.1    ; luz amarela  
semaforo_vermelho equ   P1.2    ; luz vermelha
led_emerg        equ    P1.3    ; indicador
led_trafego      equ    P1.4    ; alerta tráfego

botao_carro      equ    P3.2    ; sensor veículos
botao_emerg      equ    P3.3    ; botão emergência

display_seg      equ    P0      ; segmentos
display_dig      equ    P2      ; dígitos

; --- tabela de conversão ---
tabela_numeros:
    DB 0C0h  ; 0
    DB 0F9h  ; 1
    DB 0A4h  ; 2
    DB 0B0h  ; 3
    DB 099h  ; 4
    DB 092h  ; 5
    DB 082h  ; 6
    DB 0F8h  ; 7
    DB 080h  ; 8
    DB 090h  ; 9

; inicialização do sistema
    org     0000h
    ljmp    setup

    org     0003h
    ljmp    conta_carro

    org     0013h
    ljmp    ativa_emergencia

    org     0050h

setup:
    ; configura pilha e portas
    mov     SP, #65h
    mov     P0, #0FFh
    mov     P1, #0FFh
    mov     P2, #0FFh
    mov     P3, #0FFh

    ; prepara interrupções
    setb    EA
    setb    EX0
    setb    EX1
    setb    IT0
    setb    IT1
    setb    PX1

    ; inicia variáveis
    mov     cont_veiculos, #0
    clr     emergencia
    clr     muitos_carros

    ; zera display
    mov     dados_tempo+0, #0
    mov     dados_tempo+1, #0
    mov     dados_tempo+2, #0
    mov     dados_tempo+3, #0

    ; configura ponteiros
    mov     DPTR, #tabela_numeros

; ==============================================
; loop de operação principal
; ==============================================
main_loop:
    call    apaga_luzes
    jb      emergencia, modo_emergencia
    
    ; Ciclo Verde
    clr     semaforo_verde
    setb    botao_carro
    jb      muitos_carros, verde_longo
    mov     dados_tempo+0, #0
    mov     dados_tempo+1, #1
    call    conta_tempo_verde
    sjmp    fim_verde

verde_longo:
    ; Verde estendido (15s)
    mov     dados_tempo+0, #5
    mov     dados_tempo+1, #1
    call    conta_tempo_verde_longo
    clr     muitos_carros
    setb    led_trafego

fim_verde:
    setb    semaforo_verde
    jb      emergencia, modo_emergencia
    
    ; Ciclo Amarelo
    clr     semaforo_amarelo
    mov     dados_tempo+0, #3
    mov     dados_tempo+1, #0
    call    conta_tempo_amarelo
    setb    semaforo_amarelo
    jb      emergencia, modo_emergencia
    
    ; Ciclo Vermelho normal
    clr     semaforo_vermelho
    mov     dados_tempo+0, #7
    mov     dados_tempo+1, #0
    call    conta_tempo_vermelho
    setb    semaforo_vermelho
    
    ljmp    main_loop

modo_emergencia:
    ; Força todas as luzes para vermelho
    setb    semaforo_verde
    setb    semaforo_amarelo
    clr     semaforo_vermelho
    clr     led_emerg 
    
    ; Configura tempo de emergência (15s)
    mov     dados_tempo+0, #5
    mov     dados_tempo+1, #1
    call    conta_tempo_emergencia
    
    ; Finaliza emergência
    setb    semaforo_vermelho
    setb    led_emerg
    clr     emergencia
    ljmp    main_loop

; ==============================================
; Rotinas de temporização
; ==============================================
conta_tempo_verde:
    call    atualiza_display
    call    espera_1s
    call    diminui_tempo
    jb      emergencia, fim_contagem_verde
    jb      muitos_carros, verde_longo  ; Verifica se a flag foi ativada durante a contagem
    mov     A, dados_tempo+0
    orl     A, dados_tempo+1
    jnz     conta_tempo_verde
fim_contagem_verde:
    ret

conta_tempo_verde_longo:
    call    atualiza_display
    call    espera_1s
    call    diminui_tempo
    jb      emergencia, fim_contagem_verde_longo
    mov     A, dados_tempo+0
    orl     A, dados_tempo+1
    jnz     conta_tempo_verde_longo
fim_contagem_verde_longo:
    ret

conta_tempo_amarelo:
    call    atualiza_display
    call    espera_1s
    call    diminui_tempo
    jb      emergencia, fim_contagem_amarelo
    mov     A, dados_tempo+0
    orl     A, dados_tempo+1
    jnz     conta_tempo_amarelo
fim_contagem_amarelo:
    ret

conta_tempo_vermelho:
    call    atualiza_display
    call    espera_1s
    call    diminui_tempo
    jb      emergencia, fim_contagem_vermelho
    mov     A, dados_tempo+0
    orl     A, dados_tempo+1
    jnz     conta_tempo_vermelho
fim_contagem_vermelho:
    ret

conta_tempo_emergencia:
    call    atualiza_display
    call    espera_1s
    call    diminui_tempo
    mov     A, dados_tempo+0
    orl     A, dados_tempo+1
    jnz     conta_tempo_emergencia
    ret

; ==============================================
; Funções auxiliares
; ==============================================
apaga_luzes:
    setb    semaforo_verde
    setb    semaforo_amarelo
    setb    semaforo_vermelho
    ret

conta_carro:
    push    acc
    push    psw
    jnb      semaforo_vermelho, fim_contagem
    mov     A, cont_veiculos
    inc     A
    mov     cont_veiculos, A
    cjne    A, #6, fim_contagem
    setb    muitos_carros
    clr     led_trafego
fim_contagem:
    pop     psw
    pop     acc
    reti

ativa_emergencia:
    push    acc
    push    psw
    setb    emergencia
    ; Força mudança imediata para vermelho
    setb    semaforo_verde
    setb    semaforo_amarelo
    clr     semaforo_vermelho
    clr     led_emerg   
    pop     psw
    pop     acc
    reti

diminui_tempo:
    push    acc
    
    dec     dados_tempo+0
    mov     A, dados_tempo+0
    cjne    A, #0FFh, fim_contador
    
    mov     dados_tempo+0, #9
    dec     dados_tempo+1
    mov     A, dados_tempo+1
    cjne    A, #0FFh, fim_contador
    
    mov     dados_tempo+1, #9
    dec     dados_tempo+2
    mov     A, dados_tempo+2
    cjne    A, #0FFh, fim_contador
    
    mov     dados_tempo+2, #9
    dec     dados_tempo+3

fim_contador:
    pop     acc
    ret

atualiza_display:
    push    acc
    push    psw
    mov     R0, #dados_tempo
    mov     R5, #11111110b
    
mostra_numero:
    mov     A, @R0
    movc    A, @A+DPTR
    mov     display_seg, A
    mov     display_dig, R5
    
    call    delay_pequeno
    
    inc     R0
    mov     A, R5
    rl      A
    mov     R5, A
    
    cjne    R0, #dados_tempo+tam_display, mostra_numero
    
    mov     display_dig, #0FFh
    pop     psw
    pop     acc
    ret

delay_pequeno:
    push    acc
    mov     A, #50

delay_loop:
    djnz    acc, delay_loop
    pop     acc
    ret

espera_1s:
    mov     TMOD, #01h
    mov     TH0, #0FFh
    mov     TL0, #084h  
    setb    TR0

aguarda:
    jnb     TF0, aguarda
    clr     TF0
    ret

end
