LAB1:	;мой код
	XOR EAX, EAX
	XOR EBX, EBX	
	PUTL	EMPTYS
	PUTL	REQX
	XOR EAX, EAX
	XOR EBX, EBX	
	
	; Подсчет значения F при помощи таблицы истинности
	call BinInput
	MOV X, EBX
	PUTL Ftext
	mov eax, x
	AND EAX, 1110b
	XOR EBX, EBX
	MOV EBX, EAX
	SHR EAX, 1
	XOR EBX, EBX
	CMP EAX, 0 ;000b
	JE l1
	CMP EAX, 3	;011b
	JE l1
	CMP EAX, 4	;100b
	JE l1
	JMP l2
		
	l2: ; F = 1 (X*2 − X/8)
	PUTL Ftrue
	XOR EAX, EAX; 
	XOR EBX, EBX; 
	MOV EAX, X
	MOV EBX, X
	SHL EAX, 1
	SHR EBX, 3
	SUB EAX, EBX; Z = EAX
	JMP l3
	
	l1: ; F = 0 (Y/2 + X*4)
	XOR EAX, EAX; 
	PUTL Ffalse
	PUTL	REQY
	XOR EBX, EBX
	call BinInput
	SHR EBX, 1
	MOV EAX, X
	SHL EAX, 2
	ADD EAX, EBX; Z = EAX
	
	l3:
	MOV Z, EAX
	XOR EAX, EAX; 
	XOR EBX, EBX; 
	
	PUTL Ztext
	MOV EBX, Z
	call BinOutput	
	PUTL	EMPTYS	
	
	;z5 = !z2
	XOR EAX, EAX; 
	XOR EBX, EBX;
	MOV eax, Z
	MOV ebx, Z
	AND ebx, 100b
	SHR ebx, 3
	JC z1
	BTS EAX, 5
	JMP z2
	z1: 
	BTR EAX, 5
	z2:
	MOV Z, EAX
	
	;z8 |= z9
	XOR EAX, EAX; 
	XOR EBX, EBX;
	MOV eax, Z 
	MOV ebx, Z
	AND ebx, 1100000000b
	SHR ebx, 9
	JNC @z1
	JMP @z3
	@z1: 
	SHR ebx, 1
	JNC @z2
	JMP @z3
	@z2: 
	BTR EAX, 8
	JMP @z4
	@z3:
	BTS EAX, 8
	@z4:
	MOV Z, EAX
	
	;z17 &= z0
	XOR EAX, EAX; 
	XOR EBX, EBX;
	MOV eax, Z
	MOV ebx, Z
	AND ebx, 100000000000000001b
	SHR ebx, 1
	JC @@z1
	JMP @@z3
	@@z1:
	SHR ebx, 17
	JC @@z2
	JMP @@z3
	@@z2:
	BTS eax, 17
	JMP @@z4
	@@z3:
	BTR eax, 17
	@@z4: 
	MOV Z, EAX
	
	
	XOR EAX, EAX; 
	XOR EBX, EBX;
	
	PUTL BitChangeText
	MOV EBX, Z
	call BinOutput
	
	JMP	@@E
	;мой код end
	
	JMP p2
	BinInput proc	;Процедура ввода двоичного числа с клавиатуры
		MOV AH, 1
	FOR1:
		INT 21h
		CMP AL, 0DH
		JE END_FOR1
		SUB AL, 48
		SHL EBX, 1
		OR BL, AL
		JMP FOR1
	END_FOR1:
	;MOV X, EBX
	ret
	BinInput endp
	p2:
	
	JMP p3
	BinOutput proc	;Процедура вывода двоичного числа в консоль
		MOV CX, 20
		MOV AH, 2
	FOR2:
		SHR EBX, 1
		JC OUT_ONE
		MOV DL, '0'
		PUSH EDX
		JMP LAST_OF_LOOP		
	OUT_ONE:
		MOV DL, '1'
		PUSH EDX
	LAST_OF_LOOP:
		LOOP FOR2
		MOV CX, 20
	FOR3:
		POP EDX
		int 21h
		LOOP FOR3
	ret
	BinOutput endp
	p3:
