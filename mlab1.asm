;***************************************************************************************************
; MLAB1.ASM - учебный пример для выполнения 
; лабораторной работы N1 по машинно-ориентированному программированию
; 10.09.02: Негода В.Н.
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       Используются декларации констант и макросов
        INCLUDE MLAB1.INC	
        INCLUDE MLAB1.MAC

; Декларации данных
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"Фамилия И.О.: ",0FFh
MINIS	DB	"МИНИСТЕРСТВО ОБРАЗОВАНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ",0
ULSTU	DB	"УЛЬЯНОВСКИЙ ГОСУДАРСТВЕННЫЙ ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ",0
DEPT	DB	"Кафедра вычислительной техники",0
MOP	DB	"Машинно-ориентированное программирование",0
LABR	DB	"Лабораторная работа N 1 вариант 1",0
REQ1    DB      "Замедлить(-),ускорить(+),выйти(ESC),Лабораторная(l) ? ",0FFh
TACTS   DB	"Время работы в тактах: ",0FFh
EMPTYS	DB	0
BUFLEN = 70
BUF	DB	BUFLEN
LENS	DB	?
SNAME	DB	BUFLEN DUP (0)
PAUSE	DW	0, 0 ; младшее и старшее слова задержки при выводе строки
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; строка вывода числа тактов
                                          ; запас для разделительных "`"
										  

F db "F = x1x2x3 | x2!x3x4 | !x1!x2  | x1!x2x3!x4 | x3x4",0
x db "Введите X",0
y db "Введите Y",0
F_str db "F = ",0FFh
Z1 db "Z = X/4 + 4 * Y", 0
Z2 db "Z = X/8 - Y", 0
z db "Преобразования: z3 = !z3; z2 |= z19; z7 &= z8",0
do db "До преобразований",0
posle db "После преобразований",0
res db 21

        .CODE
; Макрос заполнения строки LINE от позиции POS содержимым CNT объектов,
; адресуемых адресом ADR при ширине поля вывода WFLD
BEGIN	LABEL	NEAR
	; инициализация сегментного регистра
	MOV	AX,	@DATA
	MOV	DS,	AX
	; инициализация задержки
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; запрос имени
	; ввод имени
	LEA	DX,	BUF
	CALL	GETS
@@L:	; циклический процесс повторения вывода заставки
	; вывод заставки
	; ИЗМЕРЕНИЕ ВРЕМЕНИ НАЧАТЬ ЗДЕСЬ
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; разделительная черта
	PUTL	EMPTYS
	PUTLSC	MINIS	; первая 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  и  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   последующие 
	PUTL	EMPTYS
	PUTLSC	MOP	;    строки  
	PUTL	EMPTYS
	PUTLSC	LABR	;     заставки
	PUTL	EMPTYS
	; приветствие
	PUTLSC	SNAME   ; ФИО студента
	PUTL	EMPTYS
	; разделительная черта
	PUTL	SLINE
	; ИЗМЕРЕНИЕ ВРЕМЕНИ ЗАКОНЧИТЬ ЗДЕСЬ 
	DURAT    	; подсчет затраченного времени
	; Преобразование числа тиков в строку и вывод
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; вывод числа тактов
	; обработка команды
get:	
	PUTL	REQ1 ;вывод текста
	CALL	GETCH ;помещение символа в AL с терминала
	CMP	AL,	'-'    ; удлиннять задержку?
	JNE	CMINUS
	INC	PAUSE+2        ; добавить 65536 мкс
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; укорачивать задержку?
	JNE	CEXIT
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; убавить 65536 мкс
BACK:	JMP	@@L
CEXIT:	CMP	AL,	CHESC
	jne input
	JE	@@E
	TEST	AL,	AL
	JNE	BACK
	CALL	GETCH
	JMP	@@L
	; Выход из программы
	; начало лабы-------------------------------------------------------------------------------
	
	
input:
	CMP AL,'l' ;если пользователь нажал e 
	jne get
	push ax
	
	mov dl,0ah
	mov ah,02
    int 21h ; выводим перевода строки
	
	pop ax
	mov dl,al
	mov ah,02
	int 21h
	
	mov dl,0ah
	mov ah,02
    int 21h ; выводим перевода строки
Program_start:
	PUTL x
	lea dx, res
    mov ah,0ah
	int 21h
	xor ecx, ecx
	xor eax,eax
	mov si, offset res+2
StrToInt_1:
	mov ebx,2
	mov cl,[si] ; берем символ из буфера
    cmp cl,0dh  ; проверяем не последний ли он
    jz count_F
    sub cl,'0' ; делаем из символа число 
    mul ebx     ; умножаем на 2
    add eax,ecx  ; прибавляем к остальным
    inc si     ; указатель на следующий символ
    jmp StrToInt_1     ; повторяем	
count_F:
	push eax
	call OutBin
	mov dl,0ah
	mov ah,02
    int 21h ; выводим перевода строки
	;x1 x2 x3 | x2 !x3 x4 | !x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	PUTL F
	xor eax,eax
	pop eax ; получение X в eax
	xor bx,bx ; обнуление
	xor ecx,ecx ; обнуление
	
	;x1 x2 x3
	mov bl,000000010b 
	and bl,al ;получение x1 из eax(al) в BL 
	shr bl,1
	mov cl,000000100b 
	and cl,al ;получение x2 из eax в CL
	shr cl, 2 ;сдвигаем вправо на 2 для выравнивания с x2
	and bl,cl ; x1 ^ x2 в BL
	mov cl,000001000b 
	and cl,al ; получение x3 из eax в CL
	shr cl,3 ;вправо на 3 для выравнивания с x1 ^ x2
	and bl,cl; x1 ^ x2 ^ x3
	push bx ; сохраняем в стек результат
	
	;x2 !x3 x4
	mov bl,000000100b 
	and bl,al ; получение x2 из eax в BL
	shr bl,2 ; выровнить x2 до 0ого разряда
	mov cl,000001000b
	and cl,al ; получение x3 из eax в CL
	shr cl,3 ;выровнить x3 до 0ого разряда
	btc cx,0 ;инверсия (!x3)
	and bl,cl ; x1 ^ !x3 в BL
	mov cl,000010000b
	and cl,al ; получение x4 из eax в CL
	shr cl,4 ; выравнивание x4 до 0ого разряда
	and bl,cl ;x1 ^ !x3 ^ x4
	push bx ; сохраняем в стек результат
	
	;!x1 !x2
	mov bl,000000010b 
	and bl,al ;получение x1 из eax(al) в BL 
	shr bl,1
	btc bx,0 ; инвертировать нулевой бит BX (!x1)
	mov cl,000000100b 
	and cl,al ;получение x2 из eax в CL
	shr cl, 2 ;сдвигаем вправо на 2 для выравнивания с x1
	btc cx,0 ; !x2
	and bl,cl ; !x1 ^ !x2 в BL
	push bx ; сохраняем результат в стек
	
	;x1 !x2 x3 !x4
	mov bl,000000010b
	and bl,al ; получение x1 из eax(al) в BL 
	shr bl,1
	mov cl,000000100b
	and cl,al; получение x2 из eax в CL
	shr cl,2
	btc cx,0 ;!x2
	and bl,cl ;x1 ^ !x2	 в BL
	mov cl,000001000b
	and cl,al; получение x3 из eax(al) в CL 
	shr cl,3 ; выравнивание до нулевого разряда
	and bl,cl ;x1 ^ !x2 ^ x3 в BL
	mov cl,000010000b
	and cl,al; получение x4 из eax в CL
	shr cl,4 ; выравнивание до нулевого разряда
	btc cx,0 ;!x4
	and bl,cl ; x1 ^ !x2 ^ x3 ^ !x4
	push bx ; сохранение результата в стек
	
	;x3 x4
	mov bl,000001000b
	and bl,al; получение x3 из eax(al) в BL 
	shr bl,3 ;выравнивание до нулевого разряда	
	mov cl,000010000b
	and cl,al ;получение x4 из eax(al) в CL 
	shr cl,4 ;выравнивание до нулевого разряда		
	and bl,cl ;x3 ^ x4 в BL
	
	
	mov cl, bl ;x3 x4 в CL
	pop bx ; получение предыдущего значения из стека в BL
	or cl,bl ;x1 !x2 x3 !x4 | x3 x4
	pop bx ;получение предыдущего значения из стека в BL
	or cl,bl ;!x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	pop bx ;получение предыдущего значения из стека в BL
	or cl,bl ; x2 !x3 x4 | !x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	pop bx ;получение предыдущего значения из стека в BL
	or cl,bl ; x1 x2 x3 | x2 !x3 x4 | !x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	push eax ;сохранение значения X
	push cx ; сохранение значения F
	
	PUTL F_str
	xor eax,eax
	pop cx ;получение значения F в CX
	add cx, '0' ; делаем из числа символ
	;вывод значения F
	mov dl,cl
	mov ah,02
	int 21h
	; выводим перевод строки
	mov dl,0ah
	mov ah,02
    int 21h 
	sub cx, '0' ; Знач F виз символа в число
	push cx ;сохраняем знач F в стек
	xor ecx,ecx
Take_str2:
	PUTL y
	xor eax,eax
	lea dx, res
    mov ah,0ah
	int 21h
	
	xor eax,eax
	xor si,si
	xor ecx,ecx
	
	mov bx,2
	mov si, offset res+2
StrToInt_2:
	mov cl,[si] ; берем символ из буфера
    cmp cl,0dh  ; проверяем не последний ли он
    jz ternary_operator
    sub cl,'0' ; делаем из символа число 
    mul ebx     ; умножаем на 2
    add eax,ecx  ; прибавляем к остальным
    inc si     ; указатель на следующий символ
    jmp StrToInt_2     ; повторяем
ternary_operator:
	push eax ;сохраняем Y
	call OutBin 
	mov dl,0ah
	mov ah,02
    int 21h ; выводим перевода строки
	pop eax ; получаем Y в EAX
	pop cx; получаем значение F в CX
	pop ebx; получаем X в EBX
	cmp cx, 1 ;Если F == true
	je True
	jmp False
True:
	push ebx ;X
	push eax; Y
	PUTL Z1
	pop eax ;Y
	pop ebx ;X
	; a >> 4 == a / 2^4
	; a << 4 == a * 2^4
	shr ebx,2 ; X / 4 в EBX 
	shl eax,2 ; Y * 4 
	add ebx,eax ; Z = X / 4 + Y * 4 в EBX
	mov eax,ebx ; Z в EAX
	jmp finish
False:
	push eax ; Y
	push ebx ; X
	PUTL Z2
	pop ebx ; X
	pop eax ; Y
	shr ebx,3 ; X/8 в EBX
	
	sub ebx,eax ; Z = X/8 - Y в EBX
	mov eax,ebx ; 
	jmp finish
finish:
	push eax ; сохраняем Z
	PUTL z
	PUTL do
	pop eax ; получаем Z в EAX
	mov ebx, eax ; Z в EBX
	push ebx 
	call OutBin
	mov dl,0ah
	mov ah,02
    int 21h ; выводим перевод строки
	
	pop ebx ; Получаем Z
	; в EBX исходная Z
	;------------------
	mov eax,ebx ; Z в EAX
	btc eax, 3 ;z3 = !z3
	
	mov ecx,80000h; 19 бит
	and ecx,eax; получение z19 из eax(al) в ECX
	shr ecx,17 ;выравнивание до z2 
	or eax,ecx ; z2 |= z19
	
	xor ecx,ecx
	mov ecx, 100000000b ; 8 бит 
	and ecx,eax ; получение z8 из eax(al) в ECX
	shr ecx,1 ;выравнивание до z7
	not ecx
	btc ecx,7	
	and eax,ecx ; z7 &= z8
	
	push eax
	PUTL posle
	pop eax
	call OutBin
	mov dl,0ah
	mov ah,02
    int 21h ; выводим перевод строки
	jmp @@E
@@E:	EXIT	
        EXTRN	PUTSS:  NEAR
        EXTRN	PUTC:   NEAR
	EXTRN   GETCH:  NEAR
	EXTRN   GETS:   NEAR
	EXTRN   SLEN:   NEAR
	EXTRN   UTOA10: NEAR
	EXTRN   OutBin: NEAR
	END	BEGIN
