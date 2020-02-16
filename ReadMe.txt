ReadMe.1st for SOS utilities 1.2 =====================================

Author:         Tommi Nieminen 20-Oct-1993
Internet:       Tommi.Nieminen@uta.fi (preferred)
                sktoni@kielo.uta.fi
Snail mail:     Tommi Nieminen
                Pajulankatu 8
                37150 NOKIA
                FINLAND

This package (sosutl12) should contain the following files:

    ReadMe.1st              This file
    License                 GNU General Public License (version 1.0);
                            see `Copyrights' section below

    bin\                    Executable files
    sostree.exe             SOS Tree directory tree drawer
    sostree_catala.exe      Catalan SOS Tree
    sostree_espanol.exe     Spanish SOS Tree
    sostree_suomi.exe       Finnish SOS Tree
    chname.cmd              Changes HPFS names to FAT format and vice
                            versa
    extract.cmd             Extract files from / List contents of
                            archives
    filefind.cmd            File finder
    kill.cmd                Kill processes by their PIDs
    ps.cmd                  Process Status simplifier utility

    doc\                    Documentation (including manual pages)
    sosutil.inf             Info file for all the programs
    sosutil.texi            Texinfo document file for all the programs
    sostree.man
    chname.man
    extract.man
    filefind.man
    kill.man
    ps.man

    src\                    C sources for SOS Tree
    sostree.c
    msg_catalan.inc         Catalan messages by Xavier Caballe
    msg_english.inc         English messages
    msg_espanol.inc         Spanish messages by Xavier Caballe
    msg_suomi.inc           Finnish messages

All these programs are public domain.

Thanks for Xavier Caballe, who translated SOS Tree messages to
Spanish and Catalan.

texi2ipf was used in creating `sosutil.inf' from `sosutil.texi'.
Thanks for Beverly A. Erlebacher and Marcus Groeber, who wrote that
utility! I am also very grateful for the excellent text window cut
and paste utility TWCP by Maurizio Sartori Masar (Masar Software
Ltd).

Notes ----------------------------------------------------------------

I'd be happy to obtain versions of these programs in different
languages. If you are able to translate the program messages, please
send the modified sources to me so that I can include them in an
update package of SOS Utilities. NOTE: EVEN IF YOU DON'T HAVE ACCESS
TO BORLAND C++ COMPILER you still can translate the messages in the
source files, and then send the sources to me. I'll distribute the
recompiled programs further. Currently available languages are
Catalan, English, Finnish, and Spanish.

The Texinfo document file, `sosutil.texi', is formatted for A4 sheets.
If you are using another paper size, remove the command `@afourpaper'
between the `@iftex' and `@end iftex' statements near the beginning
of the document.

Bug Notes ------------------------------------------------------------

1. FileFind

In SOS Utilities version 1.0, FileFind had a serious bug that caused
strange problems when the script was run (for me, anyway). The buggy
script loads the two RexxUtil functions, SysFileTree() and SysIni with
the following Calls:

    Call RxFuncAdd "SysFileTree", "RexxUtil", "SysFileTree"
    Call RxFuncAdd "SysIni", "RexxUtil", "SysFileTree"

The latter should of course be:

    Call RxFuncAdd "SysIni", "RexxUtil", "SysIni"

This seems not to disturb SysFileTree(), but SysIni() may return
strange results...

Also, in the previous versions of this `ReadMe.1st' file, FileFind is
for several times referred to as `FindFile' :-)  probably because my
own, personalized version of the program is named `Kussa' (which is a
non-existent but linguistically possible way of saying `where' in
Finnish).

2. ps

In `ps.cmd' of SOS Utilities version 1.1--ie. in the REXX script, not
the earlier Perl script--the input filter worked incorrectly. The
script filters out all input lines that (a) do not have exactly eight
`words' (ie. eight blank-separated character strings), (b) do not
begin with a number. The latter condition filters out all header lines
and is necessary, but the trouble was that PSTAT outputs numbers in
hex, and the filtering function only lets through decimals. Later in
the script, however, the values were converted from hexadecimal to
decimal correctly.

To be more specific, the following `context matching' line in the
script was incorrect:

    If Words(line) == 8 & DataType(Word(line, 1)) == "NUM" Then Do

It really should have read:

    If Words(line) == 8 & DataType(Word(line, 1), "X") == 1 Then Do

SOS Utilities version 1.2 contains the correct version, of course.

Copyrights -----------------------------------------------------------

SOS Tree v1.0a  directory drawer
ChName v1.1b    change names to/from FAT format
Extract v1.1    archive extractor/lister
FindFile v1.4a  file finder
ps v4.0a        PSTAT output simplifier
Copyright (C) 1993, SuperOscar Softwares, Tommi Nieminen.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

End of ReadMe.1st ===================================================
