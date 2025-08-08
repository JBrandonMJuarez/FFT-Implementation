
		.def	_FFTn
.sect

regs_A	.word	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
regs_B	.word	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.const
cosenos_Wn	.double 1, 0.707106781186548, 6.12323399573677e-17, -0.707106781186548		; 	Define un segmento de datos con etiqueta "vector"
senos_Wn	.double 0, -0.707106781186548, -1, -0.707106781186548
dir_Xr		.word	0
dir_Xi		.word	0
;.bss
;X_imag		.double 0, 0, 0, 0, 0, 0, 0, 0
;X_real_end	.double 0, 0, 0, 0, 0, 0, 0, 0
;X_imag_end	.double 0, 0, 0, 0, 0, 0, 0, 0

.text
_FFTn:
;X_real		.double 0.814723686393179, 0.905791937075619, 0.126986816293506, 0.913375856139019, 0.632359246225410, 0.0975404049994095, 0.278498218867048, 0.546881519204984

		; Salva los registros en memoria
		MVKL	regs_A, A10
		MVKH	regs_A, A10

		STW		A0, *A10++
		STW		A1, *A10++
		STW		A2, *A10++
		STW		A3, *A10++
		STW		A4, *A10++
		STW		A5, *A10++
		STW		A6, *A10++
		STW		A7, *A10++
		STW		A8, *A10++
		STW		A9, *A10++
		STW		A10, *A10++
		STW		A11, *A10++
		STW		A12, *A10++
		STW		A13, *A10++
		STW		A14, *A10++
		STW		A15, *A10++

		MVKL	regs_B, A10
		MVKH	regs_B, A10

		STW		B0, *A10++
		STW		B1, *A10++
		STW		B2, *A10++
		STW		B3, *A10++
		STW		B4, *A10++
		STW		B5, *A10++
		STW		B6, *A10++
		STW		B7, *A10++
		STW		B8, *A10++
		STW		B9, *A10++
		STW		B10, *A10++
		STW		B11, *A10++
		STW		B12, *A10++
		STW		B13, *A10++
		STW		B14, *A10++
		STW		B15, *A10++

; Sección de código



		MV		A4, A0				; Dirección inicial de x_real en A0. Se recibe en A4
		MV		B4, A1				; Dirección inicial de x_imag en A1. Se recibe en B4


		MVKL	dir_Xr, A4			;
		MVKH	dir_Xr, A4

		MVKL	dir_Xi, B4			;
		MVKH	dir_Xi, B4

		STW		A6,	*A4				;
		NOP		4
		STW		B6,	*B4				;
		NOP		4

		MV		A8, A5				; Size_problems = N TODO: Usar Variable. Se recibe en A8
		MV		B8, B14				; n (de log_2(N) / Número de bits) se recibe en B8, se copia a B14
		MV		B3, B13				; Copiar dirección de retorno a B13

		;MV		A6, B14				; n (de log_2(N) / Número de bits) se recibe en A6, se copia a B14
		MV		A5, B15				; N

		;MVK		X_imag, A1			; Dirección inicial de X_imag en A1
		MVKL		cosenos_Wn, A13		; Dirección inicial de cosenos_Wn
		MVKH		cosenos_Wn, A13		; Dirección inicial de cosenos_Wn
		MVKL		senos_Wn, A14		; Dirección inicial de senos_Wn
		MVKH		senos_Wn, A14		; Dirección inicial de senos_Wn

		MVK		0x01, A4			; Num_probl = 1;
		; While
ciclo_while:						; while Size_problems > 1
		SHRU	A5,1,A7				; Half_size = Size_problems/2;
		;ADD		A4,1,B15

		; Iteraciones en k
		MVK		0x00,A8				; for k = 0 : Num_probl - 1
ciclo_k:
		MPY		A8,A5,A9			; JFirst = k * Size_problems + 1;
		NOP		1

        ADD		A9,A7,A10			; JLast = JFirst + Half_size - 1;
        MVK		0,A11				; Jtwiddle = 0;

		; Iteraciones en j
		MV		A9,A12				; for j = JFirst : JLast
ciclo_j:
		ADD		A12,A7,A15			; j + Half_size

		LDDW	*+A0[A12],B1:B0		; Temp_real = a_real(j)
		NOP		4
		LDDW	*+A1[A12],B3:B2		; Temp_imag = a_imag(j)
		NOP		4
		LDDW	*+A0[A15],B5:B4		; Temp_real_h = a(j + Half_size)
		NOP		4
		LDDW	*+A1[A15],B7:B6		; Temp_imag_h = a(j + Half_size)
		NOP		4
		LDDW	*+A13[A11],B9:B8	; W_n_real = cosenos_Wn(Jtwiddle)
		NOP		4
		LDDW	*+A14[A11],B11:B10	; W_n_imag = senos_Wn(Jtwiddle)
		NOP		4


		ADDDP	B1:B0,B5:B4,B1:B0	; a_real(j) = Temp_real + Temp_real_h
		NOP		6
		ADDDP	B3:B2,B7:B6,B3:B2	; a_imag(j) = Temp_imag + Temp_imag_h;
		NOP		6

		MPY		A12,2,A12			; Ajuste en direccionamiento por palabra
		NOP		1

		STW		B0,*+A0[A12]		; Parte baja de a_real(j)
		NOP		4
		STW		B2,*+A1[A12]		; Parte baja de a_imag(j)
		NOP		4
		ADD		1,A12,A12
		STW		B1,*+A0[A12]		; Parte alta de a_real(j)
		NOP		4
		STW		B3,*+A1[A12]		; Parte alta de a_imag(j)
		NOP		4
		SUB		A12,1,A12			; Deshacer ajuste

		SHRU	A12,1,A12

		SUBDP	B1:B0,B5:B4,B1:B0	;
		NOP		6
		SUBDP	B1:B0,B5:B4,B1:B0	; Temp_real - Temp_real_h
		NOP		6
		SUBDP	B3:B2,B7:B6,B3:B2	;
		NOP		6
		SUBDP	B3:B2,B7:B6,B3:B2	; Temp_imag - Temp_imag_h;
		NOP		6

		MPY		A15,2,A15			; Ajuste para direccionamiento por palabra de j + Half_size
		NOP		1

		MPYDP	B9:B8,B1:B0,B5:B4	; cosenos_Wn(Jtwiddle) * (Temp_real - Temp_real_h)
		NOP		9
		MPYDP	B11:B10,B3:B2,B7:B6	; senos_Wn(Jtwiddle)*(Temp_imag - Temp_imag_h)
		NOP		9
		SUBDP	B5:B4,B7:B6,B5:B4	; a_real(j + Half_size) = cosenos_Wn(Jtwiddle) * (Temp_real - Temp_real_h) - senos_Wn(Jtwiddle)*(Temp_imag - Temp_imag_h)
		NOP		6
		STW		B4,*+A0[A15]		; Parte baja de a_real(j + Half_size)
		NOP		4
		ADD		A15,1,A15			; Ajuste de dirección
		STW		B5,*+A0[A15]		; Parte alta de a_real(j + Half_size)
		NOP		4

		SUB		A15,1,A15			; Ajuste de dirección
		MPYDP	B11:B10,B1:B0,B5:B4	; senos_Wn(Jtwiddle) * (Temp_real - Temp_real_h)
		NOP		9
		MPYDP	B9:B8,B3:B2,B7:B6	; cosenos_Wn(Jtwiddle)*(Temp_imag - Temp_imag_h)
		NOP		9
		ADDDP	B5:B4,B7:B6,B5:B4	; senos_Wn(Jtwiddle) * (Temp_real - Temp_real_h) + cosenos_Wn(Jtwiddle)*(Temp_imag - Temp_imag_h);
		NOP		6
		STW		B4,*+A1[A15]		; Parte baja de a_imag(j + Half_size)
		NOP		4
		ADD		A15,1,A15			; Ajuste de dirección
		STW		B5,*+A1[A15]		; Parte alta de a_imag(j + Half_size)
		NOP		4
		;SUB		A15,1,A15			; Ajuste de dirección

		ADD		A11,A4,A11			; Jtwiddle = Jtwiddle + Num_probl;

		ADD		A12,1,A12			; j = j+1
		SUB		A10,A12,A2			; j == JLast ?  (A13 = 1 ) : (A13 = 0 )
 [A2]	B		ciclo_j				; A2 == 0 ?  continue : ciclo_j
		NOP		5
		;END iteraciones en j

		ADD		A8,1,A8				; k = k+1
		SUB		A4,A8,A2			; k == Num_probl - 1 ?
 [A2]	B		ciclo_k				; A2 == 0 ?  continue : ciclo_k
		NOP		5
		;END iteraciones en k

		MPY		A4,2,A4				; Num_probl = 2 * Num_probl;
		NOP		1
		MV		A7,A5				; Size_problems = Half_size;

		SUB		A5,1,A2				; Size_problems > 1 ?
 [A2]	B		ciclo_while			; A2 == 0 ?  continue : ciclo_while
		NOP		5
		;END While

		MVKL	dir_Xr, A4			;
		MVKH	dir_Xr, A4			;
		MVKL	dir_Xi, B4			;
		MVKH	dir_Xi, B4			;

		LDW		*A4, A12
		NOP		4
		LDW		*B4, A13
		NOP		4

		;MVK		X_real_end, A12		; Dirección inicial de X_real_end
		;MVK		X_imag_end, A13		; Dirección inicial de X_imag_end TODO: cambiar nombre
		MV		B15, A5				; A5 = N		TODO: USAR VARIABLE(OK). La llamada a la función almacena N en B15 y aquí se lleva a A5
		MV		B14, A4				; n = 3			TODO: USAR VARIABLE Y ENCONTRAR n. Se recibe al inicio y se copia a B14

		MVK		0x00, A7			; for j = 0 : N
bit_reversi:
		LDDW	*+A0[A7], B1:B0		; real = X_real(i)
		LDDW	*+A1[A7], B3:B2		; imag = X_imag(i)

		MVK		0x00, A10
		MVK		0x00, A8			; for i = 0 : n
		MVK		0x00, A9			; A9 = 0
		MV		A7, A10				; DIR = A7

ciclo_i:
		SHL		A9,	1, A9			; result <<= 1;
		AND		A10, 1, A2			; if ((n & 1) == 1)
 [!A2]	B		desplaza_d			; A2 == 1 ?  desplaza_d : continue
 		NOP		5
 		ADD		A9, 1, A9			; result++
desplaza_d:
 		SHRU	A10, 1, A10			; DIR >>= 1;
		ADD		A8, 1, A8			; i = i + 1
		SUB		A8, A4, A2			; A8 == A4
 [A2]	B		ciclo_i				; A2 == 0 ?  continue : ciclo_i
 		NOP		5
		;END ciclo_i

		MPY		A9, 2, A9			; Ajuste de dirección nueva
		NOP		1

		STW		B0, *+A12[A9]		; X_real_end(r) = real
		NOP		4
		STW		B2, *+A13[A9]		; X_imag_end(r) = imag
		NOP		4
		ADD		A9,1,A9				; Ajuste para parte alta de dirección
		STW		B1, *+A12[A9]		; X_real_end(r) = real
		NOP		4
		STW		B3, *+A13[A9]		; X_imag_end(r) = imag
		NOP		4
		;SUB		A9, 1, A9		;

		ADD		A7,1,A7				; j = j + 1;
		SUB		A7,A5,A2			; j == N ?
 [A2]	B		bit_reversi			; A2 == 0 ?  continue : bit_reversi
		NOP		5
		; END bit_reversi

		MVKL	regs_A, A10
		MVKH	regs_A, A10

		LDW		*A10++,A0
		NOP		4
		LDW		*A10++,A1
		NOP		4
		LDW		*A10++,A2
		NOP		4
		LDW		*A10++,A3
		NOP		4
		LDW		*A10++,A4
		NOP		4
		LDW		*A10++,A5
		NOP		4
		LDW		*A10++,A6
		NOP		4
		LDW		*A10++,A7
		NOP		4
		LDW		*A10++,A8
		NOP		4
		LDW		*A10++,A9
		NOP		4
		;LDW		*A10++,A10
		;NOP		4
		LDW		*A10++,A11
		NOP		4
		LDW		*A10++,A12
		NOP		4
		LDW		*A10++,A13
		NOP		4
		LDW		*A10++,A14
		NOP		4
		LDW		*A10++,A15
		NOP		4

		MVKL	regs_B, A10
		MVKH	regs_B, A10

		LDW		*A10++,B0
		NOP		4
		LDW		*A10++,B1
		NOP		4
		LDW		*A10++,B2
		NOP		4
		LDW		*A10++,B3
		NOP		4
		LDW		*A10++,B4
		NOP		4
		LDW		*A10++,B5
		NOP		4
		LDW		*A10++,B6
		NOP		4
		LDW		*A10++,B7
		NOP		4
		LDW		*A10++,B8
		NOP		4
		LDW		*A10++,B9
		NOP		4
		LDW		*A10++,B10
		NOP		4
		LDW		*A10++,B11
		NOP		4
		LDW		*A10++,B12
		NOP		4
		LDW		*A10++,B13
		NOP		4
		LDW		*A10++,B14
		NOP		4
		LDW		*A10++,B15
		NOP		4


		B		B3					; Regresa
		NOP		5					; Slot 5


termina:
wait
	B		wait					;Espera aqui
	NOP		5						;Retardos para el salto
