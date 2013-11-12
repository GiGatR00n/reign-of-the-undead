::******************************************************************************
::     Reign of the Undead, v2.x
::
::     Copyright (c) 2010-2013 Reign of the Undead Team.
::     See AUTHORS.txt for a listing.
::
::     Permission is hereby granted, free of charge, to any person obtaining a copy
::     of this software and associated documentation files (the "Software"), to
::     deal in the Software without restriction, including without limitation the
::     rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
::     sell copies of the Software, and to permit persons to whom the Software is
::     furnished to do so, subject to the following conditions:
::
::     The above copyright notice and this permission notice shall be included in
::     all copies or substantial portions of the Software.
::
::     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
::     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
::     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
::     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
::     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
::     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
::     SOFTWARE.
::
::     The contents of the end-game credits must be kept, and no modification of its
::     appearance may have the effect of failing to give credit to the Reign of the
::     Undead creators.
::
::     Some assets in this mod are owned by Activision/Infinity Ward, so any use of
::     Reign of the Undead must also comply with Activision/Infinity Ward's modtools
::     EULA.
::******************************************************************************

:: Depends on: being run from the mods\rotudev folder

:: Supress output
@echo off
:: Ensure the correct current working directory gets set
cd ..\..\

:: Connect to the server
::   fs_game sets the name of the mod run
::   connect contains the IPv4 address the server is listening on
iw3mp.exe +set fs_game "mods\rotudev" +connect 192.168.1.11

:: If we were run from the command line, change back to original folder, so we
:: are ready to be run again
cd mods\rotudev
