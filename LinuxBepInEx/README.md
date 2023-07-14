# Introduction
**This is a guide for installing and using mods on Linux systems via Proton for ![Timberborn logo](https://raw.githubusercontent.com/GinFuyou/Timberborn-GinFuyou/main/LinuxBepInEx/illustrations/Timberborn20x.webp "Timberborn") [Timberborn](https://store.steampowered.com/app/1062090/Timberborn/ "Game Steam store page")** 

BepInEx

> NOTE: It used to be a guide for a *script* that was needed, but it apparently not required anymore. Ignore script section until you can't get it to work with prior steps.

It is compilation of instructions found on different sources and for various Games adapted for **Timberborn** with own experience.

Using proton presumes you will be running game via Steam, but technically there should be no difference if you run it via proton directly, but this is not covered by this document.

## IMPORTANT
We are running game through *proton* Windows compatibility layer, so we are running <ins>Windows version</ins> of the game and <ins>Windows version</ins> of BepInEx, don't confuse with running modded Linux-native game.

# Requirements to run mods
To have game starting with active mods you need **winhttp.dll**

*Original instruction is here*: https://github.com/BepInEx/BepInEx/issues/110

## Installing requirements

1. Install **winetricks**, it should be provided by your package manager. (required for protontricks to work, [about it](https://wiki.winehq.org/Winetricks))  
   Make sure it's up-to-date if already installed.  
For different distributions \ package managers (you need to pick one you are using):
- Manjaro: `pamac install winetricks`
- Ubuntu: `sudo apt-get install winetricks`


2. Install **protontricks** ([about it](https://github.com/Sirmentio/protontricks))

```sh
sudo pip install -U protontricks
```
> if `pip` is not found use `pip3`, if you have neither install `python-pip` or follow original instructions.  
> You should be using python 3.x, python 2.x is outdated, but distribution can have both and commands aliased differently.  
> Pip complaining about running with sudo is giving a *generally* good advice, but it's not critical for us, and might be tricky to use, just ignore it in this case.
3. In terminal, run following command (and ignore error messages)
```sh
protontricks --gui
```
> I have no idea what error original instruction meant, it may give some warning about missing environmental variables but says it is using defaults so it's fine, or about using 64bit WINEPREFIX, or outdated winetricks - neither should be critical.
  
> Note from https://docs.bepinex.dev/articles/advanced/proton_wine.html (they use winecfg, both methods should work)  
> "If you have a Steam Deck, the protontricks --gui command most likely won't work. Instead, you need to install protontricks via discovery store, and then launch it via the Steam search bar. Launching it via discovery store won't work."
4. Check Select Timberborn in App list
5. In the GUI, choose "Select the default Wine prefix" 
> The title of following window should have "current prefix is <path to compatdata/1062090/pfx>" - 1062090 is Timberborn app id on Steam.
6. Choose "Install a Windows DLL or component"
7. Scroll down and check **"winhttp"** then click OK
> When it finishes you'll be back to original window, just close it.

You are ready to add BepinEx and mods!

## Known issues
- [Object has no attribute 'group' error](#protontricks-fails-with-object-has-no-attribute-group-error)
- [Can't load winhttp.dll](#cant-load-winhttpdll)
- [Winhttp.dll not created](#protontricks-runs-but-doesnt-create-winhttpdll-in-the-game-dir)
- [No module named protontricks](#protontricks-fails-with-no-module-named-protontricks-error)
- [Protontricks doesn't list Timberborn](#protontricks---gui-doesnt-list-timberborn)
- [Wrong ELF class](#wrong-elf-class-errors-during-start)

---

#### Protontricks fails with object has no attribute 'group' error:
```pycon
Traceback (most recent call last):
  File "/usr/bin/protontricks", line 309, in <module>
    steam_lib_dirs = get_steam_lib_dirs(steam_dir)
  File "/usr/bin/protontricks", line 223, in get_steam_lib_dirs
    library_folders = parse_library_folders(f.read())
  File "/usr/bin/protontricks", line 196, in parse_library_folders
    key, value = match.group(1), match.group(2)
AttributeError: 'NoneType' object has no attribute 'group'
```
Caused by outdated version of protontricks, force-update it, for example with command from above.

---

#### Can't load **winhttp.dll**

_Prepend_ this to game's Steam launch options
```sh
WINEDLLOVERRIDES="winhttp=n,b"
```
*Taken from https://github.com/ebkr/r2modmanPlus/pull/350*

---

#### Protontricks runs but doesn't create winhttp.dll in the game dir
> this issue is not well studied

Some reports say that it may be caused by permissions issue.

One can try deleting **winhttp.dll** in your proton prefix (prefixes are located in your steam library `Steam/steamapps/compatdata/` file under it in `windows/syswow64/`) and re-trying running protontricks step again

Some more studies shows that steam dir where real file (not a symlink) is placed can have no write (w) permissions for owner.
Inside *your* steam library
```sh
ls -l steamapps/compatdata/1062090/pfx/dosdevices/c:/windows/syswow64/ | grep winhttp                                            ✔
lrwxrwxrwx 1 gin gin      99 sep 24 16:56 winhttp.dll -> /<your steam lib>/steamapps/common/Proton - Experimental/files/lib/wine/i386-windows/winhttp.dll
```
This shows file on this location is actually a link, copy the full path on the right without the file name. `<your steam lib>` will be your actual steam library path, replace it with it in commands beneath. Proton version will also depend on one you've using to launch the game (set in Steam game's properties)
> Don't forget to wrap paths that have spaces (proton path do) in `""`
```sh
ls -la '/<your steam lib>/steamapps/common/Proton - Experimental/files/lib/wine/i386-windows/' | grep winhttp                                      ✔
-rw-r--r-- 1 gin gin   310784 jun 19  2003 winhttp.dll
```
If you don't see "w" in this part "-r**w**-r--r--" - it's missing write permissions. I've changed permissions recursively on whole dir:
```sh
 chmod u+w -R "/<your steam lib>/steamapps/common/Proton - Experimental/"
```
Then re-try protontricks step.

> "**prefix**" is environment used for Windows compatibility for Wine \ Proton. Basically it's directory that contains configurations, libraries and folders emulating Windows typical structure. e.g. it's location *may* look like:
```
/home/<your_user>/.local/share/Steam/steamapps/compatdata/1062090/pfx/drive_c/
```
> Proton can have multiple prefixes for different games, you can know which prefix the game is using by searching for "Timberborn" in `compatdata/`. It will likely be in Steam library where Timberborn itself is installed.

---

#### Protontricks fails with "no module named protontricks" error
```pycon
Traceback (most recent call last):

File "/<...>/bin/protontricks", line 5, in <module>

from protontricks.cli import main

ModuleNotFoundError: No module named 'protontricks'
```
This appears that protontricks is not installed properly.  
Try first force-reinstall with pip.  
```sh
sudo pip install -U --force-reinstall protontricks
```

If it doesn't help - some suggest using **pipx** instead.
> **pipx** is just a wrapper around **pip** that uses isolated environment for installs, but perhaps it could bystep some problems base pip may have on your system

1. install **pipx** ([official guide](https://github.com/pypa/pipx#install-pipx))
```sh
pip install --user pipx
```
2. make **pipx** ensure that terminal is configured correctly for usage (PATH env var)
```sh
pipx ensurepath
```
3. install **protontricks** with **pipx** now.
```sh
pipx install protontricks
``` 
> Note that neither command using `sudo` (executing command as priviledged user) `--user` will install into your (current user) home folder, then **pipx** will also use dir inside home. Use this if you don't want or can't use root (sudo).

---

#### Protontricks --gui doesn't list Timberborn
You need to lanch Timberborn once so it will create a prefix dir. It probably doesn't even need to be succesfully finish starting.

---

#### "Wrong ELF class" errors during start
You might be getting errors like:
```
ERROR: ld.so: object '<...>/Steam/ubuntu12_32/gameoverlayrenderer.so' from LD_PRELOAD cannot be preloaded (wrong ELF class: ELFCLASS32): ignored.
```
It's not necessary a problem preventing starting game or loading mods.

I have a guess it's caused by Proton apparently using 64-bit prefixes and failing to load some 32-bit utils. Further insight on it is welcome.

# How to use the SCRIPT
> Depricated, try only if prior steps didn't work on themselves.

DISCLAIMER: I'm a python coder, sh/bash scripting looks like Chinese to me, still I think I've changed it to something more reasonable, but don't take my word for it, and use on your own risk.

Be warned, these are by no means well-tested, if you find mistakes or problems on other configs (I'm running Manjaro here), please post an issue.

## Using the start script itself
*By "this file" I'm referring to `timberborn_linux_bepinex.sh`*

1. Prerequirements must be fulfilled
2. Place this file in your game's dir (along with Timberborn.exe)
3. Make this script executable with ```chmod u+x timberborn_linux_bepinex.sh```
>  you must be in the game dir, otherwise use absolute path
4. In Steam, go in Steam Library -> (Game) Properties -> General -> Launch Options. Change it to:
```
./timberborn_linux_bepinex.sh %command% > ~/timberborn.log 2>&1
```
>   `> ~/timberborn.log 2>&1` part will redirect output to your home dir's timberborn.log
 it's only needed for debuging, you can remove it

5. Start the game via Steam (it may not launch from console)
---
You know BepInEx is running if you see it's console window before the game starts (it will stay in the background while game is running)

![Console window](https://raw.githubusercontent.com/GinFuyou/Timberborn-GinFuyou/main/LinuxBepInEx/illustrations/BepInEx_console.png "BepInEx Console")

> It might have important or not that much warnings, note them if you have problems.
