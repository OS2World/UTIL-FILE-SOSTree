/* ----------
 * chname.cmd (C) SuperOscar Softwares, Tommi Nieminen 1993.
 * ----------
 * Changes HPFS names to FAT names and vice versa. When truncating names
 * for FAT systems, long HPFS names are saved in `.LONGNAME' extended
 * attribute.
 *
 * Usage:
 *      [D:\] chname FILE ... [ /f /h /q /x /? ]
 *
 * Switches:
 *      /f      HPFS to FAT (default)
 *      /h      FAT to HPFS
 *      /q      Quiet mode: no output
 *      /x      Send output to OS2QUE instead of standard output
 *      /?      Show help page and quit.
 *
 * 20-Aug-1993  v1.0: first PD version.
 * 28-Aug-1993  v1.1: Options /q and /x implemented. Structural changes.
 * 4-Oct-1993   v1.1a: fixes in the help page and messages.
 * 5-Oct-1993   v1.1b: /f and /h cannot be used simultaneously; neither
 *              can /q and /x.
 */

"@echo off"

Parse Arg files "/"switches

Signal On Halt Name Quit

  /* Program name and version */
prgname = "ChName v1.1b"

  /* Constants */
TRUE = 1
FALSE = 0

  /* Load SysFileTree(), SysPutEA(), and SysGetEA() */
Call RxFuncAdd "SysFileTree", "RexxUtil", "SysFileTree"
Call RxFuncAdd "SysPutEA", "RexxUtil", "SysPutEA"
Call RxFuncAdd "SysGetEA", "RexxUtil", "SysGetEA"

  /* Defaults */
hpfs2fat = TRUE
verbose = 1             /* 0=quiet, 1=stdout, 2=OS2QUE */

  /* Check switches */
If switches <> "" Then Do
      /* Convert to upper case */
    switches = Translate(switches)

      /* Separators to blanks */
    switches = Translate(switches, " ", "/")

    Do i = 1 To Length(switches)
        ch = SubStr(switches, i, 1)
        Select
            When ch == " " Then
                Iterate

            When ch == "F" Then
                hpfs2fat = TRUE

            When ch == "H" Then
                hpfs2fat = FALSE

            When ch == "Q" Then
                verbose = 0

            When ch == "X" Then
                verbose = 2

            When ch == "?" Then
                Call ShowHelp

            Otherwise
                Call Error "invalid switch '"ch"' (use /? to get help)"
        End
    End
End

  /* Aha, you tried to fool me! */
If Pos("F", switches) > 0 & Pos("H", switches) > 0 Then
    Call Error "/f and /h switches cannot be used simultaneously"
If Pos("Q", switches) > 0 & Pos("X", switches) > 0 Then
    Call Error "/q and /x switches cannot be used simultaneously"

  /* If there are no file parameters, and we haven't yet encountered
   * /? switch, an error situation results.
   */
If files == "" Then
    Call Error "no files specified (use /? to get help)"

Do i = 1 To Words(files)
    mask = Word(files, i)
    flist = mask

      /* Expand wildcards if such exist */
    If Pos("?", mask) <> 0 | Pos("*", mask) <> 0 Then Do
        flist = ""
        res = SysFileTree(mask, fstem, "fo")
        Do j = 1 To fstem.0
              /* Spaces cause problems when handling the files, so we
               * change them to bars, which is an invalid character in
               * file names.
               */
            flist = flist || Translate(fstem.j, "|", " ") || " "
        End
    End

      /* Rename files */
    Do j = 1 To Words(flist)
          /* Separate one file from the list, and change bars back to
           * spaces if this was done before.
           */
        file = Translate(Word(flist, j), " ", "|")

          /* Check whether file exists */
        If Stream(file, "c", "query exists") == "" Then Do
            Say prgname": File '"file"' not found"
            Iterate
        End

          /* Compose a new name */
        If hpfs2fat == TRUE Then Do
            newname = Hpfs2Fat(file)
            If newname == file Then Iterate
              /* Save the name in EAs */
            res = SysPutEA(file, ".LONGNAME", file)
        End
        Else Do
            res = SysGetEA(file, ".LONGNAME", newname)
            If res <> 0 | newname == file | newname == "" Then Iterate
        End

          /* Show changes unless /q is specified; if /x is specified,
           * send the display to a queue.
           */
        If queout == TRUE Then
            Queue file "->" newname
        Else If quiet == FALSE Then
            Say file "->" newname

          /* Rename file */
        'ren "'file'" "'newname'" >nul'
    End
End

Quit:
    Exit 0

  /* Change HPFS names to FAT format */
Hpfs2Fat: Procedure Expose prgname
    Parse Arg pathname

    name = pathname
    path = ""

    If Pos("\", name) > 0 Then Do
        name = SubStr(name, LastPos("\", name) + 1)
        path = Left(name, LastPos("\", name))
    End

      /* Spaces to underlines */
    name = Translate(name, "_", " ")

      /* Separate name and extension */
    parts = Translate(name, " ", ".")
    namepart = Word(parts, 1)
    extpart = ""
    If Words(parts) > 1 Then
        extpart = "." || Word(parts, Words(parts))

      /* Does name already satisfy FAT file system? -- At most two dot-
       * separated parts, length of name part 1..8 chars, length of
       * extension part 1..3 chars plus the initial dot.
       */
    If Words(parts) > 2 | Length(namepart) > 8 | Length(extpart) > 4 Then Do
        namepart = DelStr(namepart, 9)
        extpart = DelStr(extpart, 5)
        result = namepart || extpart

          /* Does 'result' exist already? */
        If Stream(result, "c", "query exists") <> "" Then Do
            len = 1
            Do n = 0 While Stream(result, "c", "query exists") <> ""
                namepart = DelStr(namepart, 9 - len)
                result = namepart || Format(n, len) || extpart
                len = Length(((n + 1) * 10) % 10)
            End
        End
    End
    Else
        result = name

Return Translate(result)

ShowHelp: Procedure Expose prgname
    Say prgname "(C) SuperOscar Softwares, Tommi Nieminen 1993."
    Say
    Say "    [D:\] chname FILE ... [ /f /h /q /x /? ]"
    Say
    Say "Change long HPFS file names to FAT format or vice versa. When long"
    Say "HPFS file names are truncated to FAT format, long name is saved to"
    Say "`.LONGNAME'  extended  attribute,  and  the  resulting file can be"
    Say "copied to a FAT drive with the standard OS/2 copying commands."
    Say
    Say "With the  /h  switch,  file names formerly truncated to FAT format"
    Say "can be restored."
    Say
    Say "Switches:"
    Say "    /f  HPFS to FAT (default)"
    Say "    /h  FAT to HPFS (reversal of /f)"
    Say "    /q  Quiet mode"
    Say "    /x  Send output to OS2QUE instead of standard output"
    Say "    /?  Show this help page and quit"
Exit 0

Error: Procedure Expose prgname
    Parse Arg errormsg

    Say prgname":" errormsg
Exit 1
