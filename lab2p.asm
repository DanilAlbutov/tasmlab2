.MODEL SMALL
	.STACK 500h
.386
.data
zap1 db 'Input strings:', '$'
N db 'N1 N2 N3: ', '$'
res db 1000 dup ("$")
weight dw 100

i dw 0
iter dw 0
numbers db 25 dup ("$")
.code
start:
	MOV	AX,	@DATA
	MOV	DS,	AX
	mov cx, 100
	push cx
	mov cx,10
	
	mov dx, offset zap1
	mov ah,09h
	int 21h
	mov bx, offset res ;ссылка на res в BX
	add bx,2
	push bx
	sub bx,2
	
	
;цикл считывания по одному слову	
str_res1:
	;перевод строки на следующую
	mov dx,0ah
	mov ah,02h
	int 21h
	
	;считывание строки в "res"
	mov dx, bx
	mov ah,0ah
	int 21h
	;адрес в текст
	;длина адресса
	;бегать построчно
	mov dl,byte ptr [bx + 2] ;в DL первый символ  строки
	
	cmp dl, "-" ;если встретиться символ "-" то остановить считывание
	je cycle_1_start
	add bx, weight ; добавление длины к смещению (i++)
	cmp cx,0 ;если каунтер 0 то остановить считывание
	je cycle_1_start
	add iter, 1 ;счетчик слов
	sub cx, 1 ; уменьшить каунтер на 1
	jmp str_res1 ;продолжить цикл (в начало цикла)
	
cycle_1_start:
	mov si, offset res + 2 ;ссылка на первый элемент в SI
	mov ax, weight ;в AX длина одного элемента массива
	mul i ; в AX = AX(weight) * i 
	add si, ax ;в SI weight * i
	xor cx,cx
	
xor ax,ax

mov cx, 0



cycleMoveWords:	
	xor si,si
	mov si,offset res + 2
	xor ax,ax
	mov ax, weight
	mul cx
	add si, ax ;в SI = weight * cx (i)
	
	cmp cx,iter ;if (i = 0)
	je exitFromMoveWords ; если (i = 0) , то выйти из цикла
	
	push si
	
	inc cx ; i++
	jne addingNullByteToEndWord	 ; если (i != 0) то добавить нулевой байт в конец
	
	
	
	jmp cycleMoveWords
	
	
	
addingNullByteToEndWord:
	
	pop si
	inc si
	;dec si
	push si
	mov dl,byte ptr [si]
	cmp dl, "$"
	
	jne skip1 ;if !=
	mov byte ptr [si], 0	
	jmp cycleMoveWords
	
	skip1:
	jmp addingNullByteToEndWord



exitFromMoveWords:

mov cx,0

printWords:
	xor si,si
	
	
	
	mov si,offset res + 2
	xor ax,ax
	mov ax, weight
	mul cx
	add si, ax ;в SI = weight * cx (i)
	
	xor ax,ax
	xor dx,dx
	
	;mov dl, byte ptr [si]
	mov dx, si
	mov ah,09h
	int 21h
	
	xor ax,ax
	xor dx,dx

	mov dx,0ah
	mov ah,02h
	int 21h
	
	cmp cx,iter ;if (i = 0)
	je exit
	
	inc cx ; i++
	jmp printWords
	

exit:
	mov ah,4ch
	int 21h
end

; необходима функция , которая будет посимвольно 
	; пробегать по элементу массива и добавит 0 в конец 
	; элемента. arr[сслка на элемент + 1]