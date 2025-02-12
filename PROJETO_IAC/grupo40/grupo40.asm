; *********************************************************************
; * 		      PROJETO "CHUVA DE METEOROS"
; *
; *  Grupo Nº 40
; *  |   Luís Pereira, ist1103902
; *  |   Tomás Correia, ist1102707
; *	 
; * 
; *       
; *********************************************************************



; *********************************************************************************
; * Constantes
; *********************************************************************************

DISPLAYS   EQU 0A000H  					; endereço dos displays de 7 segmentos
TEC_LIN    EQU 0C000H  					; endereço das linhas do teclado
TEC_COL    EQU 0E000H  					; endereço das colunas do teclado
MASCARA    EQU 0FH     					; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA          EQU 0
TECLA_DIREITA			EQU 2		   ; tecla na segunda coluna do teclado (tecla D)
TECLA_MISSIL			EQU 1 
AUMENTA_ENERGIA         EQU 6		   ; tecla que aumenta a enengia do rover (tecla '6')	
DIMINUI_ENERGIA         EQU 7		   ; tecla que diminui a energia do rover (tecla '7')
DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA	 		    EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
APAGA_BONECO            EQU 6000H	   ; enderço do comando para apagar o ecrã do rover
DEF_ECRA 				EQU 6004H      ; endereço que define o ecra
TOCA_SOM				EQU 605AH      ; endereço do comando para tocar um som
SELECIONA_CENARIO_FUNDO  EQU 6042H     ; endereço do comando para selecionar uma imagem de fundo


MIN_COLUNA		EQU  0		    ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        	; número da coluna mais à direita que o objeto pode ocupar
MIN_LINHA		EQU  1 			; número da linha mais acima que o objeto pode ocupar
MAX_LINHA       EQU  31			; número da linha mais abaixo que o objeto pode ocupar
ATRASO			EQU	 200H		; atraso para limitar a velocidade de movimento do rover

ALTURA		    EQU	4			; largura do rover
COMPRIMENTO     EQU 5           ; comprimento do rover
COR_PIXEL		EQU	0FF00H		; cor do pixel do rover: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

ALTURA_C        EQU 5           ; altura do cometa
COR_PRETO       EQU 0F000H		
COR_BRANCO      EQU 0FFFFH
COR_CINZENTO 	EQU 08888H
COR_LARANJA     EQU 0FF9BH
COR_AZUL		EQU 0F067H

ALTURA_BM1 		EQU 3			; altura do cometa bom na primeira fase boa
ALTURA_BM2		EQU 4			; altura do cometa bom na segunda fase boa
COMPRIMENTO_BM1 EQU 3			; comprimento do cometa ma na primeira fase ma
COMPRIMENTO_BM2 EQU 4			; comprimento do cometa ma na segunda fase ma

ALTURA_C1       EQU 1			; altura de qualquer cometa na sua primeira fase
ALTURA_C2		EQU 2			; altura de qualquer cometa na sua segunda fase
COMPRIMENTO_C1  EQU 1			; comprimento de qualquer cometa na sua primeira fase
COMPRIMENTO_C2  EQU 2			; comprimento de qualquer cometa na sua segunda fase

LARGURA_MISSIL 	EQU 1			; largura do missil




; *********************************************************************************
; * Dados
; *********************************************************************************

	PLACE       1000H

; Reserva do espaço para as pilhas dos processos
	STACK 100H			; espaço reservado para a pilha do processo "programa principal"
SP_inicial_prog_princ:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:			; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "rover"
SP_inicial_rover:			; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "display"
SP_inicial_display:         ; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "cometa"
SP_inicial_cometa:			; este é o endereço com que o SP deste processo deve ser inicializado


	STACK 100H			; espaço reservado para a pilha do processo "missil"
SP_inicial_missil:			; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "controlar jogo"
SP_inicial_controla:		; este é o endereço com que o SP deste processo deve ser inicializado




; *********************************************************************************
; * Variáveis LOCK
; *********************************************************************************

tecla_carregada:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou
							

display_lock:
	LOCK 0              ; LOCK para a rotina de interrupção comunicar ao processo display que passou o tempo necessario para que a energia do rover diminua em 5%

cometa_lock:
	LOCK 0  			; LOCK para a rotina de interrupção comunicar ao processo cometa que passou o tempo necessario para que o cometa se possa mover

missil_lock:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo missil que passou o tempo necessario para a movimentação do missil

lock_remove:
	LOCK 0				; LOCK para indicar ao processo que pode ser efetuada a remoção do cometa do ecrã (caso tenha acontecido uma colisão ou tenha atingido o limite do ecrã)

jogo_bloqueado:			; LOCK para indicar ao processo que o jogo nao se encontra bloqueado (nao esta quer na fase de iniciaçao ou em pausa)
	LOCK 0


; *********************************************************************************
; * Variáveis WORD
; *********************************************************************************

ENERGIA_ATUAL:			; contem a energia atual do rover
	WORD 100

LINHA:					; contem a linha da posicao do rover
	WORD 27

COLUNA:					; contem a coluna da posicao do rover
	WORD 32

LINHA_COMETA:			; contem a linha inicial do cometa
	WORD 2

LINHA_MISSIL:			; contem a linha da posicao do missil 
	WORD 0

COLUNA_MISSIL:			; contem a coluna da posicao do missil
	WORD 0

ESTADO_JOGO:			; indica em que estado o jogo se encontra (parado ou em execucao)
	WORD 0

del_missil:				; indica se e eh para efetuar a destruiçao do missil ou nao
	WORD 0 

colide_rover:			; indica se o rover esta a colidir com um cometa ou nao
	WORD 0


; *********************************************************************************
; * TABELAS
; *********************************************************************************


; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0
	WORD rot_int_1			; rotina de atendimento da interrupção 1
	WORD rot_int_2			; rotina de atendimento da interrupção 2

							
DEF_BONECO:					; tabela que define o rover (cor, altura, comprimento, pixels)
	WORD		ALTURA																; altura do rover
    WORD        COMPRIMENTO															; comprimento do rover
	WORD		0, 0, COR_PIXEL, 0, 0												; 1a linha de pixeis do rover
    WORD        COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL								; 2a linha de pixeis do rover
    WORD        COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL				; 3a linha de pixeis do rover
    WORD        0, COR_PIXEL, 0, COR_PIXEL, 0										; 4a linha de pixeis do rover	                   


DEF_COMETA:					; tabela que define o cometa bom na sua fase final (cor, altura, comprimento, pixels)
    WORD        ALTURA_C															; altura do cometa
    WORD        COMPRIMENTO															; comprimento do cometa
    WORD        0, COR_PRETO, COR_BRANCO, COR_BRANCO, 0								; 1a linha de pixeis do cometa
    WORD        COR_PRETO, COR_PRETO, COR_BRANCO, COR_BRANCO, COR_BRANCO			; 2a linha de pixeis do cometa
    WORD        COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_PRETO, COR_PRETO			; 3a linha de pixeis do cometa
    WORD        COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_PRETO, COR_PRETO			; 4a linha de pixeis do cometa
    WORD        0, COR_PRETO, COR_BRANCO, COR_BRANCO, 0								; 5a linha de pixeis do cometa

DEF_COMETA_1:				; tabela que define qualquer cometa na sua primeira fase (cor, altura, comprimento, pixels)	
	WORD 		ALTURA_C
	WORD 		COMPRIMENTO
	WORD 		COR_CINZENTO, 0, 0, 0, 0
	WORD        0, 0, 0, 0, 0
	WORD		0, 0, 0, 0, 0
	WORD        0, 0, 0, 0, 0
	WORD		0, 0, 0, 0, 0

DEF_COMETA_2:				; tabela que define qualquer cometa na sua segunda fase (cor, altura, comprimento, pixels)
	WORD		ALTURA_C
	WORD		COMPRIMENTO
	WORD		COR_CINZENTO, COR_CINZENTO, 0, 0, 0
	WORD   		COR_CINZENTO, COR_CINZENTO, 0, 0, 0
	WORD        0, 0, 0, 0, 0, 0
	WORD 		0, 0, 0, 0, 0, 0
	WORD        0, 0, 0, 0, 0, 0

DEF_COMETABOM_1:			; tabela que define o cometa bom na sua primeira fase boa (cor, altura, comprimento, pixels)
	WORD		ALTURA_C
	WORD		COMPRIMENTO
	WORD		0, COR_PRETO, 0, 0, 0
	WORD 		COR_PRETO, COR_PRETO, COR_PRETO, 0, 0
	WORD 		0, COR_PRETO, 0, 0, 0
	WORD        0, 0, 0, 0, 0
	WORD        0, 0, 0, 0, 0

DEF_COMETABOM_2:			; tabela que define o cometa bom na sua segunda fase boa (cor, altura, comprimento, pixels)
	WORD		ALTURA_C
	WORD		COMPRIMENTO
	WORD 		0, COR_PRETO, COR_BRANCO, 0, 0
	WORD		COR_BRANCO, COR_BRANCO, COR_PRETO, COR_PRETO, 0
	WORD 		COR_PRETO, COR_PRETO, COR_BRANCO, COR_BRANCO, 0
	WORD 		0, COR_BRANCO, COR_PRETO, 0, 0
	WORD 		0, 0, 0, 0, 0
		

DEF_COMETAMAU_1:			; tabela que define o cometa mau na sua primeira fase ma (cor, altura, comprimento, pixels)
	WORD		ALTURA_C
	WORD 		COMPRIMENTO
	WORD		0, COR_AZUL, 0, COR_AZUL, 0
	WORD		0, 0, COR_AZUL, 0, 0
	WORD		0, COR_AZUL, 0, COR_AZUL, 0
	WORD 		0, 0, 0, 0, 0
	WORD        0, 0, 0, 0, 0

DEF_COMETAMAU_2:			; tabela que define o cometa mau na sua segunda fase ma (cor, altura, comprimento, pixels)
	WORD 		ALTURA_C
	WORD		COMPRIMENTO
	WORD		COR_AZUL, 0, 0, COR_AZUL, 0
	WORD		COR_AZUL, 0, 0, COR_AZUL, 0
	WORD 		0, COR_AZUL, COR_AZUL, 0, 0
	WORD 		COR_AZUL, 0, 0, COR_AZUL, 0
	WORD 		0, 0, 0, 0, 0

DEF_COMETAMAU:				; tabela que define o cometa mau na sua fase final (cor, altura, comprimento, pixels)
	WORD		ALTURA_C
	WORD		COMPRIMENTO
	WORD 		COR_AZUL, 0, 0, 0, COR_AZUL
	WORD 		COR_AZUL, 0, COR_AZUL, 0, COR_AZUL
	WORD		0, COR_AZUL, COR_AZUL, COR_AZUL,0
	WORD		COR_AZUL, 0, 0, 0, COR_AZUL
	WORD 		COR_AZUL, 0, 0, 0, COR_AZUL

DEF_EXPLOSAO:				; tabela que define a explosao resultante de qualquer cometa com o missil ou rover (cor, altura, comprimento, pixels)
	WORD 		ALTURA_C
	WORD 		COMPRIMENTO
	WORD		0, COR_LARANJA, 0, COR_LARANJA, 0
	WORD		COR_LARANJA, 0, COR_LARANJA, 0, COR_LARANJA
	WORD   		0, COR_LARANJA, 0, COR_LARANJA, 0
	WORD 		COR_LARANJA, 0, COR_LARANJA, 0, COR_LARANJA
	WORD        0, COR_LARANJA, 0, COR_LARANJA, 0

DEF_BOM_MAU:			; tabela que contem todas as tabelas de cometa bom ou mau, de modo a posteriormente representar mais facilmente um cometa bom ou mau
	WORD 	DEF_COMETA_1, DEF_COMETA_2, DEF_COMETABOM_1, DEF_COMETABOM_2, DEF_COMETA
	WORD    DEF_COMETA_1, DEF_COMETA_2, DEF_COMETAMAU_1, DEF_COMETAMAU_2, DEF_COMETAMAU

DEF_MISSIL:				; tabela que define o missil (cor, altura, comprimento, pixels)
	WORD 		LARGURA_MISSIL
	WORD 		COR_PRETO



; **********************************************************************
; * Codigo para o desenho dos elementos
; **********************************************************************

PLACE      0

inicio:
	MOV  SP, SP_inicial_prog_princ		; inicializa SP para a palavra a seguir
						; à última da pilha
	MOV  BTE, tab

    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRA], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV	R7, 1			; valor a somar à coluna do boneco, para o movimentar
	CALL registos_nao_tecla
	CALL controla_jogo
	CALL rover
	CALL display
	MOV R10, 0
	cria_cometas: 			; ciclo que controla o numero de cometas que vao ser criados
		CMP R10, 4 			; limita a 4 o numero de cometas existentes no ecra do jogo
		JZ seguinte
		MOV R2, 1	
		MOV R7, R10
		MOV R9, 8
		MUL R7, R9			; multiplica o numero da execucao do cometa (0,1,2,3) por 8, de modo a criar um intervalo de 8 pixeis entre cometas 
		CALL novo_cometa
		ADD R10, 1
		JMP cria_cometas
	seguinte:
		CALL missil 
	EI0
	EI1
	EI2
	EI


; **********************************************************************
; Processo
;
; TECLADO - Processo que deteta quando se carrega numa tecla
;		  do teclado e escreve o valor da tecla num LOCK.
;
; **********************************************************************

PROCESS SP_inicial_teclado

registos_nao_tecla: 		; contem todos os registos a serem utilizados no espera_nao_tecla
	MOV R6, 4
	MOV R10, 8

espera_nao_tecla:			; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	YIELD
	CALL	teclado			; leitura às teclas
	CMP	R0, 0
	JNZ	espera_nao_tecla	; espera, enquanto houver tecla uma tecla carregada

	

inicializa_Registos:		; inicializa os registos a serem utilizados no espera_tecla
    MOV R6, 1
    MOV R10, 8

espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	YIELD
	CALL	teclado			; leitura às teclas
	CMP	R0, 0
    JNZ loops               ; converte a tecla num valor de 0-15
    CMP R6, R10
    JZ  inicializa_Registos 
    SHL R6, 1				; caso a tecla premida nao esteja na linha que o registo esta a verificar, passa para a proxima
	JMP	espera_tecla		; volta a verificar se existe uma tecla premida na linha seguinte

loops:
    MOV  R2, 0
    MOV  R3, 0
    MOV  R4, 4
    loop_linha:
        SHR R0, 1          ; menos 1 bit para verificar 
        CMP R0, 0	     
        JZ loop_coluna
        ADD R2, 1		   ; R2 armazena o numero da linha da tecla
        JMP loop_linha
    loop_coluna:
        SHR R6, 1		   ; menos 1 bit para verificar
        CMP R6, 0
        JZ  proximo 
        ADD R3, 1		   ; R3 armazena o numero da coluna da tecla
        JMP loop_coluna
    proximo:
        MOV R0, R2		   ; R0 passa a ter o valor igual ao numero da linha
        MOV R6, R3		   ; R6 passa a ter o valor igual ao numero da coluna
        MUL R6, R4		   ; o numero da coluna multiplica por 4
        ADD R0, R6		   ; adiciona-se ao numero da linha o resultado da operaçao anterior, obtendo assim o num. de 0-15 que representa a tecla
    MOV [tecla_carregada], R0
	JMP inicializa_Registos

teclado:
	MOV  R7, TEC_LIN   ; endereço do periférico das linhas
	MOV  R9, TEC_COL   ; endereço do periférico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R7], R6      ; escrever no periférico de saída (linhas)
	MOVB R0, [R9]      ; ler do periférico de entrada (colunas)
	AND  R0, R5        ; elimina bits para além dos bits 0-3
	RET




; **********************************************************************
; Processo
;
; CONTROLA - Processo que deteta se o utlizador pretende começar, pausar,
; 		continuar ou terminar o jogo
;
; **********************************************************************

PROCESS SP_inicial_controla

controla_jogo:
	MOV R0, [tecla_carregada]
	MOV R2, 2
	MOV R1, 12
	CMP R0, R1
	JZ comeca_jogo 				; caso a tecla premida seja a tecla 'C', começa o processo de iniciar o jogo
	MOV R1, 13
	CMP R0, R1
	JZ pausa_ou_continua		; caso a tecla premida seja a tecla 'D', comeca o processo de pausar/retomar o jogo
	MOV R1, 14
	CMP R0, R1
	JZ termina_jogo				; caso a tecla premida seja a tecla 'E', comeca o processo de terminar o jogo
	JNZ controla_jogo

comeca_jogo:
	MOV R1, 1
	MOV [jogo_bloqueado], R1	; desbloqueia o jogo 
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo nº1
	MOV [ESTADO_JOGO], R1		; coloca o estado do jogo como em execucao 
	JMP controla_jogo

pausa_ou_continua:				; verifica se a tecla foi premida para pausar ou retomar o jogo
	CMP R3, 0					; se R3 = 0, o jogador pretende que o jogo seja pausado
	JZ pausa_jogo
	JMP continua_jogo			; caso contrario, pretende que o jogo seja retomado
pausa_jogo:
	ADD R3, 1 
	MOV R1, 0
	MOV [ESTADO_JOGO], R1		; define o estado de jogo para parado
	MOV R1, 2
	MOV [SELECIONA_CENARIO_FUNDO], R1	; seleciona o ecrã nº2 (de pausa)
	MOV R2, APAGA_ECRA			; apaga todos os desenhos no ecrã
	MOV R6, [DEF_ECRA]
	MOV [R2], R6	
	JMP controla_jogo
continua_jogo:					; ciclo que retoma o jogo
	SUB R3, 1
	MOV R4, 1
	MOV [ESTADO_JOGO], R4		; coloca o estado do jogo em execucao
	MOV [jogo_bloqueado], R4		; desbloqueia o jogo
	MOV [SELECIONA_CENARIO_FUNDO], R4	; seleciona o ecrã nº1 (de jogo)
	JMP controla_jogo

termina_jogo:					; processo que termina o jogo
	MOV R1, 0
	MOV [ESTADO_JOGO], R1		; para o jogo
	MOV R1, 3
	MOV [SELECIONA_CENARIO_FUNDO], R1		; seleciona o ecrã nº3 (fim voluntário de jogo)
	MOV R2, APAGA_ECRA						; apaga todos os desenhos no ecrã 
	MOV R6, [DEF_ECRA]
	MOV [R2], R6
	JMP fim_jogo
fim_jogo:
	JMP fim_jogo				; ciclo bloqueante que marca o fim do programa


; **********************************************************************
; Processo
;
; ROVER - Processo que desenha o Rover e o move horizontalmente,
;	dependendo da tecla que esta a ser premida para que tal aconteça
;
; **********************************************************************

PROCESS SP_inicial_rover

rover:					; processo que implementa o comportamento do rover
	; desenha o rover na sua posição inicial
	PUSH R1
	MOV R1, 0
	MOV [DEF_ECRA], R1
	CALL apaga_boneco
	POP R1
	MOV R10, [jogo_bloqueado]
rover_next:
	MOV R8, 0
	MOV R11, [ESTADO_JOGO]
	CMP R8, R11
	JZ rover
    MOV R1, [LINHA]			; linha do rover
	MOV	R2, [COLUNA]		; coluna do rover
	MOV	R4, DEF_BONECO		; endereço da tabela que define o rover


mostra_rover:
	PUSH  R1
	MOV	  R1, 0
	MOV [DEF_ECRA], R1			; define o ecrã para o ecrã onde está o rover
	POP   R1
	CALL	desenha_rover		; desenha o rover a partir da tabela
	JMP  ve_tecla


ve_tecla:
	MOV R0, [tecla_carregada] 					; bloqueia neste LOCK até uma tecla ser carregada





; **********************************************************************
; * Verificação de qual a tecla que está a ser premida e movimentação do rover
; **********************************************************************

funcao_tecla:     				; controla qual a tecla lida e o processo que esta inicia
	CMP	R0, TECLA_ESQUERDA
	JNZ	testa_direita			; caso a tecla premida não seja '0', o programa irá verificar se esta move o rover para a direita
	PUSH R1
	MOV R1, 0
	MOV [DEF_ECRA], R1			; define o ecrã para o ecrã onde está o rover
	POP R1
	MOV	R7, -1					; vai deslocar para a esquerda
	JMP	ve_limites

testa_direita:
    CMP R0, TECLA_DIREITA
	JNZ	ve_tecla		; como a tecla não faz nenhum dos processos pretendidos, vai ser lido o teclado de novo
	PUSH R1
	MOV R1, 0
	MOV [DEF_ECRA], R1			; define o ecrã para o ecrã onde está o rover
	POP R1
    MOV R7, +1

ve_limites:
	MOV	R6, COMPRIMENTO			; obtém o comprimento do boneco
	CALL	testa_limites		; vê se chegou aos limites do ecrã e se sim força R7 a 0
    CMP R7, 0
	JZ	ve_tecla	; se não é para movimentar o objeto, vai ler o teclado de novo

move_rover:
	PUSH R1
	MOV R1, 0
	MOV [DEF_ECRA], R1
	CALL	apaga_boneco		; apaga o rover na sua posição corrente
	POP R1

coluna_seguinte:
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)
	MOV [COLUNA], R2
	JMP	rover_next	; vai desenhar o rover de novo


; **********************************************************************
;
; DESENHO DO ROVER  - Desenha o rover na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
;
; **********************************************************************

desenha_rover:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R9
    PUSH    R8
	MOV	R9, [R4]			; obtém a altura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
    MOV R8, [R4]          ; r8 tem o comprimento 
    ADD R4, 2

desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel		; escreve cada pixel do boneco
	ADD	 R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R8, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
    SUB  R9, 1
    JNZ   nova_linha
    MOV R1, LINHA
    POP R8
    POP	R9
	POP	R4
	POP	R3
	POP	R2
	RET

nova_linha:
    MOV  R8, COMPRIMENTO
    ADD  R1, 1
    SUB  R2, COMPRIMENTO
    JMP  desenha_pixels

; **********************************************************************
;
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
;
; **********************************************************************

apaga_boneco:
	PUSH	R2
    PUSH    R11
    MOV     R11, R1 
    CALL    atraso
    MOV     R2, APAGA_BONECO                 ; O ecrã onde se encontra o rover irá ser apagado
    MOV     [R2], R11
    POP     R11
    POP     R2
    RET

; **********************************************************************
;
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET

; **********************************************************************
;
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************

atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET

; **********************************************************************
;
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
;
; **********************************************************************

testa_limites:
	PUSH	R10
	PUSH	R6
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R10, MIN_COLUNA
	CMP	R2, R10
	JGT	testa_limite_direito
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R10, MAX_COLUNA
	CMP	R6, R10
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	R6
	POP	R10
	RET





; **********************************************************************
; Processo
;
; COMETA - Processo que desenha o cometa e o move verticalmente, com
;		 temporização marcada pela interrupção 1
;
; **********************************************************************



PROCESS SP_inicial_cometa	

novo_cometa:					; verifica se o jogo esta bloqueado ou nao
	MOV R0, [jogo_bloqueado]

novo_cometa_next:				; aplica o processo atraso de 8 pixeis no desenho dos cometas iniciado no processo de CALL dos 4 cometas
	CMP R7, 0					; quando o nº de execucao do cometa passar a ser 0, este pode comecar a sua movimentacao
	JZ gera_bom_mau
	MOV R0, [cometa_lock]
	SUB R7, 1					; subtrai-se um valor ao nº de execucao do cometa por cada ciclo completo do relogio meteoro
	JMP novo_cometa_next

para_cometa:					; caso seja aplicada uma pausa no jogo, este ciclo apaga o cometa na sua posicao corrente
	POP R1
	MOV  [DEF_ECRA], R6
	CALL apaga_boneco_C
	JMP novo_cometa

gera_bom_mau:					; gera um cometa bom ou mau, conforme as probabilidades de geracao pedidas (25% bom, 75% mau)
	MOV R0, 0
	MOV R11, [ESTADO_JOGO]		
	CMP R0, R11
	JZ para_cometa				; caso o jogo se encontre parado (em pausa) 
	PUSH R2
	PUSH R3
	MOV R3, TEC_COL				;	PROCESSO DE ESCOLHA DE UM NUMERO ALEATORIO		
	MOVB  R6, [R3]				;	Numero 0 - Cometa bom
	MOV  R2, 8					;	Numeros 1,2,3 - Cometa mau
	SHR  R6, 6  				;	------------------------------------------			
	POP R3
	POP R2

verifica_bom_mau:				; verifica se um cometa e bom ou mau a partir do seu numero gerado aleatoriamente anteriormente
	CMP R6, 0				
	JZ  c_bom 					; caso o cometa seja bom
	MOV R4, 10
	MOV R6, R10
	ADD R6, 1 
	JMP cometa					; inicia a movimentacao de um cometa mau
c_bom:							; define o cometa bom e inicia a sua movimentaca 
	MOV R4, 0
	MOV R6, R10
	ADD R6, 1

cometa:
	MOV  R8, 1   				; linha do cometa
	MOV  R9, DEF_BOM_MAU     	; endereço da tabela que define o cometa
	MOV  R3, 0                  ; contador 
	MOV  R7, +1

	
cria_coluna:					; atribui aleatoriamente um valor de coluna ao cometa
	PUSH R2
	PUSH R3
	MOV R3, TEC_COL				;	PROCESSO DE ESCOLHA DE UMA COLUNA ALEATORIA
	MOVB  R11, [R3]				;	Divide o numero total de colunas em 8 possibilidades (0-7)
	MOV  R2, 8					;	Cada numero agrupa 8 colunas, dividindo assim o ecrã em 8
	SHR  R11, 5					;	possibilidades de colunas diferentes
	MUL  R11, R2				;   ---------------------------------------------------------
	POP R3
	POP R2
	

ciclo_cometa:
	MOV R0, 0
	PUSH R1 
	MOV R1, [ESTADO_JOGO]
	CMP R0, R1
	JZ para_cometa
	POP R1
	PUSH R1
	MOV R1, 1
	MOV  [DEF_ECRA], R6			; define o ecrã para o ecrã onde está o cometa
	PUSH R7
	MOV R7, 5
	CMP  R3, R7
	JZ ciclo_cometa_pops		
	POP R7	
	CALL verifica_estado		; verifica em que estado de movimentacao o cometa se encontra (1,2,3,4 ou final)
	ADD R3, R1
	MOV R4, 2
	JMP ciclo_cometa_next
ciclo_cometa_pops:				; ciclo que da "POP" aos registos a que foram dados "PUSH"
	POP R7
	POP R1
ciclo_cometa_next:
    CALL    desenha_cometa		; desenha o cometa a partir da tabela
	PUSH R2
	MOV R2, [cometa_lock]		; lock que impede o cometa de nao ser desenhado conforme a sua interrupçao
	POP R2

	MOV  [DEF_ECRA], R6 		; define o ecrã para o ecrã onde está o cometa
	CALL apaga_boneco_C


	MOV  [DEF_ECRA], R6 		; define o ecrã para o ecrã onde está o cometa
	ADD  R8, R7			
	JMP verifica_colisao



; **********************************************************************
;
; DESENHO DO COMETA - Desenha um cometa na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
;
; **********************************************************************

desenha_cometa:
	PUSH	R11
	PUSH	R3
	PUSH	R5
	PUSH	R1
    PUSH    R10
	PUSH 	R0
	MOV     R0, R8
	MOV	R1, [R5]			; obtém a altura do  cometa
	ADD	R5, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
    MOV R10, [R5]          ; r10 tem o comprimento 
    ADD R5, 2

desenha_pixels_cometa:       		; desenha os pixels do cometa a partir da tabela
	MOV	 R3, [R5]			; obtém a cor do próximo pixel do cometa
	CALL escreve_pixel_cometa		; escreve cada pixel do cometa
	ADD	 R5, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R11, 1               ; próxima coluna
    SUB  R10, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels_cometa      ; continua até percorrer toda a largura do objeto
    SUB  R1, 1
    JNZ   nova_linha_cometa
fim_desenha:
	POP R0
    POP R10
    POP	R1
	POP	R5
	POP	R3
	POP	R11
	RET

nova_linha_cometa:
	PUSH R4
	PUSH R2
    MOV  R10, COMPRIMENTO
	MOV  R2, R8  
	MOV  R4, MAX_LINHA 
	CMP  R2, R4
	JZ   nao_desenha  		; caso a proxima linha a ser desenhada ultrapasse o limite do ecrã, acaba o ciclo de desenho do cometa
	ADD  R0, 1
    SUB  R11, COMPRIMENTO
	POP R2
	POP R4
    JMP  desenha_pixels_cometa

nao_desenha:
	POP R2
	POP R4
	JMP fim_desenha

; **********************************************************************
;
; APAGA_BONECO_C - Apaga o cometa na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
;
; **********************************************************************

apaga_boneco_C:
	PUSH	R2
    PUSH    R11
    MOV     R11, R6 
    MOV     R2, APAGA_BONECO                 ; O ecrã onde se encontra o cometa irá ser apagado
    MOV     [R2], R11
    POP     R11
    POP     R2
    RET

; **********************************************************************
;
; ESCREVE_PIXEL_COMETA - Escreve um pixel na linha e coluna indicadas.
;
; **********************************************************************

escreve_pixel_cometa:
	MOV  [DEFINE_LINHA], R0		; seleciona a linha
	MOV  [DEFINE_COLUNA], R11		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
;
; COLISOES - Ciclos que testam a possivel colisao do cometa com um missil
;			ou com o rover
;
; **********************************************************************


nao_colisao:					; ciclo que permite que o missil prossiga o seu movimento, caso nao tenha colidido com nenhum cometa
	JMP verifica_colisao_rover

nenhuma_colisao:				; ciclo que, caso seja verificada que nao ocorreu nenhuma colisao, continua com o movimento do cometa para a linha seguinte
	PUSH R4
	PUSH R2
	MOV  R2, R8                 ;[LINHA_COMETA]
	MOV  R4, MAX_LINHA 
	CMP  R2, R4
	JZ   verifica_limite
	POP R2
	POP R4
	JMP ciclo_cometa

verifica_limite:			; verifica se o cometa atingiu o limite do ecrã ou não 
	POP R2
	POP R4
	PUSH R1
	MOV  R1, 1
	PUSH R2
	MOV R2, [cometa_lock]
	POP R2
	CALL apaga_boneco_C
	MOV R8, R1 
	JMP gera_bom_mau






; **********************************************************************
;
; VERIFICA_ESTADO - Verifica qual o estado de movimentação do cometa
; 					(1,2,3,4 ou final) deve ser desenhado, a partir da
;					"word" MOV_COMETA, que contém o valor desse mesmo estado
;
; **********************************************************************

verifica_estado:
	ADD R9, R4
	MOV R5, [R9]
	RET





; **********************************************************************
;
; VERIFICA_COLISAO - Verifica se o cometa colidiu com um missil ou um rover. 
;   Caso isso	se verifique, apaga o missil ou o rover na posicao em que 
;   se verificou a mesma colisao e permite que um novo missil seja disparado,
;   se for esse o caso 
;
; **********************************************************************





colisao:						; ciclo que apaga o missil e permite que um novo seja disparado
	POP R11
	POP R8
	POP R5
	POP R7
	POP R6
	POP R0
	POP R3
	PUSH R1
	MOV  R1, 1
	MOV  [DEF_ECRA], R6			; define o ecrã para o ecrã onde está o cometa
	CALL	apaga_boneco_C		; apaga o boneco na sua posição corrente
	MOV R5, DEF_EXPLOSAO

	MOV  [DEF_ECRA], R6 ; define o ecrã para o ecrã onde está o cometa
	CALL apaga_boneco_C	

	CALL    desenha_cometa		; desenha o cometa a partir da tabela
	PUSH R2
	MOV R2, [cometa_lock]
	POP R2
	CALL apaga_boneco_C

	MOV R8, R1          
	MOV [del_missil], R1  		; indica que o missil pode agora ser apagado
	
	PUSH R5
	PUSH R6
	MOV R5, DEF_COMETAMAU
	MOV R6, [R9]	
	CMP R5, R6 
	JZ aumenta_energia_mau		; caso o registo corrente da tabela DEF_BOM_MAU seja igual a tabela DEF_COMETAMAU
	POP R6
	POP R5
	POP R4
	POP R1
	JMP gera_bom_mau




aumenta_energia_mau:			; ciclo que representa o aumento de energia do rover no display resultante da destruiçao de um cometa mau
	POP R6
	POP R5
	PUSH R7
	PUSH R0
	MOV R7, [ENERGIA_ATUAL]
	ADD R7, 5					; adiciona o aumento de energia que esta destruicao representa (5%)
	MOV [ENERGIA_ATUAL], R7


	MOV R0, [ENERGIA_ATUAL]
	CALL dec_para_hex
	MOV [DISPLAYS], R0
	POP R0
	POP R7
	POP R5
	POP R1
	JMP gera_bom_mau

verifica_colisao_linha:			; ciclo que verifica se o missil se encontra numa das linhas que o cometa ocupa
	CMP R8, R3
	JZ  colisao					; caso estes ocupem a mesma linha, inicia-se o processo de remocao do missil
	ADD R8, R6					; como nao se verificou uma colisao, verifica-se a linha seguinte
	CMP R8, R5
	JNZ verifica_colisao_linha	; caso a proxima linha a ser verificada nao tenha ultrapassado a ultima linha do cometa, repete-se o ciclo
	POP R11
	POP R8
	POP R5
	POP R7
	POP R6
	POP R0
	POP R3
	JMP nao_colisao				; caso nenhuma das linhas sejam iguais, o cometa nao colide

verifica_colisao:				; ciclo que inicia a verificacao da possivel colisao do cometa com um missil
	PUSH R3	
	PUSH R0				
	PUSH R6
	PUSH R7
	PUSH R5
	PUSH R8
	PUSH R11 
	MOV  R3, [LINHA_MISSIL]
	MOV  R0, [COLUNA_MISSIL]
	MOV R7, 5
	ADD R7, R11
	MOV R6, 1
	MOV R5, 4
	ADD R5, R8
verifica_colisao_coluna:		; ciclo que verifica se o missil se encontra numa das colunas que o cometa ocupa
	CMP R11, R0
	JZ verifica_colisao_linha	; caso estes ocupem a mesma coluna, inicia-se a verificacao se estes estao na mesma linha
	ADD R11, R6					; como nao se verificou uma colisao, verifica-se a coluna seguinte
	CMP R11, R7					
	JNZ verifica_colisao_coluna ; caso a proxima coluna a ser verificada nao tenha ultrapassado a ultima coluna do cometa, repete-se o ciclo
	POP R11
	POP R8
	POP R5
	POP R7
	POP R6
	POP R0
	POP R3
	JMP nao_colisao				; caso nenhuma das colunas sejam iguais, o cometa nao colide


colisao_rover:					; ciclo que realiza todas as açoes a serem realizadas caso o rover colida com o cometa
	PUSH R2
	PUSH R3
	MOV R2, [R9]
	MOV R3, DEF_COMETA
	CMP R3, R2
	JZ 	aumenta_energia_rover	; caso o registo corrente da tabela DEF_BOM_MAU seja igual a DEF_COMETA, o rover colidiu com um cometa bom
	POP R3						; caso contrario, colidiu com um cometa mau, logo o jogador perdeu o jogo, iniciando-se o processo de fim do jogo
	POP R2
	MOV R1, 0
	MOV [ESTADO_JOGO], R1		; para o jogo
	MOV R1, 4
	MOV [SELECIONA_CENARIO_FUNDO], R1		; seleciona o ecrã nº4 (perder o jogo por colisao com um cometa mau)
	MOV R2, APAGA_ECRA			; apaga todos os desenhos do ecrã
	MOV R6, [DEF_ECRA]
	MOV [R2], R6
	JMP fim_jogo_colisao

fim_jogo_colisao:				; ciclo que impede a continuacao do programa, marcando o fim da sua execucao
	JMP fim_jogo

aumenta_energia_rover:			; ciclo que representa o aumento de 10% do display devido a colisao do rover com um cometa bom e da um som pelo ocorrido
	POP R3
	POP R2
	PUSH R6
	PUSH R7
	PUSH R0
	PUSH R8
	MOV R6, 10
	MOV R7, [ENERGIA_ATUAL]
	ADD R7, R6
	MOV [ENERGIA_ATUAL], R7
	MOV R0, [ENERGIA_ATUAL]
	CALL dec_para_hex
	MOV [DISPLAYS], R0
	MOV R8, 1
	MOV [TOCA_SOM], R8			; toca o som de colisao do rover com um cometa bom
	POP R8
	POP R0
	POP R7
	POP R6
	JMP colisao




verifica_colisao_linha_rover:			; ciclo que verifica se o rover se encontra numa das linhas que o cometa ocupa
	CMP R8, R3
	JZ  colisao_rover					; caso estes ocupem a mesma linha, o rover colidiu com um cometa
	ADD R8, R6					; como nao se verificou uma colisao, verifica-se a linha seguinte
	CMP R8, R5
	JNZ verifica_colisao_linha_rover	; caso a proxima linha a ser verificada nao tenha ultrapassado a ultima linha do cometa, repete-se o ciclo
	POP R11
	POP R8
	POP R5
	POP R7
	POP R6
	POP R0
	POP R3
	JMP nenhuma_colisao

verifica_colisao_rover:					; inicia o processo de verificacao da possivel colisao entre o rover e um cometa
	PUSH R3
	PUSH R0				
	PUSH R6
	PUSH R7
	PUSH R5
	PUSH R8
	PUSH R11 
	MOV  R3, [LINHA]
	MOV  R0, [COLUNA]
	MOV R7, 5
	ADD R7, R11
	MOV R6, 1
	MOV R5, 4
	ADD R5, R8
verifica_colisao_coluna_rover:		; ciclo que verifica se o rover se encontra numa das colunas que o cometa ocupa
	CMP R11, R0
	JZ verifica_colisao_linha_rover	; caso estes ocupem a mesma coluna, inicia-se a verificacao se estes estao na mesma linha
	ADD R11, R6					; como nao se verificou uma colisao, verifica-se a coluna seguinte
	CMP R11, R7					
	JNZ verifica_colisao_coluna_rover ; caso a proxima coluna a ser verificada nao tenha ultrapassado a ultima coluna do cometa, repete-se o ciclo
	POP R11
	POP R8
	POP R5
	POP R7
	POP R6
	POP R0
	POP R3
	JMP nenhuma_colisao









; **********************************************************************
; Processo
;
; Missil - Processo que inicializa o display com valor 100 e o atualiza
; ao longo da utilização do programa
;		
;
; **********************************************************************

PROCESS SP_inicial_missil


missil:
	MOV R0, [jogo_bloqueado]
missil_next:
	MOV R0, 0
	MOV R11, [ESTADO_JOGO]
	CMP R0, R11
	JZ missil
	PUSH R2
	MOV R2, 0
	MOV [LINHA_MISSIL], R2 
	MOV [COLUNA_MISSIL], R2
	POP R2
	MOV R0, [tecla_carregada]
	CMP R0, TECLA_MISSIL
	JZ	processo_missil				
	JMP missil_next						; caso a tecla premida nao seja a de disparar um missil, a verificacao da mesma volta a ocorrer

processo_missil:
	PUSH R9
	PUSH R8
	PUSH R0
	PUSH R5
	PUSH R3
	PUSH R4
	MOV R8, 0
	MOV [TOCA_SOM], R8				; execucao do som de disparo do missil
	MOV R9, 1
	MOV [display_lock], R9
	MOV R0, [LINHA]					; linha do rover
	MOV	R5, [COLUNA]				; coluna do rover
	MOV R3, 1
	MOV R4, 2
	SUB R0, R3						; subtrai-se um valor a linha do rover, de modo a que missil seja disparado uma linha acima do rover
	ADD R5, R4						; aumenta-se em dois valores a coluna do rover, de modo a que missil seja disparado do centro do rover
	MOV [LINHA_MISSIL], R0			; linha do missil
	MOV [COLUNA_MISSIL], R5			; coluna do missil
	POP R9
	POP R8
	POP R4
	POP R3
	POP R5
	POP R0
	MOV R1, [LINHA_MISSIL]			; R1- linha do missil
	MOV R2, [COLUNA_MISSIL]			; R2 - coluna do missil
	MOV	R4, DEF_MISSIL				; endereço da tabela que define o missil
	MOV R7, -1
	MOV R8, 0
	MOV R9, 1
	MOV R10, 17




ciclo_missil:						; ciclo que representa a movimentacao do missil no ecra, conforme a interrupçao 2
	PUSH R1
	MOV  R1, 5
	MOV  [DEF_ECRA], R1				; define o ecrã para o ecrã onde está o missil
	POP R1


	CALL	desenha_missil			; desenha o missil a partir da tabela

	MOV	R3, [missil_lock]			; lê o LOCK e bloqueia até a interrupção escrever nele
									; Quando bloqueia, passa o controlo para outro processo
									; Como não há valor a transmitir, o registo pode ser um qualquer


	PUSH R1
	MOV  R1, 5
	MOV  [DEF_ECRA], R1				; define o ecrã para o ecrã onde está o missil
	CALL	apaga_missil			; apaga o missil na sua posição corrente
	POP R1


	MOV	R6, [R4]					; obtém a largura do missil
	CALL	testa_limites_missil	; vê se chegou aos limites do missil
	ADD	R1, R7						; para desenhar o missil na linha seguinte
	MOV [LINHA_MISSIL], R1
	ADD R8, R9
	CMP R8, R10
	JZ 	missil_next
	JMP check_colisao
						



; **********************************************************************
; DESENHA_MISSIL - Desenha um missil na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o missil
;
; **********************************************************************

desenha_missil:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels_missil:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel_missil		; escreve cada pixel do boneco
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET

; **********************************************************************
; APAGA_MISSIL - Apaga o missil na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o missil
;
; **********************************************************************

apaga_missil:
	PUSH	R2
    PUSH    R11
    MOV     R11, R1 
;    CALL    atraso_missil
    MOV     R2, APAGA_BONECO                 ; O ecrã onde se encontra o missil irá ser apagado
    MOV     [R2], R1
    POP     R11
    POP     R2
    RET


; **********************************************************************
; CHECK_COLISAO - Verifica se o missil colidiu um cometa e, em caso
; afirmativo, apaga o mesmo e permite que um novo missil seja desenhado
; **********************************************************************

check_colisao:
	MOV R0, [del_missil]
	CMP R0, 1
	JZ apaga_missil_colisao
	JMP ciclo_missil
apaga_missil_colisao:
	PUSH R1
	MOV R1, 5
	MOV [DEF_ECRA], R1
	SUB R0, 1
	MOV [del_missil], R0
	CALL apaga_missil 
	POP R1
	JMP missil_next





; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************

escreve_pixel_missil:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; TESTA_LIMITES_MISSIL - Testa se o missil chegou aos limites do ecrã
;
; 	Argumentos:			R1 - linha em que o missil está
;						R6 - largura do missil
;						R7 - movimento para cima do missil
;	
; **********************************************************************

testa_limites_missil:
	PUSH	R5
	PUSH	R6
testa_limite_superior:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_LINHA
	CMP	R1, R5
	JLE	sai_testa_limites_missil
	CMP R7, 0
	JGT impede_movimento_missil
	JMP sai_testa_limites_missil
impede_movimento_missil:
	MOV R7, 0						; o movimento é impedido
	MOV R8, 16 

sai_testa_limites_missil:	
	POP	R6
	POP	R5
	RET








; **********************************************************************
; Processo
;
; Display - Processo que inicializa o display com valor 100 e o atualiza
; ao longo da utilização do programa
;		
;
; **********************************************************************

PROCESS SP_inicial_display

display:					; representa, no momento de inicio do programa, o display com energia maxima (100%)
	MOV R0, [ENERGIA_ATUAL]
	CALL dec_para_hex
	MOV [DISPLAYS], R0
check_display:				; verifica se o jogo esta parado ou nao
	MOV R7, [jogo_bloqueado]
display_next:
	MOV R0, [ENERGIA_ATUAL]
	CALL dec_para_hex
	MOV [DISPLAYS], R0
	MOV R8, 0
	MOV R11, [ESTADO_JOGO]	
	CMP R8, R11
	JZ check_display

diminui_energia:			; ciclo que representa a diminuicao da energia do rover, quer devido ao relogio display, quer por disparo de um missil
	MOV R8, 0
	MOV R11, [ESTADO_JOGO]
	CMP R8, R11
	JZ check_display
	MOV R2, [display_lock]
	MOV R1, 5
	MOV R0, [ENERGIA_ATUAL]
	SUB R0, R1
	MOV [ENERGIA_ATUAL], R0
	CALL dec_para_hex
	MOV [DISPLAYS], R0
	MOV R9, [ENERGIA_ATUAL]
	CMP R9, 0				; verifica se a energia chegou a 0%
	JZ termina_jogo_display	; caso tal se verifique, inicia o processo de terminar o jogo 
	JMP display_next



termina_jogo_display:
	MOV R1, 0
	MOV [ESTADO_JOGO], R1
	MOV R1, 3
	MOV [SELECIONA_CENARIO_FUNDO], R1	; seleciona o ecrã 3 (fim de jogo devido a esgotamento da energia)
	MOV R2, APAGA_ECRA
	MOV R6, [DEF_ECRA]
	MOV [R2], R6
	JMP fim_jogo_display

fim_jogo_display:		; ciclo que impede a execucao de qualquer outro processo, marcando assim o fim do programa
	JMP fim_jogo

; **********************************************************************
; DEC_PARA_HEX - Ciclo que converte um numero decimal num numero hexa-
; decimal, de modo a poder representar o decimal no display
;
; **********************************************************************
dec_para_hex:		
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R1, 1
	MOV R2, 10
	MOV R4, 0
	loop:
		MOV R3, R0
		MOD R3, R2
		MUL R3, R1 
		ADD R4, R3
		SHL R1, 4
		DIV R0,	R2
		JNZ loop
	MOV R0, R4
	POP R1
	POP R2
	POP R3
	POP R4
	RET




; **********************************************************************
;      ---------------------------------------------------------
; PROCESSAMENTO DAS ROTINAS DE INTERRUPÇÃO (COMETA, MISSIL E ENERGIA)
;      ---------------------------------------------------------
; **********************************************************************

rot_int_0:						; rotina de interrupcao do cometa
	MOV [cometa_lock], R2
	RFE

rot_int_1:						; rotina de interrupcao do missil
	MOV [missil_lock], R2
	RFE

rot_int_2:						; rotina de interrupcao da energia
	MOV [display_lock], R2
	RFE








