10 print chr$(147)
11 rem this file is padded - being much smaller than sinecos.bas broke the
12 rem chain-load into it (confirmed live, see claude.md)
20 poke 52,28 : poke 56,28 : clr
30 poke 36869,255
40 for i=7168 to 7679 : poke i,0 : next i
50 ox=88 : oy=92 : rh=int(oy/8) : cv=int(ox/8)
60 poke 7168+(oy and 7),255
70 for j=0 to 7 : poke 7176+j,2^(7-(ox and 7)) : next j
80 for j=0 to 7 : poke 7184+j,2^(7-(ox and 7)) : next j
90 poke 7184+(oy and 7),255
100 for co=0 to 21 : poke 7680+rh*22+co,0 : poke 38400+rh*22+co,6 : next co
110 for ro=0 to 22 : poke 7680+ro*22+cv,1 : poke 38400+ro*22+cv,6 : next ro
120 poke 7680+rh*22+cv,2 : poke 38400+rh*22+cv,6
130 nc=2 : cc=-1 : cr=-1
140 for x=0 to 175
150 t=tan((x-ox)*.0714)
151 if t>6 then t=6
152 if t<-6 then t=-6
160 y=oy-int(15*t)
170 co=int(x/8) : ro=int(y/8)
180 if co=cc and ro=cr then 210
190 if nc<63 then nc=nc+1
200 cc=co : cr=ro : ch=nc : poke 7680+ro*22+co,ch : poke 38400+ro*22+co,7
201 if ro=rh then poke 7168+ch*8+(oy and 7),255
202 if co=cv then for j=0 to 7 : poke 7168+ch*8+j,peek(7168+ch*8+j) or 2^(7-(ox and 7)) : next j
210 a=7168+ch*8+(y-ro*8)
220 poke a,peek(a) or 2^(7-(x-co*8))
230 next x
234 for d=1 to 1750 : next d
240 print chr$(147) : poke 36869,240
243 load"unitcircle",8,1
