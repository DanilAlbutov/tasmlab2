;***************************************************************************************************
; MLAB1.ASM - �祡�� �ਬ�� ��� �믮������ 
; ������୮� ࠡ��� N1 �� ��設��-�ਥ��஢������ �ணࠬ��஢����
; 10.09.02: ������ �.�.
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       �ᯮ������� ������樨 ����⠭� � ����ᮢ
        INCLUDE MLAB1.INC	
        INCLUDE MLAB1.MAC

; ������樨 ������
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"������� �.�.: ",0FFh
MINIS	DB	"������������ ����������� ���������� ���������",0
ULSTU	DB	"����������� ��������������� ����������� �����������",0
DEPT	DB	"��䥤� ���᫨⥫쭮� �孨��",0
MOP	DB	"��設��-�ਥ��஢����� �ணࠬ��஢����",0
LABR	DB	"������ୠ� ࠡ�� N 1 ��ਠ�� 1",0
REQ1    DB      "���������(-),�᪮���(+),���(ESC),������ୠ�(l) ? ",0FFh
TACTS   DB	"�६� ࠡ��� � ⠪��: ",0FFh
EMPTYS	DB	0
BUFLEN = 70
BUF	DB	BUFLEN
LENS	DB	?
SNAME	DB	BUFLEN DUP (0)
PAUSE	DW	0, 0 ; ����襥 � ���襥 ᫮�� ����প� �� �뢮�� ��ப�
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; ��ப� �뢮�� �᫠ ⠪⮢
                                          ; ����� ��� ࠧ����⥫��� "`"
										  

F db "F = x1x2x3 | x2!x3x4 | !x1!x2  | x1!x2x3!x4 | x3x4",0
x db "������ X",0
y db "������ Y",0
F_str db "F = ",0FFh
Z1 db "Z = X/4 + 4 * Y", 0
Z2 db "Z = X/8 - Y", 0
z db "�८�ࠧ������: z3 = !z3; z2 |= z19; z7 &= z8",0
do db "�� �८�ࠧ������",0
posle db "��᫥ �८�ࠧ������",0
res db 21

        .CODE
; ����� ���������� ��ப� LINE �� ����樨 POS ᮤ�ন�� CNT ��ꥪ⮢,
; ����㥬�� ���ᮬ ADR �� �ਭ� ���� �뢮�� WFLD
BEGIN	LABEL	NEAR
	; ���樠������ ᥣ���⭮�� ॣ����
	MOV	AX,	@DATA
	MOV	DS,	AX
	; ���樠������ ����প�
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; ����� �����
	; ���� �����
	LEA	DX,	BUF
	CALL	GETS
@@L:	; 横���᪨� ����� ����७�� �뢮�� ���⠢��
	; �뢮� ���⠢��
	; ��������� ������� ������ �����
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; ࠧ����⥫쭠� ���
	PUTL	EMPTYS
	PUTLSC	MINIS	; ��ࢠ� 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  �  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   ��᫥���騥 
	PUTL	EMPTYS
	PUTLSC	MOP	;    ��ப�  
	PUTL	EMPTYS
	PUTLSC	LABR	;     ���⠢��
	PUTL	EMPTYS
	; �ਢ���⢨�
	PUTLSC	SNAME   ; ��� ��㤥��
	PUTL	EMPTYS
	; ࠧ����⥫쭠� ���
	PUTL	SLINE
	; ��������� ������� ��������� ����� 
	DURAT    	; ������ ����祭���� �६���
	; �८�ࠧ������ �᫠ ⨪�� � ��ப� � �뢮�
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; �뢮� �᫠ ⠪⮢
	; ��ࠡ�⪠ �������
get:	
	PUTL	REQ1 ;�뢮� ⥪��
	CALL	GETCH ;����饭�� ᨬ���� � AL � �ନ����
	CMP	AL,	'-'    ; 㤫������ ����প�?
	JNE	CMINUS
	INC	PAUSE+2        ; �������� 65536 ���
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; 㪮�稢��� ����প�?
	JNE	CEXIT
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; 㡠���� 65536 ���
BACK:	JMP	@@L
CEXIT:	CMP	AL,	CHESC
	jne input
	JE	@@E
	TEST	AL,	AL
	JNE	BACK
	CALL	GETCH
	JMP	@@L
	; ��室 �� �ணࠬ��
	; ��砫� ����-------------------------------------------------------------------------------
	
	
input:
	CMP AL,'l' ;�᫨ ���짮��⥫� ����� e 
	jne get
	push ax
	
	mov dl,0ah
	mov ah,02
    int 21h ; �뢮��� ��ॢ��� ��ப�
	
	pop ax
	mov dl,al
	mov ah,02
	int 21h
	
	mov dl,0ah
	mov ah,02
    int 21h ; �뢮��� ��ॢ��� ��ப�
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
	mov cl,[si] ; ��६ ᨬ��� �� ����
    cmp cl,0dh  ; �஢��塞 �� ��᫥���� �� ��
    jz count_F
    sub cl,'0' ; ������ �� ᨬ���� �᫮ 
    mul ebx     ; 㬭����� �� 2
    add eax,ecx  ; �ਡ���塞 � ��⠫��
    inc si     ; 㪠��⥫� �� ᫥���騩 ᨬ���
    jmp StrToInt_1     ; �����塞	
count_F:
	push eax
	call OutBin
	mov dl,0ah
	mov ah,02
    int 21h ; �뢮��� ��ॢ��� ��ப�
	;x1 x2 x3 | x2 !x3 x4 | !x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	PUTL F
	xor eax,eax
	pop eax ; ����祭�� X � eax
	xor bx,bx ; ���㫥���
	xor ecx,ecx ; ���㫥���
	
	;x1 x2 x3
	mov bl,000000010b 
	and bl,al ;����祭�� x1 �� eax(al) � BL 
	shr bl,1
	mov cl,000000100b 
	and cl,al ;����祭�� x2 �� eax � CL
	shr cl, 2 ;ᤢ����� ��ࠢ� �� 2 ��� ��ࠢ������� � x2
	and bl,cl ; x1 ^ x2 � BL
	mov cl,000001000b 
	and cl,al ; ����祭�� x3 �� eax � CL
	shr cl,3 ;��ࠢ� �� 3 ��� ��ࠢ������� � x1 ^ x2
	and bl,cl; x1 ^ x2 ^ x3
	push bx ; ��࠭塞 � �⥪ १����
	
	;x2 !x3 x4
	mov bl,000000100b 
	and bl,al ; ����祭�� x2 �� eax � BL
	shr bl,2 ; ��஢���� x2 �� 0��� ࠧ�鸞
	mov cl,000001000b
	and cl,al ; ����祭�� x3 �� eax � CL
	shr cl,3 ;��஢���� x3 �� 0��� ࠧ�鸞
	btc cx,0 ;������� (!x3)
	and bl,cl ; x1 ^ !x3 � BL
	mov cl,000010000b
	and cl,al ; ����祭�� x4 �� eax � CL
	shr cl,4 ; ��ࠢ������� x4 �� 0��� ࠧ�鸞
	and bl,cl ;x1 ^ !x3 ^ x4
	push bx ; ��࠭塞 � �⥪ १����
	
	;!x1 !x2
	mov bl,000000010b 
	and bl,al ;����祭�� x1 �� eax(al) � BL 
	shr bl,1
	btc bx,0 ; ������஢��� �㫥��� ��� BX (!x1)
	mov cl,000000100b 
	and cl,al ;����祭�� x2 �� eax � CL
	shr cl, 2 ;ᤢ����� ��ࠢ� �� 2 ��� ��ࠢ������� � x1
	btc cx,0 ; !x2
	and bl,cl ; !x1 ^ !x2 � BL
	push bx ; ��࠭塞 १���� � �⥪
	
	;x1 !x2 x3 !x4
	mov bl,000000010b
	and bl,al ; ����祭�� x1 �� eax(al) � BL 
	shr bl,1
	mov cl,000000100b
	and cl,al; ����祭�� x2 �� eax � CL
	shr cl,2
	btc cx,0 ;!x2
	and bl,cl ;x1 ^ !x2	 � BL
	mov cl,000001000b
	and cl,al; ����祭�� x3 �� eax(al) � CL 
	shr cl,3 ; ��ࠢ������� �� �㫥���� ࠧ�鸞
	and bl,cl ;x1 ^ !x2 ^ x3 � BL
	mov cl,000010000b
	and cl,al; ����祭�� x4 �� eax � CL
	shr cl,4 ; ��ࠢ������� �� �㫥���� ࠧ�鸞
	btc cx,0 ;!x4
	and bl,cl ; x1 ^ !x2 ^ x3 ^ !x4
	push bx ; ��࠭���� १���� � �⥪
	
	;x3 x4
	mov bl,000001000b
	and bl,al; ����祭�� x3 �� eax(al) � BL 
	shr bl,3 ;��ࠢ������� �� �㫥���� ࠧ�鸞	
	mov cl,000010000b
	and cl,al ;����祭�� x4 �� eax(al) � CL 
	shr cl,4 ;��ࠢ������� �� �㫥���� ࠧ�鸞		
	and bl,cl ;x3 ^ x4 � BL
	
	
	mov cl, bl ;x3 x4 � CL
	pop bx ; ����祭�� �।��饣� ���祭�� �� �⥪� � BL
	or cl,bl ;x1 !x2 x3 !x4 | x3 x4
	pop bx ;����祭�� �।��饣� ���祭�� �� �⥪� � BL
	or cl,bl ;!x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	pop bx ;����祭�� �।��饣� ���祭�� �� �⥪� � BL
	or cl,bl ; x2 !x3 x4 | !x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	pop bx ;����祭�� �।��饣� ���祭�� �� �⥪� � BL
	or cl,bl ; x1 x2 x3 | x2 !x3 x4 | !x1 !x2  | x1 !x2 x3 !x4 | x3 x4
	push eax ;��࠭���� ���祭�� X
	push cx ; ��࠭���� ���祭�� F
	
	PUTL F_str
	xor eax,eax
	pop cx ;����祭�� ���祭�� F � CX
	add cx, '0' ; ������ �� �᫠ ᨬ���
	;�뢮� ���祭�� F
	mov dl,cl
	mov ah,02
	int 21h
	; �뢮��� ��ॢ�� ��ப�
	mov dl,0ah
	mov ah,02
    int 21h 
	sub cx, '0' ; ���� F ��� ᨬ���� � �᫮
	push cx ;��࠭塞 ���� F � �⥪
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
	mov cl,[si] ; ��६ ᨬ��� �� ����
    cmp cl,0dh  ; �஢��塞 �� ��᫥���� �� ��
    jz ternary_operator
    sub cl,'0' ; ������ �� ᨬ���� �᫮ 
    mul ebx     ; 㬭����� �� 2
    add eax,ecx  ; �ਡ���塞 � ��⠫��
    inc si     ; 㪠��⥫� �� ᫥���騩 ᨬ���
    jmp StrToInt_2     ; �����塞
ternary_operator:
	push eax ;��࠭塞 Y
	call OutBin 
	mov dl,0ah
	mov ah,02
    int 21h ; �뢮��� ��ॢ��� ��ப�
	pop eax ; ����砥� Y � EAX
	pop cx; ����砥� ���祭�� F � CX
	pop ebx; ����砥� X � EBX
	cmp cx, 1 ;�᫨ F == true
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
	shr ebx,2 ; X / 4 � EBX 
	shl eax,2 ; Y * 4 
	add ebx,eax ; Z = X / 4 + Y * 4 � EBX
	mov eax,ebx ; Z � EAX
	jmp finish
False:
	push eax ; Y
	push ebx ; X
	PUTL Z2
	pop ebx ; X
	pop eax ; Y
	shr ebx,3 ; X/8 � EBX
	
	sub ebx,eax ; Z = X/8 - Y � EBX
	mov eax,ebx ; 
	jmp finish
finish:
	push eax ; ��࠭塞 Z
	PUTL z
	PUTL do
	pop eax ; ����砥� Z � EAX
	mov ebx, eax ; Z � EBX
	push ebx 
	call OutBin
	mov dl,0ah
	mov ah,02
    int 21h ; �뢮��� ��ॢ�� ��ப�
	
	pop ebx ; ����砥� Z
	; � EBX ��室��� Z
	;------------------
	mov eax,ebx ; Z � EAX
	btc eax, 3 ;z3 = !z3
	
	mov ecx,80000h; 19 ���
	and ecx,eax; ����祭�� z19 �� eax(al) � ECX
	shr ecx,17 ;��ࠢ������� �� z2 
	or eax,ecx ; z2 |= z19
	
	xor ecx,ecx
	mov ecx, 100000000b ; 8 ��� 
	and ecx,eax ; ����祭�� z8 �� eax(al) � ECX
	shr ecx,1 ;��ࠢ������� �� z7
	not ecx
	btc ecx,7	
	and eax,ecx ; z7 &= z8
	
	push eax
	PUTL posle
	pop eax
	call OutBin
	mov dl,0ah
	mov ah,02
    int 21h ; �뢮��� ��ॢ�� ��ப�
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
