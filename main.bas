10 INK 4
20 BORDER 0
30 PAPER 0
40 CLS
50 PRINT "Initialising SPACE FLEET please wait...";
60 REM support print at 22+ via stream
70 DEF FN s(x)=(1+(x<22))
80 DEF FN x(x)=(x-(22*(x>21)))
90 REM the map
100 DIM l(8, 12)
110 REM attack vectors: 1:dx,2:dy,3:damage
120 DIM a(30, 3)
130 REM movement vectors: 1:dx,2:dy,3:dir (+- clockwise)
140 DIM m(15, 3)
150 REM names
160 DIM n$(4, 5)
170 REM player data: 1:x,2:y,3:dir(0:u,1:r,2:d,3:l),4:front,5:right,6:back,7:left,8:hull,9:manoeuvre,10:attack
180 DIM d(4, 10)
190 REM player UIs: 1:ship,2:planet,3:planet-x,4:planet-y;5:shield-x;6:shield-y
200 DIM u(4, 6)
210 REM load attack vectors
220 RESTORE 8220
230 FOR x = 1 TO 30 STEP 1
240 FOR y = 1 TO 3 STEP 1
250 READ a(x, y)
260 NEXT y
270 NEXT x
280 REM load movement vectors
290 RESTORE 8530
300 FOR x = 1 TO 15 STEP 1
310 FOR y = 1 TO 3 STEP 1
320 READ m(x, y)
330 NEXT y
340 NEXT x
350 REM load player UIs and name
360 RESTORE 8690
370 FOR x = 1 TO 4 STEP 1
380 FOR y = 1 TO 6 STEP 1
390 READ u(x, y)
400 NEXT y
410 NEXT x
420 RESTORE 8740
430 FOR x = 1 TO 4 STEP 1
440 READ n$(x)
450 NEXT x
460 REM load UDGs
470 LET i = USR "a"
480 LET t = i+8*19-1
490 RESTORE 8810
500 FOR x = i TO t STEP 1
510 READ y
520 POKE x, y
530 NEXT x
540 LET k$ = ""
1000 CLS
1010 GO SUB 3000
1030 GO SUB 4000
1040 IF k$ <> "Y" THEN GO TO 1000
1050 REM main game loop
1060 FOR p = 1 TO t STEP 1
1070 IF d(p, 1) = 0 THEN GO TO 1140
1080 LET k$ = ""
1090 REM main move input loop
1100 GO SUB 5200
1110 GO SUB 4200
1120 GO SUB 4000
1130 IF k$ <> "Y" THEN GO TO 1090
1140 NEXT p
1150 REM move then redraw ships
1160 FOR p = 1 TO t STEP 1
1170 IF d(p, 8) < 1 THEN GO TO 1200
1180 LET tx = (d(p, 1) - 1) * 2 : LET ty = ((d(p, 2) - 1) * 2) + 8
1190 GO SUB 6000 : PRINT AT tx, ty; "  "; AT tx + 1, ty; "  " : GO SUB 5600
1200 NEXT p
1210 GO SUB 6200
1220 REM combat phase
1230 FOR p = 1 TO t STEP 1
1240 REM check ship on map
1250 IF d(p, 1) < 1 THEN GO TO 1320
1260 LET k$ = ""
1270 REM main attack input loop
1280 GO SUB 5200
1290 GO SUB 4500
1300 GO SUB 4000
1310 IF k$ <> "Y" THEN GO TO 1270
1320 REM next attack input     
1330 NEXT p
1340 REM apply combat
1350 FOR p = 1 TO t STEP 1
1360 REM if ship on map
1370 IF d(p, 1) > 0 THEN GO SUB 5200 : GO SUB 6500
1380 NEXT p    
1390 REM move killed ships off map
1400 FOR p = 1 TO t STEP 1
1410 REM if ship on map and 0 hull move off map
1420 IF d(p, 1) > 0 AND d(p, 8) < 1 THEN LET d(p, 1) = 0
1430 NEXT p
1440 GO SUB 6200
1450 GO SUB 7500
1460 IF t > 0 THEN GO TO 1050
1470 GO TO 1000
3000 REM initialise game
3010 LET p = 1
3020 LET t = 0
3030 GO SUB 5200
3040 GO SUB 5000
3050 PRINT AT 17, 11; INK 5; "<SPACE FLEET>";
3060 PRINT AT 19, 11; "Enter players 2-4? "; FLASH 1; CHR$(143);
3070 PAUSE 0
3080 LET k$ = INKEY$
3090 IF CODE(k$) < 50 OR CODE(k$) > 52 THEN GO TO 3070
3100 PRINT AT 19, 30; k$;
3110 LET t = VAL(k$)
3115 PRINT AT 20, 11; "Loading map...";
3120 REM load player data
3130 RESTORE 8760
3140 FOR x = 1 TO t STEP 1
3150 FOR y = 1 TO 10 STEP 1
3160 READ d(x, y)
3170 NEXT y
3180 NEXT x
3190 REM clear map
3200 FOR y = 1 TO 12 STEP 1
3210 FOR x = 1 TO 8
3220 LET l(x, y) = 0
3230 NEXT x
3240 NEXT y     
3250 REM generate planet locations
3260 RANDOMIZE 0
3270 REM always 4 planets 
3280 FOR p = 1 TO 4  
3290 REM randomise planet locations
3300 LET x = INT (RND * 4) + u(p, 3)
3310 LET y = INT (RND * 4) + u(p, 4)
3320 REM avoid edges
3330 IF x < 2 OR x > 7 OR y < 2 OR y > 11 THEN GO TO 3290
3340 REM update map and draw planet
3350 LET l(x, y) = u(p, 2)
3360 LET tx = (x - 1) * 2
3370 LET ty = ((y - 1) * 2) + 8
3380 PRINT AT tx, ty; INK l(x, y); PAPER 0; CHR$(144); CHR$(145); AT tx + 1, ty; CHR$(146); CHR$(147);
3390 NEXT p
3400 REM draw players
3410 FOR p = 1 TO t STEP 1
3420 GO SUB 5500
3430 GO SUB 5600
3440 NEXT p
3450 PRINT AT 20, 11; "              ";
3460 RETURN
4000 REM console confirm
4010 PRINT #1; AT 1, 11; INK 6; "Confirm Y/N? "; FLASH 1; CHR$(143);
4020 PAUSE 0
4030 LET k$ = INKEY$
4040 IF k$ = "y" OR k$ = "Y" THEN LET k$ = "Y" : GO TO 4070
4050 IF k$ = "n" OR k$ = "N" THEN LET k$ = "N" : GO TO 4070
4060 GO TO 4020
4070 PRINT #1; AT 1, 24; INK 6; k$;
4080 RETURN
4200 REM console movement
4210 PRINT AT 17, 11; INK 5; "<Helm Computer>";
4220 PRINT AT 19, 11; "Speed A/B/C? "; FLASH 1; CHR$(143);
4240 LET d(p, 9) = 1
4250 PAUSE 0           
4260 IF INKEY$ = "A" OR INKEY$ = "a" THEN LET d(p, 9) = 0 : LET k$ = "A" : GO TO 4290
4270 IF INKEY$ = "B" OR INKEY$ = "b" THEN LET d(p, 9) = 5 : LET k$ = "B" : GO TO 4290
4280 IF INKEY$ = "C" OR INKEY$ = "c" THEN LET d(p, 9) = 10 :  LET k$ = "C"
4300 IF d(p, 9) = 1 THEN GO TO 4250
4310 PRINT AT 19, 24; k$;
4320 PRINT AT 20, 11; "Movement 1-5? "; FLASH 1; CHR$(143);
4330 PAUSE 0
4340 LET k$ = INKEY$
4350 IF CODE(k$) < 49 OR CODE(k$) > 53 THEN GO TO 4330
4360 PRINT AT 20, 25; k$;
4370 LET d(p, 9) = d(p, 9) + VAL(k$)  
4380 RETURN
4500 REM console attack
4510 PRINT AT 17, 11; INK 5; "<Combat Display>";
4520 PRINT AT 19, 11; "Distance A-F? "; FLASH 1; CHR$(143);   
4540 LET d(p, 10) = 1
4560 PAUSE 0      
4570 IF INKEY$ = "A" OR INKEY$ = "a" THEN LET d(p, 10) = 0 : LET k$ = "A" : GO TO 4630
4580 IF INKEY$ = "B" OR INKEY$ = "b" THEN LET d(p, 10) = 5 : LET k$ = "B" : GO TO 4630
4590 IF INKEY$ = "C" OR INKEY$ = "c" THEN LET d(p, 10) = 10 : LET k$ = "C" : GO TO 4630
4600 IF INKEY$ = "D" OR INKEY$ = "d" THEN LET d(p, 10) = 15 : LET k$ = "D" : GO TO 4630
4610 IF INKEY$ = "E" OR INKEY$ = "e" THEN LET d(p, 10) = 20 : LET k$ = "E" : GO TO 4630
4620 IF INKEY$ = "F" OR INKEY$ = "f" THEN LET d(p, 10) = 25 : LET k$ = "F"
4640 IF d(p, 10) = 1 THEN GO TO 4560
4650 PRINT AT 19, 25; k$;
4660 PRINT AT 20, 11; "Arc 1-5? "; FLASH 1; CHR$(143);
4670 LET k$ = ""
4680 PAUSE 0
4690 LET k$ = INKEY$
4700 IF CODE(k$) < 49 OR CODE(k$) > 53 THEN GO TO 4680
4710 PRINT AT 20, 20; k$;
4720 LET d(p, 10) = d(p, 10) + VAL(k$)   
4730 RETURN
4800 REM console any key
4810 PRINT #1; AT 1, 11; INK 6; "Press any key."; : PAUSE 0 : RETURN
5000 REM draw common controls
5010 PRINT AT 0, 0; INK 5; "Combat";
5020 PRINT AT 1, 0; INK 5; "Display";
5030 PRINT AT 2, 1; "12345";
5040 PRINT AT 3, 0; "A"; PAPER 2; "     "; INK 2; PAPER 0; "4";
5050 PRINT AT 4, 0; "B"; PAPER 6; " "; PAPER 2; "   "; PAPER 6; " "; INK 2; PAPER 0; "2";
5060 PRINT AT 5, 0; "C"; PAPER 6; "  "; PAPER 2; " "; PAPER 6; "  "; INK 2; PAPER 0; "1";
5070 PRINT AT 6, 0; "D"; PAPER 6; "  "; INK 1; PAPER 0; CHR$(161); PAPER 6; "  ";
5080 PRINT AT 7, 0; "E"; PAPER 6; "  "; PAPER 0; " "; PAPER 6; "  ";
5090 PRINT AT 8, 0; "F"; PAPER 6; " "; PAPER 0; "   "; PAPER 6; " ";
5100 PRINT AT 9, 4; INK 6; "31";
5110 PRINT AT 16, 0; INK 5; "Helm"; INK 1; CHR$(140); INK 5; "Computer";
5120 PRINT AT 17, 0; "A"; PAPER 0; CHR$(160); CHR$(162); INK 0; PAPER 4; CHR$(161); CHR$(162); INK 4; PAPER 0; CHR$(161); INK 0; PAPER 4; CHR$(162); CHR$(161); INK 4; PAPER 0; CHR$(162); CHR$(160);
5130 PRINT AT 18, 1; " "; CHR$(162); INK 0; PAPER 4; " "; CHR$(162); INK 4; PAPER 0; CHR$(162); INK 0; PAPER 4; CHR$(162); " "; INK 4; PAPER 0; CHR$(162); " ";
5140 PRINT AT 19, 1; " "; CHR$(161); INK 0; PAPER 4; " "; CHR$(161); INK 4; PAPER 0; CHR$(161); INK 0; PAPER 4; CHR$(161); " "; INK 4; PAPER 0; CHR$(161); " ";
5150 PRINT AT 20, 0; "B"; INK 0; PAPER 4; CHR$(160); CHR$(162); INK 4; PAPER 0; CHR$(161); CHR$(162); INK 0; PAPER 4; CHR$(161); INK 4; PAPER 0; CHR$(162); CHR$(161); INK 0; PAPER 4; CHR$(162); CHR$(160);
5160 PRINT AT 21, 1; INK 0; PAPER 4; " "; CHR$(161); INK 4; PAPER 0; " "; CHR$(161); INK 0; PAPER 4; CHR$(161); INK 4; PAPER 0; CHR$(161); " "; INK 0; PAPER 4; CHR$(161); " ";
5170 PRINT #1; AT 0, 0; INK 4; "C   "; INK 0; PAPER 4; CHR$(160); INK 4; PAPER 0; CHR$(161); INK 0; PAPER 4; CHR$(160); INK 4; PAPER 0; "   ";
5180 PRINT #1; AT 1, 2; INK 4; "1 234 5 ";
5190 RETURN
5200 REM draw player controls and clear console
5210 INK u(p, 1)
5220 PRINT AT 0, 6; CHR$(133); CHR$(161);
5230 PRINT AT 1, 7; CHR$(161);
5240 PRINT AT 2, 0; CHR$(138); AT 2, 6; CHR$(133); CHR$(161);
5250 PRINT AT 3, 7; CHR$(161);
5260 PRINT AT 4, 7; CHR$(161);
5270 PRINT AT 5, 7; CHR$(161);
5280 PRINT AT 6, 3; CHR$(161); AT 6, 6; CHR$(133); CHR$(161);
5290 PRINT AT 7, 6; CHR$(133); CHR$(161);
5300 PRINT AT 8, 6; CHR$(133); CHR$(161);
5310 PRINT AT 9, 0; CHR$(142); CHR$(140); CHR$(140); CHR$(140); AT 9, 6; CHR$(141); CHR$(161);
5320 PRINT AT 10, 6; CHR$(133); CHR$(161);
5330 PRINT AT 11, 6; CHR$(133); CHR$(161);
5340 PRINT AT 12, 6; CHR$(133); CHR$(161);
5350 PRINT AT 13, 6; CHR$(133); CHR$(161);
5360 PRINT AT 14, 6; CHR$(133); CHR$(161);
5370 PRINT AT 15, 6; CHR$(133); CHR$(161);
5380 PRINT AT 16, 4; CHR$(140); AT 16, 13; CHR$(140); CHR$(140); CHR$(140); CHR$(140); CHR$(140); CHR$(140); CHR$(140); CHR$(140); INK 7; PAPER 0; "SPACE"; INK u(p, 1); CHR$(140); INK 7; n$(p);
5390 PRINT AT 17, 10; CHR$(138); "                     ";
5400 PRINT AT 18, 10; CHR$(138); "                     ";
5410 PRINT AT 19, 10; CHR$(138); "                     ";
5420 PRINT AT 20, 10; CHR$(138); "                     ";
5430 PRINT AT 21, 10; CHR$(138); "                     ";
5440 PRINT #1; AT 0, 10; INK u(p, 1); CHR$(138); "                     ";
5450 PRINT #1; AT 1, 10; INK u(p, 1); CHR$(138); "                     ";
5460 INK 4
5470 RETURN
5500 REM draw player shields
5510 IF d(p, 8) < 1 THEN PRINT AT 10 + u(p, 5), 1 + u(p, 6); " "; AT 11 + u(p, 5), u(p, 6); "   "; AT 12 + u(p, 5), 1 + u(p, 6); " "; : RETURN
5520 PRINT AT 10 + u(p, 5), 1 + u(p, 6); INK u(p, 1); d(p, 4);
5530 PRINT AT 11 + u(p, 5), u(p, 6); INK u(p, 1); d(p, 7); INK 0; PAPER u(p, 1); d(p, 8); INK u(p, 1); PAPER 0; d(p, 5);
5540 PRINT AT 12 + u(p, 5), 1 + u(p, 6); INK u(p, 1); d(p, 6);
5550 RETURN
5600 REM draw player ship
5610 LET tx = (d(p, 1) - 1) * 2
5620 LET ty = ((d(p, 2) - 1) * 2) + 8
5630 IF d(p, 8) = 0 THEN PRINT AT tx, ty; "  "; AT tx + 1, ty; "  "; : RETURN
5640 IF d(p, 3) = 0 THEN PRINT AT tx, ty; INK u(p, 1); CHR$(152); CHR$(153); AT tx + 1, ty; CHR$(150); CHR$(151); : RETURN
5650 IF d(p, 3) = 1 THEN PRINT AT tx, ty; INK u(p, 1); CHR$(148); CHR$(156); AT tx + 1, ty; CHR$(150); CHR$(157); : RETURN
5660 IF d(p, 3) = 2 THEN PRINT AT tx, ty; INK u(p, 1); CHR$(148); CHR$(149); AT tx + 1, ty; CHR$(154); CHR$(155); : RETURN
5670 PRINT AT tx, ty; INK u(p, 1); CHR$(158); CHR$(149); AT tx + 1, ty; CHR$(159); CHR$(151);
5680 RETURN
5800 REM draw target explosion
5810 LET tx = (d(q, 1) - 1) * 2
5820 LET ty = ((d(q, 2) - 1) * 2) + 8
5830 PRINT AT tx, ty; INK 6; PAPER 2; FLASH 1; CHR$(139); CHR$(135); AT tx + 1, ty; CHR$(142); CHR$(141);
5840 RETURN
6000 REM player move
6010 IF d(p, 3) = 0 THEN LET x = d(p, 1) + m(d(p, 9), 1) : LET y = d(p, 2) + m(d(p, 9), 2) : GO TO 6050
6020 IF d(p, 3) = 1 THEN LET x = d(p, 1) + m(d(p, 9), 2) : LET y = d(p, 2) - m(d(p, 9), 1) : GO TO 6050
6030 IF d(p, 3) = 2 THEN LET x = d(p, 1) - m(d(p, 9), 1) : LET y = d(p, 2) - m(d(p, 9), 2) : GO TO 6050
6040 LET x = d(p, 1) - m(d(p, 9), 2) : LET y = d(p, 2) + m(d(p, 9), 1)
6050 IF x < 1 OR x > 8 OR y < 1 OR y > 12 THEN RETURN
6060 IF l(x, y) > 0 THEN RETURN
6070 LET d(p, 1) = x
6080 LET d(p, 2) = y
6090 LET d(p, 3) = d(p, 3) + m(d(p, 9), 3)
6100 IF d(p, 3) > 3 THEN LET d(p, 3) = d(p, 3) - 4 : RETURN
6110 IF d(p, 3) < 0 THEN LET d(p, 3) = d(p, 3) + 4
6120 RETURN
6200 REM collision check
6210 FOR p = 1 TO t STEP 1
6220 IF d(p, 1) < 1 THEN GO TO 6300
6230 FOR q = p TO t STEP 1
6240 IF p = q OR d(q, 1) < 1 OR d(p, 1) <> d(q, 1) OR d(p, 2) <> d(q, 2) THEN GO TO 6290
6250 REM collision!
6260 LET tx = (d(p, 1) - 1) * 2
6270 LET ty = ((d(p, 2) - 1) * 2) + 8
6280 PRINT AT tx, ty; INK u(p, 1); PAPER u(q, 1); FLASH 1; CHR$(139); CHR$(135); AT tx + 1, ty; CHR$(142); CHR$(141);
6290 NEXT q
6300 NEXT p
6310 RETURN
6500 REM player attack
6510 IF a(d(p, 10), 3) = 0 THEN RETURN
6520 IF d(p, 3) = 0 THEN LET x = d(p, 1) + a(d(p, 10), 1) : LET y = d(p, 2) + a(d(p, 10), 2) : GO TO 6560
6530 IF d(p, 3) = 1 THEN LET x = d(p, 1) + a(d(p, 10), 2) : LET y = d(p, 2) - a(d(p, 10), 1) : GO TO 6560
6540 IF d(p, 3) = 2 THEN LET x = d(p, 1) - a(d(p, 10), 1) : LET y = d(p, 2) - a(d(p, 10), 2) : GO TO 6560
6550 LET x = d(p, 1) - a(d(p, 10), 2) : LET y = d(p, 2) + a(d(p, 10), 1) 
6560 LET s = 0
6570 PRINT AT 17, 11; INK 2; "<Combat>";
6580 FOR q = 1 TO t STEP 1
6590 IF d(q, 1) <> x OR d(q, 2) <> y THEN GO TO 6950
6600 INK u(p, 1) : GO SUB 5400 : INK 4
6610 PRINT AT 18, 11; INK u(p, 1); n$(p); INK 4; " attack "; INK u(q, 1); n$(q); INK 4; " x"; a(d(p, 10), 3);        
6620 PAPER u(p, 1)     
6630 LET s = p
6640 LET p = q
6650 GO SUB 5600
6660 LET q = p
6670 LET p = s
6680 PAPER 0              
6690 REM resolve shield based on relative positions and q dir
6700 LET tx = d(p, 1) - d(q, 1)
6710 LET ty = d(p, 2) - d(q, 2)
6720 IF tx*tx > ty*ty AND tx > 0 THEN LET s = 6 : GO TO 6760
6730 IF tx*tx > ty*ty THEN LET s = 4 : GO TO 6760
6740 IF ty > 0 THEN LET s = 5 : GO TO 6760
6750 LET s = 7
6760 LET s = s - d(q, 3)
6770 IF s > 7 THEN LET s = s - 4 : GO TO 6790
6780 IF s < 4 THEN LET s = s + 4
6790 LET tx = 19
6800 FOR i = 1 TO a(d(p, 10), 3) STEP 1
6810 IF d(q, 8) < 1 THEN GO TO 6860
6820 IF RND * 9 < 5 THEN PRINT #FN s(tx); AT FN x(tx), 11; INK 4; "MISS!"; : GO TO 6860
6830 IF d(q, s) > 0 THEN LET d(q, s) = d(q, s) - 1 : PRINT #FN s(tx); AT FN x(tx), 11; INK 4; "HIT! Shields damaged."; : GO TO 6860
6840 IF d(q, 8) > 1 THEN LET d(q, 8) = d(q, 8) - 1 : PRINT #FN s(tx); AT FN x(tx), 11; INK 4; "HIT! Hull damaged."; : GO TO 6860
6850 IF d(q, 8) = 1 THEN LET d(q, 8) = 0 : PRINT #FN s(tx); AT FN x(tx), 11; INK 4; "HIT! Ship destroyed!"; : GO SUB 5800
6860 LET tx = tx + 1
6870 NEXT i        
6880 REM refresh attacked ship
6890 LET i = p
6900 LET p = q
6910 GO SUB 5500
6920 GO SUB 4800
6930 GO SUB 5600
6940 LET p = i
6950 NEXT q
6960 IF s = 0 THEN PRINT AT 18, 11; INK u(p, 1); n$(p); INK 4; " do not attack."; : GO SUB 4800 
6970 RETURN
7500 REM end game check
7510 LET i = 0
7520 LET q = 1
7530 FOR p = 1 TO t STEP 1
7540 IF d(p, 1) > 0 THEN LET q = p : LET i = i + 1
7550 NEXT p    
7560 REM still at least 2 players
7570 IF i > 1 THEN RETURN
7580 REM ends game
7590 LET t = 0
7600 REM 1st player or winner colours
7610 LET p = q
7620 GO SUB 5200
7630 PRINT AT 17, 11; INK 2; "<GAME OVER>";
7640 IF i = 0 THEN PRINT AT 18, 11; "Everybody is dead."; : GO TO 7660
7650 PRINT AT 18, 11; INK u(p, 1); "SPACE "; n$(p); INK 4; " have won.";
7660 GO SUB 4800
7670 RETURN
8210 REM attack vectors data
8220 DATA -3, -2, 4, -3, -1, 4, -3, 0, 4
8250 DATA -3, 1, 4, -3, 2, 4, -2, -2, 1
8280 DATA -2, -1, 2, -2, 0, 2, -2, 1, 2
8310 DATA -2, 2, 1, -1, -2, 1, -1, -1, 3
8340 DATA -1, 0, 1, -1, 1, 3, -1, 2, 1
8370 DATA 0, -2, 1, 0, -1, 3, 0, 0, 0
8400 DATA 0, 1, 3, 0, 2, 1, 1, -2, 1
8430 DATA 1, -1, 3, 1, 0, 0, 1, 1, 3
8460 DATA 1, 2, 1, 2, -2, 1, 2, -1, 0
8490 DATA 2, 0, 0, 2, 1, 0, 2, 2, 1
8520 REM movement vectors data
8530 DATA -2, -1, -1, -2, -1, 0, -2, 0, 0
8560 DATA -2, 1, 0, -2, 1, 1, -1, -1, -1
8590 DATA -1, -1, 0, -1, 0, 0, -1, 1, 0
8620 DATA -1, 1, 1, 0, 0, 0, 0, 0, -1
8650 DATA 0, 0, 0, 0, 0, 1, 0, 0, 0
8680 REM player UIs data
8690 DATA 1, 5, 1, 1, 0, 0
8700 DATA 2, 4, 5, 9, 3, 3
8710 DATA 3, 2, 1, 9, 0, 3
8720 DATA 6, 3, 5, 1, 3, 0
8730 REM player names data
8740 DATA "FLEET", "ELVES", "CHAOS", "HORDE"
8750 REM player data
8760 DATA 1, 1, 2, 3, 3, 3, 3, 4, 0, 0
8770 DATA 8, 12, 0, 3, 3, 3, 3, 4, 0, 0
8780 DATA 1, 12, 2, 3, 3, 3, 3, 4, 0, 0
8790 DATA 8, 1, 0, 3, 3, 3, 3, 4, 0, 0
8800 REM UDGs data
8810 DATA 0, 3, 15, 31, 63, 63, 127, 127
8820 DATA 0, 192, 240, 248, 252, 252, 254, 254 
8830 DATA 127, 127, 63, 63, 31, 15, 3, 0 
8840 DATA 254, 254, 252, 252, 248, 240, 192, 0
8850 DATA 0, 0, 0, 0, 1, 7, 7, 15
8860 DATA 0, 0, 0, 0, 128, 224, 224, 240 
8870 DATA 15, 7, 7, 1, 0, 0, 0, 0
8880 DATA 240, 224, 224, 128, 0, 0, 0, 0
8900 DATA 0, 0, 0, 5, 15, 7, 15, 7
8910 DATA 0, 0, 0, 160, 240, 224, 240, 224
8920 DATA 7, 15, 7, 15, 5, 0, 0, 0 
8930 DATA 224, 240, 224, 240, 160, 0, 0, 0 
8940 DATA 0, 0, 0, 0, 80, 248, 240, 248 
8950 DATA 248, 240, 248, 80, 0, 0, 0, 0 
8960 DATA 0, 0, 0, 0, 10, 31, 15, 31 
8970 DATA 31, 15, 31, 10, 0, 0, 0, 0 
8980 DATA 0, 0, 0, 60, 60, 0, 0, 0 
8990 DATA 0, 0, 24, 24, 24, 24, 0, 0 
9000 DATA 0, 0, 0, 0, 24, 0, 0, 0