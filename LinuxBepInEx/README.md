**This is edited script for running [BepInEx](https://github.com/BepInEx/BepInEx) for ![Timberborn logo](https://raw.githubusercontent.com/GinFuyou/Timberborn-GinFuyou/main/LinuxBepInEx/illustrations/Timberborn20x.webp "Timberborn") Timberborn under Linux**


# How to use
This is compilation of instructions found on different sources and for various Games adapted for **Timberborn** with own experience.

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

## Prerequirements
To have game starting with active mods you need **winhttp.dll**

*Original instruction is here*: https://github.com/BepInEx/BepInEx/issues/110

My moddified instruction:

1. Install Protontricks https://github.com/Sirmentio/protontricks (requires Winetricks https://wiki.winehq.org/Winetricks)

```sh
sudo pip install -U protontricks
```
> if `pip` is not found use `pip3`, if you have neither install `python-pip` or follow original instructions
> You should be using python 3.x, python 2.x is outdated, but distribution can have both and commands aliased differently
2. In terminal, run "protontricks  --gui" (and ignore the error msg)
> I have no idea what error original instruction meant, it may give some warning about missing environmental variables but says it is using defaults so it's fine
3. Select Timberborn in App list
4. In the GUI, choose "Select the default Wine prefix"
5. Choose "Install a Windows DLL or component"
6. Scroll down and check "winhttp" then click OK

### Known issues
- #### protontricks fails with following error:
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

- #### Can't load **winhttp.dll**
_Prepend_ this to game's Steam launch options
```sh
WINEDLLOVERRIDES="winhttp=n,b"
```
*Taken from https://github.com/ebkr/r2modmanPlus/pull/350*

- #### protontricks runs but doesn't create winhttp.dll in the game dir
> this issue is not well studied

Some reports say that it may be caused by permissions issue.

One can try deleting **winhttp.dll** in your proton prefix (prefixes are located in your steam library `Steam/steamapps/compatdata/` file under it in `windows/syswow64/`) and re-trying running protontricks step again

> "**prefix**" is environment used for Windows compatibility for Wine \ Proton. Basically it's directory that contains configurations, libraries and folders emulating Windows typical structure. e.g. it's location *may* look like:
```
/home/<your_user>/.local/share/Steam/steamapps/compatdata/1062090/pfx/drive_c/
```
> Proton can have multiple prefixes for different games, you can know which prefix the game is using by searching for "Timberborn" in `compatdata/`. It will likely be in Steam library where Timberborn itself is installed.
