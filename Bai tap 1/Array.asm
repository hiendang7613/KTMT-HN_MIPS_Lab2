.data
	enterNArr_Title: .asciiz "Nhap so phan tu cua mang:"
	enterArr_s: .asciiz "Nhap phan tu cua mang\n"
	NWrong_s : .asciiz "Nhap n sai - hay nhap lai ( 0 < n < 1000 )\n"
	Arr: .word 0:100 	
	
	menu_Title: .asciiz "\n======MENU======\n1. Xuat ra cac phan tu.\n2. Tinh tong cac phan tu.\n3. Liet ke cac phan tu la so nguyen to.\n4. Tim max.\n5. Tim phan tu co gia tri x (nguoi dung nhap vao) trong mang.\n6. Thoat chuong trinh\n================"
	printArr_Title: .asciiz "======Xuat Mang======\n"
	space_c: .asciiz "   "
	sumArr_Title: .asciiz "======Tong Mang======\n Tong cua cac phan tu trong mang = "	
	primeArr_Title: .asciiz "======So nguyen to trong Mang======\n Cac so nguyen to trong mang = "
	maxArr_Title: .asciiz "======Max Mang======\n Gia tri lon nhat trong mang = "
	findArr_Title: .asciiz "======Tim x======\n Nhap x can tim  "
	findIsTrue_s: .asciiz "Vi tri phan tu x tim duoc =\n "
	findIsFalse_s: .asciiz "Khong tim thay phan tu x\n "
	sayGoodBye_s: .asciiz "GoodBye!!"
	comingBackToMenu_s: .asciiz "\ncoming back to menu ... (3 seconds)\n"
	
.text

	.globl main
	main :
		#In nhap so phan tu
		InputNLoop:
		li $v0, 4
		la $a0, enterNArr_Title
		syscall
		
		#Nhap so phan tu (nap vao $s0)
		li $v0, 5
		syscall
		move $s0, $v0		#$s0 = n
		
		blt $s0,1, FalseN
		bgt $s0,999, FalseN
		j TrueN
		
		FalseN:
		li $v0, 4
		la $a0, NWrong_s
		syscall
		
		j InputNLoop
		
		TrueN:
		li $v0, 4
		la $a0, enterArr_s
		syscall
		
		li $t0, 0
		la $t1, Arr
		
		#Nhap phan tu
		loop:
		li $v0, 5
		syscall
		sw $v0, ($t1)
		addi $t0, $t0, 1
		addi $t1, $t1, 4
		blt $t0, $s0, loop
		
	#Menu
	loopMenu:
		#In menu
		li $v0, 4
		la $a0, menu_Title
		syscall
		
		li $v0, 5
		syscall
		move $t0, $v0		#$t0 = choose
		
		beq $t0, 1, PrintArr
		beq $t0, 2, SumArr
		beq $t0, 3, PrimeArr
		beq $t0, 4, MaxArr
		beq $t0, 5, FindArr
		beq $t0, 6, GoodBye
		
		BackMenu:
		beq $0, 0, loopMenu
		

	#Xuat mang
	PrintArr:
		#Title
		li $v0, 4
		la $a0, printArr_Title
		syscall
	
		#Xuat console
		li $t0, 0
		la $t1, Arr
	
	    	ploop:
	    	lw $a0, ($t1)
		li $v0, 1
		syscall
		
		la $a0, space_c
		li $v0, 4
		syscall	

		addi $t0, $t0, 1
		addi $t1, $t1, 4
		
		blt $t0, $s0, ploop
		j Sleep
		
	#TInh tong
	SumArr:
		#Title
		li $v0, 4
		la $a0, sumArr_Title
		syscall
		
		#sum
		li $t2, 0 		#$t2 = sum
		
		li $t0, 0
		la $t1, Arr
	
	    	sumloop:
	    	lw $t3, ($t1)
	    	add $t2, $t2, $t3

		addi $t0, $t0, 1
		addi $t1, $t1, 4
		
		blt $t0, $s0, sumloop
		
		li $v0, 1
		move $a0, $t2
		syscall
		j Sleep
		
	#Liet ke so nguyen to
	PrimeArr:
		#Title
		li $v0, 4
		la $a0, primeArr_Title
		syscall
		
		#sum
		li $s1, 0		#$s1 = count
		la $s2, Arr		#$t2 = iterator
	
	    	PrimeLoop:
	    	lw $a0, ($s2)
	    	
	    	jal IsPrime
	    	
	    	beq $v0, 1, PrintPrime
	    	b PrimeFalse 
	    	    PrintPrime:
	    	    li $v0, 1
		    syscall
		    
		    la $a0, space_c
		    li $v0, 4
		    syscall
		PrimeFalse:

		addi $s1, $s1, 1
		addi $s2, $s2, 4
		
		blt $s1, $s0, PrimeLoop
		j Sleep
	
	IsPrime:
		li $t0, 2
		
		ble $a0, 2 , IsPrimeTrue
		ble $a0, 1 , IsPrimeFalse
		
	    	IsPrimeLoop:
	    	div $a0, $t0
	    	mfhi $t1
	    	beq $t1, 0, IsPrimeFalse
		addi $t0, $t0, 1
		blt $t0, $a0, IsPrimeLoop
		
		IsPrimeTrue:
		li $v0, 1
		jr $ra
		
		IsPrimeFalse:
	    	li $v0, 0
	    	jr $ra
	
	
	#Tim max
		MaxArr:
		#Title
		li $v0, 4
		la $a0, maxArr_Title
		syscall
		
		#sum
		li $s1, 0		#$s1 = count
		la $s2, Arr		#$s2 = iterator
		lw $s3, ($s2) 		#$s3 = max
		
	
	    	MaxLoop:
	    	lw $s4, ($s2)		#$s4 = a[i]
	    	sub $s5, $s4, $s3 	#$s5 = sub
	    	    	
	    	bgtz $s5,  Max
	    	b MaxFalse 
	    	    Max:
	    	    move $s3, $s4
		MaxFalse:

		addi $s1, $s1, 1
		addi $s2, $s2, 4
		
		blt $s1, $s0, MaxLoop
		
		#In Max
		move $a0, $s3
		li $v0, 1
		syscall
		
		j Sleep
		
	
	#Tim phan tu x
	FindArr:
		#Title
		li $v0, 4
		la $a0, findArr_Title
		syscall
		
		#Nhap x (nap vao $s3)
		li $v0, 5
		syscall
		move $s3, $v0		#$s3 = x
		
		#loop
		li $s1, 0		#$s1 = count
		la $s2, Arr		#$s2 = iterator
		
	
	    	FindLoop:
	    	lw $s4, ($s2)		#$s4 = a[i]
	    		    	    	
	    	beq $s4, $s3, FindArrTrue

		addi $s1, $s1, 1
		addi $s2, $s2, 4
		
		blt $s1, $s0, FindLoop
		
		# Khong tim thay
		li $v0, 4
		la $a0, findIsFalse_s
		syscall
		j Sleep
		
		#Tim thay 
		FindArrTrue:
		li $v0, 4
		la $a0, findIsTrue_s
		syscall
		
		li $v0, 1
		addi $s1, $s1, 1
		move $a0, $s1
		syscall
		j Sleep
		
		
	#Sleep
	Sleep:
	li $v0, 4
	la $a0, comingBackToMenu_s
	syscall
	
	li $a0, 3000		# 3 seconds
	li $v0, 32
	syscall
	
	j BackMenu

		
	#Goodbye!!
	GoodBye:
	li $v0, 4
	la $a0, sayGoodBye_s
	syscall
