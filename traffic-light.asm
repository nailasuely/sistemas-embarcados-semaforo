; --- constantes do sistema ---
dados_tempo    equ     28h     ; endereço para temporizador
tam_display    equ     4       ; dígitos no display
cont_veiculos  equ     45h     ; contagem de carros

; --- flags de controle ---
emergencia     bit     24h.0   ; flag de emergência
muitos_carros  bit     24h.1   ; flag de mt carro

; --- configuração de hardware ---
semaforo_verde   equ    P1.0    ; luz verde
semaforo_amarelo equ    P1.1    ; luz amarela  
semaforo_vermelho equ   P1.2    ; luz vermelha
led_emerg        equ    P1.3    ; indicador
led_trafego      equ    P1.4    ; alerta tráfego

botao_carro      equ    P2.0    ; sensor veículos
botao_emerg      equ    P2.1    ; botão emergência

display_seg      equ    P0      ; segmentos
display_dig      equ    P3      ; dígitos

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
    mov     R5, #11111110b   ; máscara inicial para dígito 1

; ==============================================
; loop de operação principal
; ==============================================
main_loop:
    call    apaga_luzes
    call    ciclo_verde
    call    ciclo_amarelo
    call    ciclo_vermelho
    sjmp    main_loop

; rotinas de controle de tráfego para verificar se o botão é aceso no momento certo 
ciclo_verde:
    setb    botao_carro
    
    jb      muitos_carros, verde_longo

    ; tempo padrão 10s
    clr     semaforo_verde
    mov     dados_tempo+0, #0
    mov     dados_tempo+1, #1
    call    conta_10s
    setb    semaforo_verde
    ret

verde_longo:
    ; tempo estendido 15s
    clr     semaforo_verde
    mov     dados_tempo+0, #5
    mov     dados_tempo+1, #1
    call    conta_15s
    setb    semaforo_verde
    clr     muitos_carros
    ret

ciclo_amarelo:
    clr     semaforo_amarelo
    mov     dados_tempo+0, #3
    mov     dados_tempo+1, #0  ; garante que mostra só 3
    call    conta_3s
    setb    semaforo_amarelo
    ret

ciclo_vermelho:
    setb    botao_emerg
    
    jb      emergencia, vermelho_emergente

    ; tempo normal 7s (corrigido para mostrar 7 segundos)
    clr     semaforo_vermelho
    mov     dados_tempo+0, #7
    mov     dados_tempo+1, #0  ; garante que mostra só 7
    call    conta_7s
    setb    semaforo_vermelho
    ret

vermelho_emergente:
    ; emergência 15s (corrigido para mostrar 15 segundos)
    clr     semaforo_vermelho
    setb    led_emerg
    mov     dados_tempo+0, #5
    mov     dados_tempo+1, #1  ; mostra 15 (1-5)
    mov     dados_tempo+2, #0  ; zera outros digitos
    mov     dados_tempo+3, #0
    call    conta_15s
    setb    semaforo_vermelho
    clr     led_emerg
    clr     emergencia
    ret

apaga_luzes:
    setb    semaforo_verde
    setb    semaforo_amarelo
    setb    semaforo_vermelho
    ret

; tratamento de interrupções
conta_carro:
    jb      semaforo_vermelho, fim_contagem
    call    soma_veiculo
fim_contagem:
    reti

ativa_emergencia:
    setb    emergencia
    clr     led_emerg
    reti

soma_veiculo:
    push    acc
    mov     A, cont_veiculos
    inc     A
    mov     cont_veiculos, A
    
    cjne    A, #5, fim_soma
    setb    muitos_carros
    clr     led_trafego
fim_soma:
    pop     acc
    ret

; ==============================================
; controle de temporização
; ==============================================
conta_3s:
    mov     dados_tempo+0, #3
    mov     dados_tempo+1, #0
    call    contagem
    ret

conta_7s:
    mov     dados_tempo+0, #7
    mov     dados_tempo+1, #0
    call    contagem
    ret

conta_10s:
    mov     dados_tempo+0, #0
    mov     dados_tempo+1, #1
    call    contagem
    ret

conta_15s:
    mov     dados_tempo+0, #5
    mov     dados_tempo+1, #1
    call    contagem
    ret

contagem:
    call    atualiza_display
    call    espera_1s
    call    diminui_tempo
    
    mov     A, dados_tempo+0
    orl     A, dados_tempo+1
    orl     A, dados_tempo+2
    orl     A, dados_tempo+3
    jnz     contagem
    ret

; manipulação do display 
atualiza_display:
    push    acc
    push    psw
    mov     R0, #dados_tempo       ; começa do primeiro dígito
    mov     R5, #11111110b         ; máscara inicial para dígito 1
    
mostra_numero:
    mov     A, @R0                 ; pega valor do dígito
    movc    A, @A+DPTR             ; converte para 7 segmentos
    mov     display_seg, A         ; envia para segmentos
    mov     display_dig, R5        ; ativa dígito
    
    ; pequeno delay para persistência
    call    delay_pequeno
    
    ; prepara próximo dígito
    inc     R0
    mov     A, R5
    rl      A
    mov     R5, A
    
    ; verifica se terminou todos dígitos
    cjne    R0, #dados_tempo+tam_display, mostra_numero
    
    ; desliga todos dígitos no final
    mov     display_dig, #0FFh
    pop     psw
    pop     acc
    ret

; novo delay para persistência do display
delay_pequeno:
    push    acc
    mov     A, #50
delay_loop:
    djnz    acc, delay_loop
    pop     acc
    ret

; rotina de decremento de tempo
diminui_tempo:
    push    acc
    
    ; decrementa unidade primeiro
    dec     dados_tempo+0
    mov     A, dados_tempo+0
    cjne    A, #0FFh, fim_contador  ; verifica se passou de 0 para 255 (isso tem q verificar melhor)
    
    ; se passou, ajusta para 9 e decrementa a dezezen e verifica
    mov     dados_tempo+0, #9
    dec     dados_tempo+1
    mov     A, dados_tempo+1
    cjne    A, #0FFh, fim_contador
    
    ; arruma a dezena e decrementa centecentena (testar separadoooo)
    mov     dados_tempo+1, #9
    dec     dados_tempo+2
    mov     A, dados_tempo+2
    cjne    A, #0FFh, fim_contador
    
    ; arruma centena e decrementa milhar
    mov     dados_tempo+2, #9
    dec     dados_tempo+3

fim_contador:
    pop     acc
    ret

;delays
espera_1s:
    mov     TMOD, #01h
    mov     TH0, #0FFh    ; mantido como estava (não mudei o timer)
    mov     TL0, #084h
    setb    TR0

aguarda:
    jnb     TF0, aguarda
    clr     TF0
    ret                   ; removi o setb led_emerg que causava o piscar

; fimmmmm
    end