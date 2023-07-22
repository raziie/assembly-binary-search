%include "asm_io.inc"
extern _scanf

segment .bss
array:	resd 100

segment .data
msg1:	dd "enter length of array:", 0
msg2:	dd "elements:", 0
msg3:	dd "enter key:", 0
msg4:	dd "index of key is:", 0
key:	dd 0
float_format: db  "%f", 0 
len:	dd 0
segment .text
        global  _asm_main
_asm_main:
        enter   0,0
        pusha

		; get length of array
		mov eax, msg1 
		call print_string
		call print_nl
		call read_int
		mov [len], eax

		; get elements of array
		mov eax, msg2
		call print_string
		call print_nl

		mov edi, 0 ; index
		mov ecx, [len]
l1:
		call read_float
		mov [array + 4*edi], eax
		inc edi
		loop l1	

		; get key
		mov eax, msg3
		call print_string
		call print_nl
		call read_float
		mov dword [key], eax

		mov edx, [len]
		dec edx ; index of last element

		push dword [key] ; key
		push array ; array
		push 0 ; low
		push edx ; high
		call search
		add esp, 16

		mov ebx, eax
		mov eax, msg4 ; print(index of key is:)
		call print_string
		call print_nl
		mov eax, ebx ; print result
		call print_int
		call print_nl

        popa
        mov     eax, 0
        leave                     
        ret

search:
		enter 4,0 ; reserve 4 bytes for storing result
		pusha

		mov edi, [ebp + 8] ; high
		mov esi, [ebp + 12] ; low
		mov ebx, [ebp + 16] ; array
binary_search:
		cmp edi, esi ; if high < low
		jl not_found ; retrun -1

		mov eax, edi ; eax = mid = (high + low) / 2
		add eax, esi
		sar eax, 1

		fld dword [ebp + 20] ; compare array[mid] , key
		fld dword [ebx + 4*eax]
		fcomip st1
		fstp st0

		ja left_search ; if array[mid] > key
		jb right_search ; if array[mid] < key
		jmp end	; if array[mid] == key return mid

left_search:
		push dword [ebp + 20] ; key
		push ebx ; array
		push esi ; low
		dec eax
		push eax ; high (mid - 1)
		call search
		add esp, 16
		jmp end

right_search:
		push dword [ebp + 20] ; key
		push ebx ; array
		inc eax
		push eax ; low (mid + 1)
		push edi ; high
		call search
		add esp, 16
		jmp end

not_found:
		mov eax, -1

end:
		mov [ebp - 4], eax
		popa
		pop eax
		leave
		ret

read_float:
        enter 4,0
        pusha
        pushf
        lea eax, [ebp-4]
        push eax
        push dword float_format
        call _scanf
        pop eax
        pop eax
        popf
        popa
        mov eax, [ebp-4]
        leave
        ret			