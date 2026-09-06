10 print chr$(147)
20 poke 52,28 : poke 56,28 : clr
30 poke 36869,255
40 for i=7168 to 7679 : poke i,0 : next i
45 for i=7680 to 8185 : poke i,0 : next i
50 ox=88 : oy=92 : rh=int(oy/8) : cv=int(ox/8)
60 poke 7168+(oy and 7),255
70 for j=0 to 7 : poke 7176+j,2^(7-(ox and 7)) : next j
80 for j=0 to 7 : poke 7184+j,2^(7-(ox and 7)) : next j
90 poke 7184+(oy and 7),255
100 for co=0 to 21 : poke 7680+rh*22+co,0 : poke 38400+rh*22+co,6 : next co
110 for ro=0 to 22 : poke 7680+ro*22+cv,1 : poke 38400+ro*22+cv,6 : next ro
120 poke 7680+rh*22+cv,2 : poke 38400+rh*22+cv,6
140 nc=2
150 for x=0 to 175
160 y=oy-int(12*sin((x-ox)*.0714)) : cl=6 : gosub 900
170 y=oy-int(12*cos((x-ox)*.0714)) : cl=2 : gosub 900
180 next x
490 for d=1 to 1750 : next d
500 print chr$(147) : poke 36869,240
503 load"tan",8,1
899 rem plot one point at (x,y), reusing this cell's character if already drawn
900 co=int(x/8) : ro=int(y/8)
910 ch=peek(7680+ro*22+co) : if ch>=3 then 950
920 if nc>=63 then return
930 nc=nc+1 : ch=nc
940 poke 7680+ro*22+co,ch : poke 38400+ro*22+co,cl
942 if ro=rh then poke 7168+ch*8+(oy and 7),255
944 if co=cv then for j=0 to 7 : poke 7168+ch*8+j,peek(7168+ch*8+j) or 2^(7-(ox and 7)) : next j
950 a=7168+ch*8+(y-ro*8) : poke a,peek(a) or 2^(7-(x-co*8))
960 return
