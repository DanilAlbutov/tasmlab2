.model small
.STACK 200h

.data
string db 40 Dup ('$') ;исходная строка
mas_ind	db	20 dup (0) ; массив индексов первых букв слов ASCI (10рично)
mas_num	db	20 dup (0) ; массив порядковых номеров слов с 0
mas_shift	db	20 dup (0) ; массив смещений слов относительно начала строки

sorted_index db 20 dup (0); массив отсортированных индексов
 
mas_ind_i dw 0
mas_num_i dw 0
mas_shift_i dw 0
k dw 0
temp db 0
shift_count dw 0
shift_ind dw 0
index_tmp dw 0
index_ind dw 0
word_count dw 0
word_number_ind dw 0
loop_count dw 0
tmp db 0
i dw 0
j dw 0
R dd 0


.code
start1:
mov ax,@data
mov ds,ax

mov cx,3 ;счетчик вводимых строк
push cx
getStrToArr:
	mov si,cx
	mov ah,0Ah ;Ввод строки
	lea dx,string[si]
	int 21h ; ввод строки
	mov dl,0ah
	mov ah,2
	int 21h ; курсор - на следующую строку
	loop getStrToArr
	
pop cx
mov si,cx
addEndStr:
	xor bx,bx
	mov bl,[string+1]
	mov [string+2+bx],'$' ; вставляем последним символом
	dec cx
	cmp cx,0
	jne addEndStr
mov ax, shift_ind
add ax, 2
mov shift_ind, ax

mov ax, word_number_ind
add ax, 1
mov word_number_ind, ax

xor dx,dx
xor cx,cx

xor ax, ax
xor bx, bx
mov ax, 2
mov bx,offset string ;указательна первый элемент строки
add bx,ax 
mov al, byte ptr[bx] ; значение первого символа в AL
mov si, 0

mov ax,4c00h ;стандартный выход
int 21h
END start1