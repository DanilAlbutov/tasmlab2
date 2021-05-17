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

mov si,1
mov ah,01h ;Ввод строки
lea dx,string[si]
int 21h ; ввод строки

mov dl,0ah
mov ah,2
int 21h ; курсор - на следующую строку
    
xor bx,bx
mov bl,[string+1]
mov [string+2+bx],'$' ; вставляем последним символом

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
mov mas_ind[si], al ;в массив индексо заносиим код первого 
mov sorted_index[si], al 
mov bx, 1
mov mas_ind_i, bx
mov word_count, bx
mov shift_count, bx
mov mas_num_i, bx ;счетчики
mov mas_shift_i, bx
mov bx, 0
mov mas_shift[si], bl
mov mas_num[si], bl


@cycle:
xor ax, ax
xor bx, bx
mov ax, 2
mov bx,offset string ;ссылка на нач чтроки

add bx,ax
add bx, shift_count
cmp byte ptr[bx], '$'
je string_end
cmp byte ptr[bx],' '
je probel
jmp p2

probel:
call mas_shift_proc
call mas_ind_proc
call mas_num_proc
jmp p2

p2:
add cx, 1
mov shift_count, cx
jmp @cycle

string_end:
	call Sort2
	mov	si,0

mov dl,0ah
mov ah,2
int 21h 
xor ax, ax

dec word_count
mov si, 0
@while:
xor bx, bx
mov di, 0
	@@while:	
	mov bl,sorted_index[si] 
	cmp bl, mas_ind[di]
	je finded
	inc di
	jmp @@while
finded:
	xor bx, bx
	mov	al, mas_ind[di] :
	call OutInt
	xor ax, ax
	mov dl, ' '
	mov ah,02h
    int 21h
	xor ax, ax
	mov	al, mas_num[di]
	call OutInt
	xor ax, ax
	xor ax, ax
	mov dl, ' '
	mov ah,02h
    int 21h
	mov bx, offset string
	add bx, 2
	add bl, mas_shift[di]
	@@@while:
		xor ax, ax
		mov dl, byte ptr[bx]
		cmp byte ptr[bx], ' '
		je @@@while_end
		cmp byte ptr[bx], '$'
		je @@@while_end
		mov ah,02h
		int 21h
		inc bx
	jmp @@@while
	@@@while_end:
	xor ax, ax
	mov dl,0ah
	mov ah,2
	int 21h 
	xor ax, ax

inc si
cmp si, word_count
jbe @while

mov ah, 4ch 
int 21h

Sort2 proc
mov bp, word_count ;процедупа сортировки массива индексов по алфавиту
C:
    mov cx, word_count
    dec cx
    lea bx, sorted_index ;ссылк на ажрес начало массива
        xor si, si                
B:
    mov al, [bx + si]
    mov di, si
    A:
        add di, 1
        mov dl, [bx + di]
 
        cmp al, dl
        jl davaytuda
            mov [bx+di], al
            mov [bx+si], dl
    davaytuda:
 
     mov dx, word_count
     shl dx, 1
     cmp di, dx
     jnl  A
     add si, 1
     loop B
         xor si, si
         xor di, di
         dec bp
         cmp bp,0
         jne c
ret
Sort2 endp

mas_shift_proc proc ;функция заполнения массива смещений слов относительно начала строки
mov cx, shift_count
add cx, 1
xor bx, bx
xor ax, ax

xor si, si
mov si, mas_shift_i
mov mas_shift[si], cl
inc si
mov mas_shift_i, si
ret
mas_shift_proc endp

mas_ind_proc proc ;заполнение массива индексов
xor ax, ax
xor bx, bx
mov ax, 2
mov bx,offset string
add bx,ax
add bx, shift_count
xor ax, ax
inc bx
mov al, byte ptr[bx]
mov index_tmp, ax
xor si, si
mov si, mas_ind_i
mov mas_ind[si], al
mov sorted_index[si], al
inc si
mov mas_ind_i, si
ret
mas_ind_proc endp

mas_num_proc proc ;находения порядкового номера слова и занесение в массив (с нуля)
xor dx, dx
mov bx, word_count
mov dx,bx
inc bx
mov word_count, bx
xor si, si
mov si, mas_num_i
mov mas_num[si], dl
inc si
mov mas_num_i, si
ret
mas_num_proc endp

OutInt proc      ;вывод значений в 10ричной системе
    xor     cx, cx
    mov     bx, 10 ; основание сс. 10 для десятеричной и т.п.
oi2:
    xor     dx,dx
    div     bx
    push    dx
    inc     cx
    test    ax, ax
    jnz     oi2
    mov     ah, 02h
oi3:
    pop     dx
    add     dl, '0'
    int     21h
    loop    oi3   
	mov dl, ' '
	mov ah,02h
    int 21h
    ret	
    ret
OutInt endp
END start1