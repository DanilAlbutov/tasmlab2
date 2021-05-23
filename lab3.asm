.MODEL SMALL
	.STACK 500h
.386

;шаблон структуры
number struc
celaya db 15 dup ("$")
drobnaya db 3 dup ("$")
number ends

.data
zapros1 db "Vvedite do 20 chisel:","$"
zapros2 db "Vvedite I:","$"
zapros3 db "Vvedite J:","$"
primer db "Primer: (A[I] + A[J] * A[J + 1])", "$"
error_r db "Previshenie maximalnogo znachenia","$"
error_i db "Nepravilnii index","$"
mass_numbers number 20 dup (<>)
temp db 20 dup ("$")
iter dw 0
i dw 0
j dw 0
k dw 0
res_poryadok1 dw 0
res_mantissa1 dw 0
res_poryadok2 dw 0
res_mantissa2 dw 0
res_poryadok3 dw 0
res_mantissa3 dw 0
res_poryadok dd 0
res_mantissa dw 0
res_znak dw 0
flag_znak1 dw 0
flag_znak2 dw 0
.code
start:
	MOV	AX,	@DATA
	MOV	DS,	AX
	mov di, offset mass_numbers
	mov bx, type number
	;вывод текста на экран
	mov dx, offset zapros1
	mov ah,09h
	int 21h
	;перевод строки на следующую
	mov dx, 0ah
	mov ah,02h
	int 21h
	
	xor cx,cx
;считывание строки и занесение в temp для последующей обработки
loop_numbers:
	cmp iter, 20
	je next_step
	
	;считывание строки
	mov dx,offset temp
	mov ah,0ah
	int 21h
	
	;перевод строки на следующую
	mov dx,0ah
	mov ah,02h
	int 21h
	
	mov si, offset temp +2 ;в SI ссылка на массив temp
	add iter,1 ;i++ , счетчик чисел
	
loop_temp:	
	mov dl, [si] ;в dl ссылка на первый символ temp
	
	cmp dl, "-" ; если равно "-" то остановить ввод
	je next_step_0
	
	
	
	cmp dl, 0Dh ;проверка на enter; то есть когда встречаеться конец строки следующая итерация
	je next_iter
	
	cmp dl, "."
	je to_mantissa_start ;начать считывать дробную часть
	
	mov [di].celaya, dl
	inc si ;следующий символ в temp
	inc di ;следующее символ в numbers
	jmp loop_temp
	
;переход к след сруктуре (nambers[i++])




next_iter:
	inc cx ; в CX i
	mov di,offset mass_numbers ;ссылка на массив структур
	mov ax,bx	; в AX размер одной структуры
	mul cx ; размер * cx (i)
	add di,ax ; i++
	jmp loop_numbers
to_mantissa_start:
	;i++
	mov di,offset mass_numbers
	mov ax,bx
	mul cx	
	add di,ax
	
	inc si ;следущий символ после точки
to_mantissa:
	mov dl, [si] ; в DL первый символ дробной части
	mov [di].drobnaya, dl ;numbers[di] + [адрес "drobnaya"] = DL
	inc si ;следущий символ в TEMP
	inc di ;Следующая цифра в number.drobnaya
	cmp dl, 0Dh ;если DL = конец строки
	je next_iter ; то след итерация
	jmp to_mantissa ; продолжить считывание дробной части
;на этом шаге закончилось заполнение массива структур
next_step_0:
	sub iter,2
next_step:
	xor bx,bx
	
	;перевод строки на следующую строку
	mov dx,0ah
	mov ah,02h
	int 21h
	
	;вывод запроса на ввод I
	mov dx, offset zapros2
	mov ah,09h
	int 21h
	
	;перевод строки на следующую строку
	mov dx, 0ah
	mov ah,02h
	int 21h
	
	;считать I в AL
	mov ah,01h
	int 21h
	
	mov bl,al ;Теперь в BL I 
	sub bl,1 ; I - 1
	sub bl, "0" ; char to int
	mov i, bx ; сохраняем в переменную
	;;;;;;;;;;;;;;;;;;;;
	;то же самое с J
	mov dx, 0ah
	mov ah,02h
	int 21h
	
	mov dx, offset zapros3
	mov ah,09h
	int 21h
	
	mov dx, 0ah
	mov ah,02h
	int 21h
	
	mov ah,01h
	int 21h
	
	mov bl,al
	sub bl,1
	sub bl, "0"
	mov j,bx
	;;;;;;;;;;;;;;;;;;;;;;
	
	;перевод на след строку
	mov dx, 0ah
	mov ah,02h
	int 21h
	
	;вывод своего варианта
	mov dx, offset primer
	mov ah,09h
	int 21h
	
	;перевод на след строку
	mov dx,0ah
	mov ah,02h
	int 21h
	
podschet:
	mov ax, i ; в AX I
	cmp ax, iter  ;если I > number.count
	;ja error_indx ;вывести ошибку
	
	mov ax, j 
	cmp ax, iter
	;ja error_indx ; вывести ошибку если J > num.count
	;;start copy
	mov ax,type number ;получение размера одной структуры в AX
	mov di,offset mass_numbers ; ссылка на первый элемент массива структур
	mov bx, i ;в BX I
	mul bx ;AX = [размер одной структуры * I]
	add di,ax ;в DI индекс текущего элемента массива структур (индекс массива)
	mov iter,0
	
	
to_int_poryadok_1:
	
	cmp [di].celaya, "$" ;если в целой части встретиться $ 
	je to_int_mantissa_start_1 ; переход к получению численного занчения дробной части
	
	;вывод символов чисел целой части
	mov dl, [di].celaya ; в DL ссылка на первый символ целой части
	mov ah, 02h
	int 21h ;вывод цифры
	
	mov bl,[di].celaya ;в BL первая цифра целой части
	sub bl,"0" ; char to int
	;получение из символов значения
	mov ax,10 ;в AX 10
	mul res_poryadok1 ;ax = ax * res_poryadok1    0  20 230 
	add al, bl ; al = al(10 * res_poryadok1) + цифра  0 + 2  20 + 3 230 + 5
	mov res_poryadok1,ax   ;23
	inc di
	
	
	add iter,1
	jmp to_int_poryadok_1
to_int_mantissa_start_1:
	xor eax,eax
	
	sub di,iter ;
	mov iter, 0
	;вывод точки
	mov dl,"." 
	mov ah,02h
	int 21h
to_int_mantissa_1:
	
	cmp [di].drobnaya, 0Dh ; если конец строки
	je plus_two_start  ; закончить вывод и перейти к о второму числу
	;выести первое число дробной части
	mov dl, [di].drobnaya ;в DL перый символ дробной части
	mov ah, 02h
	int 21h
	
	mov bl,[di].drobnaya ; в BL первый симол числа дробной части
	;получение из символов значения
	sub bl,"0" ; char to int
	mov ax,10
	mul res_mantissa1	
	add al, bl
	mov res_mantissa1,ax
	inc di
	add iter,1
	jmp to_int_mantissa_1
	;теперь в res_poryadok1 = целая часть 1 числа
	;в res_mantissa1 = дробная часть 1 числа
plus_two_start:
;;start copy
	push iter ; сохраняем длину дробной части
	sub di,iter ;получаем адрес целой части 2ого числа
	;переход на след строку
	mov dx, 0ah
	mov ah, 02h
	int 21h
	
to_int_poryadok_2_start:
	mov ax,type number ;получение размера одной структуры
	mov di,offset mass_numbers ;получение ссылки на первы элемнт массива чисел
	mov bx, j
	mul bx
	add di,ax ;в DI индекс первого элемента массива чисел
	mov iter,0
	
	
to_int_poryadok_2:
	cmp [di].celaya, "$" ; если символ равен $
	je to_int_mantissa_start_2 ; обработка дробной части
	;вывод цифры
	mov dl, [di].celaya ;в dl ссылка на первую цифру целой части
	mov ah, 02h
	int 21h
	
	mov bl,[di].celaya ;в BL символ первой цифры целой части
	; получение значения целой части
	sub bl,"0" ; char to int
	mov ax,10
	mul res_poryadok2
	add al, bl
	mov res_poryadok2,ax
	inc di
	add iter,1
	jmp to_int_poryadok_2
	
to_int_mantissa_start_2:
	
	xor eax,eax
	;push iter
	sub di,iter ; переходим к дробной части
	mov iter, 0
	;вывод точки
	mov dl,"."
	mov ah,02h
	int 21h
to_int_mantissa_2:
	
	cmp [di].drobnaya, 0Dh ;если конец строки
	je start_get3elem 
	mov dl, [di].drobnaya
	mov ah, 02h
	int 21h
	mov bl,[di].drobnaya
	sub bl,"0"
	mov ax,10
	mul res_mantissa2
	add al, bl
	mov res_mantissa2,ax
	inc di
	add iter,1
	jmp to_int_mantissa_2
	
start_get3elem:
	push iter
	sub di,iter
	;;;;;;;;;;;;;;;;;;;;;;;
	mov dx, 0ah
	mov ah, 02h
	int 21h
	
to_int_poryadok_3_start:
	mov ax,type number ;получение размера одной структуры
	mov di,offset mass_numbers ;получение ссылки на первы элемнт массива чисел
	add j, 1
	mov bx, j ;;;;;;;;;;;;;;;;----------------;;;;;;;;;;
	mul bx
	add di,ax ;в DI индекс первого элемента массива чисел
	mov iter,0
	
	
to_int_poryadok_3:
	cmp [di].celaya, "$" ; если символ равен $
	je to_int_mantissa_start_3 ; обработка дробной части
	;вывод цифры
	mov dl, [di].celaya ;в dl ссылка на первую цифру целой части
	mov ah, 02h
	int 21h
	
	mov bl,[di].celaya ;в BL символ первой цифры целой части
	; получение значения целой части
	sub bl,"0" ; char to int
	mov ax,10
	mul res_poryadok3
	add al, bl
	mov res_poryadok3,ax
	inc di
	add iter,1
	jmp to_int_poryadok_3
	
to_int_mantissa_start_3:
	
	xor eax,eax
	;push iter
	sub di,iter ; переходим к дробной части
	mov iter, 0
	;вывод точки
	mov dl,"."
	mov ah,02h
	int 21h
to_int_mantissa_3:
	
	cmp [di].drobnaya, 0Dh ;если конец строки
	je start_op1_mul 
	mov dl, [di].drobnaya
	mov ah, 02h
	int 21h
	mov bl,[di].drobnaya
	sub bl,"0"
	mov ax,10
	mul res_mantissa3
	add al, bl
	mov res_mantissa3,ax
	inc di
	add iter,1
	jmp to_int_mantissa_3	
	
	
	
	
	
	
	
	
	
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	start_op1_mul:

	push iter
	sub di,iter
	
	mov dx, 0ah
	mov ah,02h
	int 21h
	
	xor ax,ax
	xor dx,dx	
	
	mov ax,res_mantissa1
	mov dx, res_mantissa2
	add ax,dx
	
	push ax
	
	xor ax,ax
	xor dx,dx
	
	mov ax, res_poryadok1
	mov dx, res_poryadok2
	add ax,dx
	jmp finalPrint
	
	;{
	;sum.txt
	
	;}
	
	
	finalPrint:
	;Вывод результата (Число должно быть в AX)
	
	mov     bx,     10              ;делитель (основание системы счисления)
	mov     cx,     0               ;количество выводимых цифр
	div2:
			xor     dx,     dx      ;делим (dx:ax) на bx
			div     bx
			add     dl,     '0'     ;преобразуем остаток деления в символ цифры
			push    dx              ;и сохраняем его в стеке
			inc     cx              ;увеличиваем счётчик цифр
			test    ax,     ax      ;в числе ещё есть цифры?
	jnz     div2                   ;да - повторить цикл выделения цифры
	show2:
			mov     ah,     02h     ;функция ah=02h int 21h - вывести символ из dl на экран
			pop     dx              ;извлекаем из стека очередную цифру
			int     21h             ;и выводим её на экран
	loop    show2                  ;и так поступаем столько раз, сколько нашли цифр в числе (cx)
	
	mov al, '.'
    int 29h
	
	pop ax
	
	mov     bx,     10              ;делитель (основание системы счисления)
        mov     cx,     0               ;количество выводимых цифр
        div1:
                xor     dx,     dx      ;делим (dx:ax) на bx
                div     bx
                add     dl,     '0'     ;преобразуем остаток деления в символ цифры
                push    dx              ;и сохраняем его в стеке
                inc     cx              ;увеличиваем счётчик цифр
                test    ax,     ax      ;в числе ещё есть цифры?
        jnz     div1                   ;да - повторить цикл выделения цифры
        show1:
                mov     ah,     02h     ;функция ah=02h int 21h - вывести символ из dl на экран
                pop     dx              ;извлекаем из стека очередную цифру
                int     21h             ;и выводим её на экран
        loop    show1                  ;и так поступаем столько раз, сколько нашли цифр в числе (cx)
	
	
	jmp exit






exit:
	mov ah,4ch
	int 21h
EXTRN   OutInt: NEAR
end