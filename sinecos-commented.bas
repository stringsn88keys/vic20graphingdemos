9 rem clear the screen
10 print chr$(147)
19 rem reserve memory above $1c00 for custom characters, then clear basic
20 poke 52,28 : poke 56,28 : clr
29 rem point the vic chip at screen ram $1e00 and char ram $1c00
30 poke 36869,255
39 rem blank out all 64 custom character definitions
40 for i=7168 to 7679 : poke i,0 : next i
44 rem blank the screen matrix too - cells outside the axes must read as
45 for i=7680 to 8185 : poke i,0 : next i
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
139 rem next free custom char - shared across both curves below
140 nc=2
149 rem step across every column, plotting sine (blue) then cosine (red)
150 for x=0 to 175
159 rem sine value for this column, scaled/shifted to pixels
160 y=oy-int(12*sin((x-ox)*.0714)) : cl=6 : gosub 900
169 rem cosine value for this column, scaled/shifted to pixels
170 y=oy-int(12*cos((x-ox)*.0714)) : cl=2 : gosub 900
179 rem loop back for the next column
180 next x
489 rem pause so the finished curves are visible for a couple of seconds
490 for d=1 to 1750 : next d
499 rem clear the screen and restore the rom character set, so a failed
500 print chr$(147) : poke 36869,240
502 rem load below prints a legible error instead of custom-charset garbage
503 load"tan",8,1
899 rem plot one point at (x,y), reusing this cell's character if already drawn
900 co=int(x/8) : ro=int(y/8)
909 rem a screen code >=3 means this cell already has a curve character
910 ch=peek(7680+ro*22+co) : if ch>=3 then 950
919 rem out of custom characters - skip this point rather than corrupt one
920 if nc>=63 then return
929 rem claim the next free custom character
930 nc=nc+1 : ch=nc
939 rem place this new character in the cell, in whichever curve's color
940 poke 7680+ro*22+co,ch : poke 38400+ro*22+co,cl
941 rem if on the axis row, carry its line into the new character
942 if ro=rh then poke 7168+ch*8+(oy and 7),255
943 rem same for the axis column
944 if co=cv then for j=0 to 7 : poke 7168+ch*8+j,peek(7168+ch*8+j) or 2^(7-(ox and 7)) : next j
949 rem set this pixel's bit without disturbing its neighbors
950 a=7168+ch*8+(y-ro*8) : poke a,peek(a) or 2^(7-(x-co*8))
959 rem back to whichever curve called this
960 return
