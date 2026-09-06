9 rem clear the screen
10 print chr$(147)
19 rem reserve memory above $1c00 for custom characters, then clear basic
20 poke 52,28 : poke 56,28 : clr
29 rem point the vic chip at screen ram $1e00 and char ram $1c00
30 poke 36869,255
39 rem blank out all 64 custom character definitions
40 for i=7168 to 7679 : poke i,0 : next i
49 rem origin pixel and its character row/column
50 ox=88 : oy=92 : rh=int(oy/8) : cv=int(ox/8)
59 rem draw the origin's horizontal axis row into char 0
60 poke 7168+(oy and 7),255
69 rem draw the origin's vertical axis column into char 1
70 for j=0 to 7 : poke 7176+j,2^(7-(ox and 7)) : next j
79 rem copy that same vertical line into char 2 (the origin cell)
80 for j=0 to 7 : poke 7184+j,2^(7-(ox and 7)) : next j
89 rem add the horizontal line into char 2 as well
90 poke 7184+(oy and 7),255
99 rem fill the x-axis row with char 0, colored blue
100 for co=0 to 21 : poke 7680+rh*22+co,0 : poke 38400+rh*22+co,6 : next co
109 rem fill the y-axis column with char 1, colored blue
110 for ro=0 to 22 : poke 7680+ro*22+cv,1 : poke 38400+ro*22+cv,6 : next ro
119 rem place the origin's crosshair character
120 poke 7680+rh*22+cv,2 : poke 38400+rh*22+cv,6
129 rem next free custom char, and no cell touched yet
130 nc=2 : cc=-1 : cr=-1
139 rem step across every column of the screen
140 for x=0 to 175
149 rem tangent value for this column, before clamping
150 t=tan((x-ox)*.0714)
154 rem tan runs off to infinity near its asymptotes - clamp the top...
155 if t>6 then t=6
157 rem ...and the bottom, so a couple of columns near each asymptote
158 if t<-6 then t=-6
159 rem scale/shift the clamped value to a screen pixel
160 y=oy-int(15*t)
169 rem which character cell this pixel falls in
170 co=int(x/8) : ro=int(y/8)
179 rem same cell as last time - reuse its character, skip allocating
180 if co=cc and ro=cr then 210
189 rem otherwise claim the next free custom character (max 63)
190 if nc<63 then nc=nc+1
199 rem place this new character in the cell, colored yellow
200 cc=co : cr=ro : ch=nc : poke 7680+ro*22+co,ch : poke 38400+ro*22+co,7
204 rem if on the axis row, carry its line into the new character
205 if ro=rh then poke 7168+ch*8+(oy and 7),255
207 rem same for the axis column
208 if co=cv then for j=0 to 7 : poke 7168+ch*8+j,peek(7168+ch*8+j) or 2^(7-(ox and 7)) : next j
209 rem this character's byte for the pixel's row within the cell
210 a=7168+ch*8+(y-ro*8)
219 rem set that pixel's bit without disturbing its neighbors
220 poke a,peek(a) or 2^(7-(x-co*8))
229 rem loop back for the next column
230 next x
233 rem pause so the finished curve is visible for a couple of seconds
234 for d=1 to 1750 : next d
239 rem clear the screen and restore the rom character set, so a failed
240 print chr$(147) : poke 36869,240
242 rem load below prints a legible error instead of custom-charset garbage
243 load"unitcircle",8,1
