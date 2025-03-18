# Chaos Mod
## Description
Adds random effects that cycle, not too many are implemented so far but intend to add more.

This mod is released under the MIT license, you can find the source code here: https://github.com/sitton76/Starship-Chaos-Mod

If you want to add effects to this feel free to open a PR for it!

## Installation
1. Download the script prerelease build here https://github.com/Net64DD/Starship/actions/runs/13895756261 (Requires a github account) and run through the typical setup.
2. Copy `chaos_mod.o2r` file to your `mods` folder
3. Enjoy!

## Known Issues:
1. DRIFT does not work correctly in all range mode.
2. INVERT does not work correctly in all range mode.
3. CHANGE turning you into the Blue Marine may cause lighting issues for the duration of the state.
4. CHANGE turning you into the Landmaster may make the Aring stuck to the ground after the effects duration in some stages.

## Version Changes:
'1.2.0': [
    Prevented CHANGE from turning the player into Blue Marine in All Range mode(prevents a softlock for the duration)
    Prevented CHANGE from turning the player into Landmaster in space levels(Landmaster would just fall into the void)
    Prevented FAST from working during boss fights in Non-All Range cases.(The player could outrun the boss)
]
