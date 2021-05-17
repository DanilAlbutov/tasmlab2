.MODEL SMALL
	.STACK 500h
.386
.data
zap1 db 'Input strings:', '$'
N db 'N1 N2 N3: ', '$'
res db 2400 dup ("$")
weight dw 100
equ_flag db 0
space_flag_1 dw 0
space_flag_2 dw 0
i dw 0
iter dw 0
numbers db 25 dup ("$")
.code
start:
	MOV	AX,	@DATA
	MOV	DS,	AX
	mov cx, 100
	push cx
	mov cx,24
	
	mov dx, offset zap1
	mov ah,09h
	int 21h
	mov bx, offset res ;ссылка на res в BX
	
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
	
	mov dl,byte ptr [bx + 2] ;в DL ссылка на первый элемент строки
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
	
	
	

exit:
	mov ah,4ch
	int 21h
end