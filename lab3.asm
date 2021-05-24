.MODEL SMALL
	.STACK 500h
.386

;шаблон структуры
number struc
celaya db 15 dup ("$")
drobnaya db 4 dup ("$")
number ends

.data
zapros1 db "Vvedite do 100 chisel:","$"
zapros2 db "Vvedite I:","$"
zapros3 db "Vvedite J:","$"
primer db "Zadanie: (A[I] + A[J] * A[J + 1])", "$"
result db "Result: ","$"
mass_numbers number 100 dup (<>)
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
res_poryadok dw 0
res_mantissa dw 0
mulCel1 dw 0
mulCel2 dw 0
mulCel3 dw 0
mulCel4 dw 0
mulCel5 dw 0
mulDrob1 dw 0
mulDrob2 dw 0
mulDrob3 dw 0
mulDrob4 dw 0
mulDrob5 dw 0
mulVarRes dw 0
tempVar dw 0
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
	mov bx, j 
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
	
	;MOV AX, 150    ; Первый множитель в регистр AX
	;MOV BX, 250    ; Второй множитель в регистр BX
	;MUL BX         ; Теперь АХ = 150 * 250 = 37500
	
	;в переменных числа
	;A[I] + A[J] * A[J + 1]
	
	calculate_Cel1Cel2:
	;Этап цел1\цел2
	mov ax, res_poryadok2
	mov bx, res_poryadok3
	mul bx ;в ax = cel1 * cel2
	mov mulCel1, ax ;в стеке cel1 * cel2
	;целое1 заполнено
	xor ax,ax
	xor bx,bx
	
	
	;Этап цел1\дроб2
	mov ax, res_poryadok2
	mov bx, res_mantissa3
	mul bx
	; в ax cel1 * drob2
	 ;старший байт слово делимого
	mov bx, 10
	mov cx,3
	;цикл выполняеться 3 раза
	pushDrob1Cycle:
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	loop pushDrob1Cycle
	mov tempVar, ax  ;сохраняем оставшееся число
	
	mov cx, 3
	popFromStackDrob1Cycle:
	mov dx, 0
	mov ax, mulDrob1
	mul bx ;ax = muldrob * 10
	;;
	mov mulDrob1, ax
	;;
	pop ax
	add mulDrob1, ax	;добавляем остаток из стека
	loop popFromStackDrob1Cycle
	;дробное1 заполнено; осталось целое2
	
	mov ax, tempVar ;отсаток от числа в ax
	cmp ax, 0
	je skipPushCel2Cycle ;если целой части в результате умножения 
	                     ; не обнаружено то пропустить
	pushCel2Cycle:
	cmp ax, 0
	je exitFrompushCel2Cycle
	
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	inc k
	jmp pushCel2Cycle
	
	exitFrompushCel2Cycle:
	
	mov cx, k
	
	popFromStackCel2Cycle:
	
	mov dx, 0
	mov ax, mulCel2
	mul bx ;ax = mulCel2 * 10
	;
	mov mulCel2, ax
	;
	pop ax
	add mulCel2, ax	;	
	
	loop popFromStackCel2Cycle
	
	skipPushCel2Cycle:
	;целое2 заполнено; осталось целое3 + дробное2 + дробное3
	
	;Этап цел2\дроб1
	
	mov ax, res_poryadok3
	mov bx, res_mantissa2
	mul bx
	; в ax cel2 * drob1
	 ;старший байт слово делимого
	mov bx, 10
	mov cx,3
	;цикл выполняеться 3 раза
	pushDrob2Cycle:
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	loop pushDrob2Cycle
	mov tempVar, ax  ;сохраняем оставшееся число
	
	mov cx, 3
	popFromStackDrob2Cycle:
	mov dx, 0
	mov ax, mulDrob2
	mul bx ;ax = muldrob2 * 10
	;
	mov mulDrob2, ax
	;
	pop ax
	add mulDrob2, ax	;добавляем остаток из стека
	loop popFromStackDrob2Cycle
	;дробное1 заполнено; осталось целое2
	
	mov ax, tempVar ;отсаток от числа в ax
	
	mov k, 0 ;обнуляем счетчик оставшихся цифр целого
	
	cmp ax, 0
	je skipPushCel3Cycle
	
	pushCel3Cycle:
	cmp ax, 0
	je exitFrompushCel3Cycle
	
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	inc k
	jmp pushCel3Cycle
	
	exitFrompushCel3Cycle:
	
	mov cx, k
	
	popFromStackCel3Cycle:
	
	mov dx, 0
	mov ax, mulCel3
	mul bx ;ax = mulCel2 * 10
	;
	mov mulCel3, ax
	;
	pop ax
	add mulCel3, ax	;	
	
	loop popFromStackCel3Cycle
	
	skipPushCel3Cycle:
	;целое3 и дробное2 заполнено; осталось дробное 3

	;этап дроб1\дроб2
	
	mov bx, res_mantissa2
	mov ax, res_mantissa3
	mul bx ;ax = drob1 * drob2
	mov dx, 0
	mov bx, 1000
	div bx ;ax = drob1 * drob2 \ 1000
	
	mov bx,10
	mov cx,3
	
	pushDrob3Cycle:
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	loop pushDrob3Cycle
	
	
	mov cx, 3
	popFromStackDrob3Cycle:
	mov dx, 0
	mov ax, mulDrob3
	mul bx ;ax = muldrob * 10
	;
	mov mulDrob3, ax
	;
	pop ax
	add mulDrob3, ax	;добавляем остаток из стека
	loop popFromStackDrob3Cycle
	
	;целое1 + целое2  + дробное1
	;+ целое3 + дробное2 + дробное3 заполнено
	;этап сложения 
	
	mov res_mantissa3, 0
	mov res_poryadok3 , 0
	
	mov ax, mulCel1
	add res_poryadok3, ax
	mov ax, mulCel2
	add res_poryadok3, ax
	mov ax, mulCel3
	add res_poryadok3, ax
	;в res_poryadok3 целая часть результата умножения
	
	mov ax, mulDrob1
	add res_mantissa3, ax
	mov ax, mulDrob2
	add res_mantissa3, ax
	mov ax, mulDrob3
	add res_mantissa3, ax
	
	mov ax, res_mantissa3
	;;;;;;;;;;;;;;;;;;;;;
	mov bx, 10
	mov cx,3
	;цикл выполняеться 3 раза
	pushDrob4Cycle:
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	loop pushDrob4Cycle
	mov tempVar, ax  ;сохраняем оставшееся число
	
	
	
	mov cx, 3
	popFromStackDrob4Cycle:
	mov dx, 0
	mov ax, mulDrob4
	mul bx ;ax = muldrob * 10
	;
	mov mulDrob4, ax
	;
	pop ax
	add mulDrob4, ax	;добавляем остаток из стека
	loop popFromStackDrob4Cycle
	;дробное1 заполнено; осталось целое2
	
	mov ax, tempVar ;отсаток от числа в ax
	
	mov k, 0
	
	cmp ax, 0
	je skipPushCel4Cycle
	
	
	pushCel4Cycle:
	cmp ax, 0
	je exitFrompushCel4Cycle
	
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	inc k
	jmp pushCel4Cycle
	
	exitFrompushCel4Cycle:
	
	mov cx, k
	
	popFromStackCel4Cycle:
	
	mov dx, 0
	mov ax, mulCel4
	mul bx ;ax = mulCel2 * 10
	;
	mov mulCel4, ax
	;
	pop ax
	add mulCel4, ax	;	
	
	loop popFromStackCel4Cycle
	
	skipPushCel4Cycle:
	
	mov ax, mulCel4 ;в mulCel4 целая часть результата сложения
	add res_poryadok3, ax ; добавляем к целой части
	
	mov ax,mulDrob4 ; в mulDrob4 дробная часть результата сложения
	
	mov res_mantissa3, ax
	
	mov ax, res_mantissa3 ;  в res_mantissa3 дробная часть результата умножения
	push ax
	mov ax, res_poryadok3 ; в res_poryadok3 дробная часть результата умножения
	push ax
	
	xor ax,ax
	mov ax,res_poryadok1
	add ax,res_poryadok3 ; в ax сумма целой части
	mov res_poryadok, ax
	
	xor ax,ax
	mov ax,res_mantissa1
	add ax,res_mantissa3 ; в ax сумма целой части
	
	mov res_mantissa, ax
	
	mov ax, res_mantissa
	
	;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov bx, 10
	mov cx,3
	;цикл выполняеться 3 раза
	pushDrob5Cycle:
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	loop pushDrob5Cycle
	mov tempVar, ax  ;сохраняем оставшееся число
	
	
	
	mov cx, 3
	popFromStackDrob5Cycle:
	mov dx, 0
	mov ax, mulDrob5
	mul bx ;ax = muldrob * 10
	;
	mov mulDrob5, ax
	;
	pop ax
	add mulDrob5, ax	;добавляем остаток из стека
	loop popFromStackDrob5Cycle
	;дробное1 заполнено; осталось целое2
	
	mov ax, tempVar ;отсаток от числа в ax
	
	mov k, 0
	
	cmp ax, 0
	je skipPushCel5Cycle
	
	
	pushCel5Cycle:
	cmp ax, 0
	je exitFrompushCel5Cycle
	
	mov dx, 0
	div bx ;результат деления в ax, остаток в dx
	push dx ;сохраняем остаток в стек
	inc k
	jmp pushCel5Cycle
	
	exitFrompushCel5Cycle:
	
	mov cx, k
	
	popFromStackCel5Cycle:
	
	mov dx, 0
	mov ax, mulCel5
	mul bx ;ax = mulCel2 * 10
	;
	mov mulCel5, ax
	;
	pop ax
	add mulCel5, ax	;	
	
	loop popFromStackCel5Cycle
	
	skipPushCel5Cycle:
	;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov ax, mulCel5
	add res_poryadok, ax
	
	mov ax,mulDrob5 ; в mulDrob4 дробная часть результата сложения
	
	mov res_mantissa, ax
	
	mov ax, res_mantissa
	push ax
	mov ax, res_poryadok
	push ax
	
	
	
	
	jmp finalPrint
	
	
	
	finalPrint:
	;Вывод результата (Число должно быть в AX)
	
	mov dx, offset result
	mov ah,09h
	int 21h
	
	pop ax 
	
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