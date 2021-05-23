.MODEL SMALL
.CODE
.386

OutInt proc
        
;; если число знаковое, то необходимо расскоментировать следующие строки
;; Проверяем число на знак.
;   test    ax, ax
;   jns     oi1
;
;; Если оно отрицательное, выведем минус и оставим его модуль.
;   mov  cx, ax
;   mov     ah, 02h
;   mov     dl, '-'
;   int     21h
;   mov  ax, cx
;   neg     ax
;; Количество цифр будем держать в CX.
;oi1:  
    xor     ecx, ecx
    mov     bx, 10 ; основание сс. 10 для десятеричной и т.п.
oi2:
    xor     edx,edx
    div     ebx
; Делим число на основание сс. В остатке получается последняя цифра.
; Сразу выводить её нельзя, поэтому сохраним её в стэке.
    push    edx
    inc     ecx
; А с частным повторяем то же самое, отделяя от него очередную
; цифру справа, пока не останется ноль, что значит, что дальше
; слева только нули.
    test    eax, eax
    jnz     oi2
; Теперь приступим к выводу.
	mov eax,ecx
	sub ax, di
	mov di,ax
    mov     ah, 02h
oi3:
    pop     edx
	cmp di, 0
	je oi4
	mov     ah, 02h
	jmp oi5
oi4:
	mov ebx,edx
	mov dl, "."
	mov ah,02h
	int 21h
	sub di,1
	mov edx,ebx
	jmp oi5

; Извлекаем очередную цифру, переводим её в символ и выводим.
;; раскоментировать если основание сс > 10, т.е. для вывода требуются буквы
;   cmp     dl,9
;   jbe     oi4
;   add     dl,7
;oi4:
oi5:
    add     dl, '0'
	mov     ah, 02h
    int     21h
	sub edi,1
; Повторим ровно столько раз, сколько цифр насчитали.
    loop    oi3
    
    ret

OutInt endp


PUBLIC	OutInt

        END