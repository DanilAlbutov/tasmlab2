;*********************************************************
; Процедуры для учебного примера лабораторной работы N 1  *
; по МОП. 10.09.02: Негода В.Н.                           *
;*********************************************************

.MODEL SMALL
.CODE
.386
 INCLUDE MLAB1.INC
 LOCALS
;=====================================================
; Подпрограмма вывода на экран строки, адресуемой SI, 
; с задержкой времени между символами в <CX,DX> mcs.
; Завершителями строки являеются байты 0 или 0FFh.
; ЕСЛИ строка заканчивается байтом 0,
;   ТО добавляется переход в начало новой строки
; 
;=====================================================
PUTSS   PROC	NEAR
@@L:    MOV	AL,	[SI]
        CMP	AL,	0FFH
        JE	@@R
        CMP	AL,	0
        JZ	@@E
        CALL	PUTC
        INC	SI
	CALL	DILAY
        JMP	SHORT @@L
        ; Переход на следующую строку
@@E:    MOV	AL, CHCR
        CALL	PUTC
        MOV	AL, CHLF
        CALL	PUTC
@@R:    RET
PUTSS	ENDP

;==============================================
; Подпрограмма вывода AL на терминал
;==============================================
PUTC	PROC	NEAR
        PUSH	DX
        MOV	DL,   AL
        MOV	AH,   FUPUTC
        INT	DOSFU
        POP	DX
        RET
PUTC	ENDP

;==============================================
; Подпрограмма ввода символа в AL с терминала
;==============================================
GETCH	PROC	NEAR
        MOV	AH,   FUGETCH
        INT	DOSFU
        RET
GETCH	ENDP

;=================================================
; Подпрограмма ввода строки в буфер, адресуемый DX
;   и имеющий структуру: 
;    { char size; // размер буфера 
;      char len;  // реально введено
;      char str[size]; // символы строки }
;=================================================
GETS	PROC	NEAR
	PUSH	SI
	MOV	SI,	DX
        MOV	AH,	FUGETS
        INT	DOSFU
	; прописать байт 0 в конец строки
	XOR	AH,	AH
	MOV	AL,	[SI+1]
	ADD	SI,	AX
	MOV	BYTE PTR [SI+2], 0
	POP	SI
        RET
GETS	ENDP

;==============================================
; Подпрограмма подсчета числа символов в строке,
; адресуемой SI. Завершители строки: 0 и 0FFh
; Результат возвращается в AX
;==============================================
SLEN	PROC	NEAR
	XOR     AX,   AX
LSLEN:  CMP     BYTE PTR [SI], 0
	JE	RSLEN
        CMP     BYTE PTR [SI], 0FFh
	JE	RSLEN
	INC	AX
	INC	SI
	JMP	SHORT	LSLEN
RSLEN:  RET
SLEN 	ENDP

;====================================================
; Подпрограмма преобразования <EDX,EAX> в беззнаковое 
; десятичное, размещаемое по адресу DI
;==============================================
	.DATA
UBINARY	DQ	0  ; Исходное двоичное 64-разрядное
UPACK	DT	0  ; Упакованные 18 десятичных цифр	
	.CODE
UTOA10	PROC	NEAR
	PUSH	CX
	PUSH	DI
	MOV	DWORD PTR [UBINARY],   EAX
	MOV	DWORD PTR [UBINARY+4], EDX
	FINIT			; инициализация сопроцессора
	FILD	UBINARY		; забрасывание в него бинарного
	FBSTP	UPACK		; извлечение упаковонного десятичного
	MOV	CX,	LENPACK	; получено 9 пар цифр
	PUSH	DS		; писать 
	POP	ES 		;   будем
	CLD     		;     через stosw
	LEA	SI,	UPACK   ;     с конца 
	ADD	SI,	LENPACK	;     буфера upack        
	; Цикл преобразования пар полубайтов в ASCII-коды цифр
@@L:	XOR	AX,	AX
	DEC	SI
	MOV	AL,	[SI]
	SHL	AX,	4
	SHR	AL,	4	
	ADD	AX,	3030h
	XCHG	AL,	AH
	STOSW		
	LOOP	@@L
	; Фиксация конца строки
	XOR	AL, 	AL
	STOSB
	; Улучшим читабельность слишком длинного числа
	CLD
	MOV	AX,	LENNUM-4	
@@L1:	MOV	CX,	AX
	POP	DI	   ; встаем на начало строки
	PUSH	DI	
	MOV	SI,	DI
	INC	SI
	REP	MOVSB
	MOV	BYTE PTR [DI], CHCOMMA ; вставить разделитель троек цифр
	SUB	AX,	4  ;     3 цифры + разделитель обработаны
	JS	@@E        ; прекратить, если осталось не больше 3-х цифр
	JMP	SHORT	@@L1
@@E:	POP	SI
	PUSH	SI
	XOR	CX,	CX
	; Съедаем первые нули
	;   сначала подсчитываем
@@L2:	CMP	BYTE PTR [SI], '0'
	JE	@@N
	CMP	BYTE PTR [SI], CHCOMMA		
	JNE	@@N1
@@N:	INC	CX
	INC	SI
	JMP	SHORT	@@L2
@@N1:	;   а теперь съедаем
	POP	DI
	SUB	CX, LENNUM+1
	NEG	CX
	REP	MOVSB
	POP	CX
        RET
UTOA10	ENDP

;==============================================
; Подпрограмма задержки выполнения программы 
; на <CX,DX> микросекунд 
;==============================================
DILAY	PROC	NEAR
	MOV	AH,	86h
        INT	15h
        RET
DILAY	ENDP

OutBin proc
 
    mov ebx,eax
	mov cx,20
	mov si, 0
	shl ebx, 12
ob1:
    shl ebx,1
    jc ob2
    
    mov dl,'0'
    jmp ob3
    
ob2:
    mov dl,'1'
ob3:
    mov ah,2
    int 21h
	inc si
	cmp si,4
	je ob4
ob5:
    loop ob1
    ret
ob4:
	mov dl,20h
	mov ah,2
    int 21h
	mov si, 0
	jmp ob5
OutBin endp



        PUBLIC	PUTSS, PUTC, GETCH, GETS, DILAY, SLEN, UTOA10, OutBin

        END
