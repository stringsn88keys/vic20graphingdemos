# Repo notes for Claude

## The demo reel

sine -> cos -> sinecos -> tan -> unitcircle -> sine (loops forever). Each
listing ends by executing `LOAD"<next-name>",8,1` - executing `LOAD` from a
*running* BASIC program (as opposed to typing it at the READY prompt)
auto-RUNs whatever it just loaded, so the reel plays continuously and never
holds more than one demo's code in the VIC-20's memory at a time.
`Run-GraphingDemos.ps1` tokenizes the whole chain into one work directory
mounted as VICE's device #8 filesystem, then types just the first
`LOAD"sine",8,1` + `RUN` to kick it off - see the script's own comments for
the exact VICE flags that make chain-loading from a plain directory work
(`-fs8` alone isn't enough; `-trapdevice8` is the one that's easy to miss).
`-keybuf`-typed boot occasionally fails to type the `RUN` (a VICE keybuf
timing quirk, confirmed live) - if the emulator just sits at READY. after
the LOAD, type `RUN` yourself once, or relaunch the script.

Before each chain-load, a listing pauses (~2s, a calibrated `FOR/NEXT` delay
- see below for why not `TI`), then clears the screen and restores the ROM
character set (`POKE 36869,240`) before the `LOAD`. That way a failed LOAD
prints its error legibly instead of through the graph's blanked custom
character set.

Two VICE/KERNAL quirks to know about if you touch this chain (both
confirmed live, root-caused the hard way):

- **Don't busy-wait on `TI`.** `T0=TI` followed by `IF TI<T0+120 THEN <line>`
  (looping back to itself or via a second line) hangs the machine *only*
  when the program also POKEs `36869` (the char-set register) somewhere
  before a subsequent `LOAD`. A plain `FOR D=1 TO n : NEXT D` delay doesn't
  have this problem - that's why the pause is written that way. `n=1750` is
  calibrated for roughly 2 seconds; if you change what runs before the
  pause, recalibrate by timing `FOR D=1 TO 5000:NEXT D` against `TI`.
- **Chain-loading gets less reliable the deeper into the session you go,
  and worse for bigger targets - this is not fully solved.** Confirmed
  live, repeatedly, with a real `.d64` image and true drive emulation too
  (rules out the fs8/`-trapdevice8` fast-load path as the cause):
  - A trivial (~50 byte) target loads fine no matter how many chain-loads
    preceded it - tested up to 5 deep (sine->cos->sinecos->tan->trivial).
  - A normal-sized demo (~1000+ bytes) as the *5th* load in the session
    (sine->cos->sinecos->tan->unitcircle) reliably produces
    `?SYNTAX ERROR` in the *loading* program's own `LOAD` line (not the
    target's code at all - confirmed by swapping the target's content
    with no effect on the failure) - or the same failure with no visible
    error, depending on whether the screen happens to be in legible ROM
    charset or the graph's blanked custom charset at the time.
  - Earlier in the session (2-4 loads deep) this same target size is
    usually fine, which is what made this look like a predecessor-size or
    padding problem for a long time - REM padding on `cos.bas`,
    `tan.bas`, and `unitcircle.bas` was added and removed more than once
    chasing that theory, sometimes appearing to fix things, sometimes
    appearing to break them, without a config that reliably survives a
    full 5-deep run. Current state: `sine.bas` carries a small two-line
    pad (confirmed needed - without it, being smaller than `cos.bas`
    breaks the very first link); the other four carry none. Don't trust
    that this is the final answer - verify live after any change, all the
    way through at least one full loop of the reel, not just the first
    couple of links.
  - Working theory: some VICE-side resource (not file-content-specific)
    degrades with each chain-load in a session, shrinking how big a
    target it can reliably load. Not confirmed. If you pick this back up,
    a real fix probably means either finding VICE's actual limit (test a
    range of target sizes at a fixed, deep chain position) or giving up on
    unbounded chain-load depth - e.g. having the reel re-boot from a known
    -autostart entry point every full loop instead of chaining forever.
- **Keep individual BASIC lines short.** A single REM line north of ~250
  characters caused a listing to silently hang on boot even with no
  chain-load involved - split long comments across multiple short lines.

## Commented companions for BASIC listings

Every `*.bas` listing here gets a sibling `{name}-commented.bas`. Keep it in
sync whenever the original changes:

- Same code, unchanged, at the same line numbers where that's possible.
- Before each code line, insert a `REM` line explaining what it does, numbered
  `{that line's number} - 1` (code at `150` gets its `REM` at `149`).
- If two consecutive code lines are numbered less than 2 apart (no room for
  the `-1` line), renumber the later ones to open a gap first - check that
  nothing (`GOTO`/`GOSUB`/`THEN`) jumps to the line number you're moving
  before renumbering it. This is allowed to diverge from the plain file's
  own numbering; nothing links the two files' line numbers together.
- Comments explain *purpose*, not syntax - what the line accomplishes in the
  program, not a restatement of the BASIC keywords already on it.
- The trailing `LOAD"<next>",8,1` chain-load line still gets a REM like any
  other code line.

The commented copy roughly doubles program size, which busts the unexpanded
VIC-20's ~3583-byte BASIC workspace. `Run-GraphingDemos.ps1 -Commented`
handles this automatically: it tokenizes with petcat's load address at
`$0401` instead of `$1001` and adds VICE's `-memory 3k` expander so the
bigger listings fit - the same trick vice-background-creator's
`New-ViceScreenshot.ps1` uses for the same reason.
