.MODEL SMALL
	.STACK 500h
.386
.data
zap1 db 'Input strings:', '$'

res db 1000 dup ("$")
adress db 1000 dup ("$")
weight dw 100
letters db  '0123456789ABCDEF$' ;Числа в 16-ричной системе
i dw 0
iter dw 0
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
	je next1
	add bx, weight ; добавление длины к смещению (i++)
	cmp cx,0 ;если каунтер 0 то остановить считывание
	je next1
	add iter, 1 ;счетчик слов
	sub cx, 1 ; уменьшить каунтер на 1
	jmp str_res1 ;продолжить цикл (в начало цикла)
	
next1:
	
	
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
	;mov byte ptr [si + 5], '0'
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
	
	mov byte ptr [si - 1], '0'	
	jmp cycleMoveWords
	
	skip1:
	jmp addingNullByteToEndWord



exitFromMoveWords:

mov cx,0

	mov dx,0ah
	mov ah,02h
	int 21h

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
	je exitFromPrint
	
	inc cx ; i++
	jmp printWords
	
exitFromPrint:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;бааааги снизу

	mov cx, 0
cyclePushAdress:	
	xor si,si
	mov si,offset res + 2
	xor ax,ax
	mov ax, weight
	mul cx
	add si, ax ;в SI = weight * cx (i)
	;add si, 3030h
	xor ax,ax
	mov ax,si
	;add al, '0'
	;add ah, '0'
	
	push ax
	
	cmp cx,iter ;if (i = 0)
	je exitFromcyclePushAdress ; если (i = 0) , то выйти из цикла
	
	
	inc cx ; i++	
	jmp cyclePushAdress
	
exitFromcyclePushAdress:
	
	mov cx, iter
cyclePopAdress:	
	xor si,si
	mov si,offset adress + 2
	xor ax,ax
	mov ax, weight
	mul cx
	add si, ax ;в SI = weight * cx (i)
	
	pop dx 
	
	;mov byte ptr [si], dl
	mov word ptr [si], dx
	
	cmp cx,0 ;if (i = 0)
	je exitFromcyclePopAdress ; если (i = 0) , то выйти из цикла
	
	
	dec cx ; i--	
	jmp cyclePopAdress
	
exitFromcyclePopAdress:	

mov cx,0
finalPrint:
	;обнуление
	xor si,si
	xor di,di
	xor ax,ax
	xor dx,dx
	;индексация массива адресов
	mov si,offset adress + 2 ; ссылка на первый символ массива адресов
	xor ax,ax 
	mov ax, weight
	mul cx
	add si, ax ;в SI = weight * cx (i)
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov dl, byte ptr [si]
	mov dh, byte ptr [si + 1]
	;shr dx, 8
	xor ax,ax
    mov al,dl
    push    ax
    shr al,4    ; выделить старшие четыре бита
    xor bx,bx
    mov bl,al
    mov al,letters[bx]
    int 29h ; вывести на экран
 
    pop ax
    and al,0Fh  ; выделить младшие четыре бита
    xor bx,bx
    mov bl,al
    mov al,letters[bx]
    int 29h ; вывести на экран
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	xor ax,ax
    mov al,dh
    push    ax
    shr al,4    ; выделить старшие четыре бита
    xor bx,bx
    mov bl,al
    mov al,letters[bx]
    int 29h ; вывести на экран
 
    pop ax
    and al,0Fh  ; выделить младшие четыре бита
    xor bx,bx
    mov bl,al
    mov al,letters[bx]
    int 29h ; вывести на экран
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;вывод адреса
	;mov dx, si
	;mov ah,09h
	;int 21h
	
	xor dx,dx
	xor ax,ax
	;вывод двоеточия
	mov ah, 02h
	mov dl, 3Ah
	int 21h
	
	xor dx,dx
	xor ax,ax
	;индексация массива строк
	mov si,offset res + 2
	xor ax,ax
	mov ax, weight
	mul cx	
	add si, ax ;в DI = weight * cx (i)
	
	;вывод строки
	mov dx, si
	mov ah,09h
	int 21h
	
	xor dx,dx
	xor ax,ax
	;вывод переноса строки
	mov dx,0ah
	mov ah,02h
	int 21h	
	
	
	
	
	
	cmp cx, iter
	je exit
	inc cx
	
	jmp finalPrint
		
exit:
	mov ah,4ch
	int 21h
end

; необходима функция , которая будет посимвольно 
	; пробегать по элементу массива и добавит 0 в конец 
	; элемента. arr[сслка на элемент + 1]