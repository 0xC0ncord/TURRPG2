TURRPG 2
========
TURRPG 2 is a fork of [TitanRPG](https://github.com/pdinklag/TitanRPG) for the Tony's Unreal Realm UT2k4 server.

Building
--------
TURRPG 2 uses a slightly more complex building process than typical UT2004 packages. A preprocessor is required in order to compile some classes in the project. The current build process facilitates the use of [`gpp`](https://files.nothingisreal.com/software/gpp/gpp.html) to perform the pre-processing stage. The only supported platforms for building are UNIX and UNIX-like platforms such as GNU/Linux or Mac OS X. For this reason, `ucc.exe` is currently run under Wine by the build script. Building on Windows may be possible under WSL or cygwin, but this has not been tested.

To build TURRPG 2, the following steps are necessary:
1. Clone the repository into your UT2004 installation directory (so that the TURRPG2 directory is on the same level as e.g. *System* or *Animations*).
2. Open a shell and change into the *TURRPG2* directory.
3. Run `make` or `./build.sh`

The included `Makefile` invokes the build script, `build.sh`. The build script performs the following steps:
1. Locate a *Classes.sha1sum* file in the TURRPG2 project directory if one exists, and read the contents. Inside should be a SHA1 hash.
2. Calculate a SHA1 hash of the contents of the *Classes* directory and compare it to the hash in *Classes.sha1sum*. If it matches, abort building, as the *Classes* directory is believed to not have changed since the last build. If the *Classes.sha1sum* file was not found, skip the checksum comparison.
3. Check for the existence of the *.preprocessed* file in the *Classes* directory. If it exists, abort building, as the *Classes* directory is believed to have already been pre-processed.
4. Recursively copy the *Classes* directory to *.Classes*.
5. Run `gpp` against every *.uc* file in the *Classes* directory, including the macros defined in *TURRPG2.inc* first. If this is a debug build, pre-process with the `__DEBUG__` macro defined. This will modify the source files in place.
6. Create an empty file in the *Classes* directory with the name *.preprocessed*.
7. If a *TURRPG2.u* file already exists in your UT2004 installation's *System* directory, rename it to *TURRPG2.u.bak*.
8. Run `ucc make` under `wine` with the argument `ini=../../TURRPG2/make.ini`. This performs the usual compiling phase of building Unreal packages, but using the included *make.ini* instead of the usual *UT2004.ini*. This alleviates the need to modify the `EditPackages` fields in your *UT2004.ini*.
9. If the compile process was successful, write the previously calculated SHA1 hash for the *Classes* directory to *Classes.sha1sum*.
10. If the compile process fails and a *TURRPG2.u.bak* file was just renamed, rename it back to *TURRPG2.u*.
11. Whether the compile process failed or was successful, remove the entire *Classes* directory and rename the previously copied *.Classes* directory to *Classes*. This is because this directory contains the source files as they were before the pre-processing phase.

The included `Makefile` has three defined targets:
* `compile` - Compile the project normally.
* `release` - Compile the project, but without the `__DEBUG__` macro defined. This is used to produce a build for public release.
* `clean` - Remove any existing `TURRPG2.u` and `TURRPG2.u.bak` from the UT2004 installation's *System* directory and, if a *.Classes* directory exists, remove the entire *Classes* directory and rename *.Classes* to *Classes*. This restores the project directory back to a ready to compile state.

The included build script has several arguments that can be provided:
* `-h | --help` - Show help.
* `-n | --no-restore` - When finishing building, don't restore the original *Classes* directory. This can be used to analyze the source tree after it has been pre-processed in order to find errors that may be related to pre-processing.
* `-s | --skip-preprocess` - Skip the pre-processing phase of building. Note that if this argument is used, the project may fail to compile. This argument can be used to continue the build process even if the *.preprocessed* file was created in an earlier build process that was either interrupted or had failed.
* `-r | --release` - Compile the project with the `__DEBUG__` macro disabled. This is used to produce a build for public release.

Documentation State
-------------------
There is currently no documentation for configuring TURRPG 2 and none is planned.

Credits
-------
TURRPG 2 contains code written by the following people:

* **Mysterial**
-- The creator of the original UT2004RPG. Although there is not too much left of UT2004RPG in TitanRPG internally, TitanRPG was based on UT2004RPG and still uses the original ideas.
* **TheDruidXpawX & Shantara**
-- These two are responsible for DruidsRPG, which can be considered the biggest and most influential addendum to UT2004RPG. It, too, represented a foundation of TitanRPG.
* **fluffy**
-- The first developer of TitanRPG, who created several extras for UT2004RPG and DruidsRPG for the historic TitanOnslaught VCTF RPG server.
* **Jrubzjeknf**
-- Creator of the Mantarun Assist and RPGFlags mutators. He also helped fluffy contribute several features and fixes to the early versions of TitanRPG.
* **BattleMode**
-- Owner of the BigBatteServers.com and creator of the resident UT2004RPG and DruidsRPG modifications, which would have their main features merged into TitanRPG at later point.
* **Mahalis**
-- Creator of the original Drones mutator, a modification by BattleMode of which was later merged into TitanRPG.
* **Wulff**
-- Contributor of some minor features, like the Lightning Rod being blockable using the Shield Gun.
* **Jonathan Zepp**
-- Author of GoodKarma, the core of which has been integrated to TitanRPG for future use.
* **pdinklag** aka **pd**
-- Current developer of TitanRPG, who merged the single TitanRPG packages by fluffy into one and later made TitanRPG a standalone RPG system.
* **TonyTheSlayer** aka **0xC0ncord**
-- Current developer of TURRPG 2 and owner of the Tony's Unreal Realm UT2k4 server.
