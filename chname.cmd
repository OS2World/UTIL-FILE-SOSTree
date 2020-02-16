/* ----------
 * chname.cmd (C) SuperOscar Softwares, Tommi Nieminen 1993.
 * ----------
 * Changes HPFS names to FAT names and vice versa. When truncating names
 * for FAT systems, long HPFS names are saved in `.LONGNAME' extended
 * attribute.
 *
 * Usage:
 *      [D:\] chname FILE ... [ /f /h /q ]
 *
 * Switches:
 *      /f  HPFS to FAT (default)
 *      /h  FAT to HPFS
 *      /q  quiet mode
 *
 * 20-Aug-1993  v1.0: first PD version.
 */

"@echo off"

Parse Arg files "/"switches

Signal On Halt Name Quit

  /* Program name and version */
program_name = "ChName v1.0"

  /* Constants */
TRUE = 1
FALSE = 0

  /* Load SysFileTree(), SysPutEA(), and SysGetEA() */
Call RxFuncAdd "SysFileTree", "RexxUtil", "SysFileTree"
Call RxFuncAdd "SysPutEA", "RexxUtil", "SysPutEA"
Call RxFuncAdd "SysGetEA", "RexxUtil", "SysGetEA"

  /* Defaults */
hpfs2fat = TRUE
quiet = FALSE

  /* Check switches */
If switches <> "" Then Do
    switches = Translate(switches, " ", "/")
    Do i = 1 To Length(switches)
        ch = Translate(SubStr(switches, i, 1))
        Select
            When ch == " " | ch == "/" Then Iterate
            When ch == "F" Then Iterate
            When ch == "H" Then hpfs2fat = FALSE
            When ch == "Q" Then quiet = TRUE
            When ch == "?" Then Call ShowHelp
            Otherwise Call Error "invalid switch '"ch"' (use /? for help)"
        End
    End
End

  /* If there are no file parameters, and we haven't yet encountered
   * /? switch, an error situation results.
   */
If files == "" Then Call Error "no files specified"

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
            Say program_name": File '"file"' not found"
            Iterate
        End

        If hpfs2fat == TRUE Then Do
            newname = Hpfs2Fat(file)
            If file <> newname Then Do
                Say file "->" newname
                'ren "'file'"' newname '>nul'
                res = SysPutEA(newname, ".LONGNAME", file)
            End
        End
        Else Do
            res = SysGetEA(file, ".LONGNAME", "newname")
            If res == 0 & newname <> "" & file <> newname Then Do
                Say file "->" newname
                'ren' file '"'newname'" >nul'
            End
        End
    End

End

Quit:
    Exit 0

  /* Change HPFS names to FAT format */
Hpfs2Fat: Procedure Expose program_name
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

ShowHelp: Procedure Expose program_name
    Say program_name "(C) SuperOscar Softwares, Tommi Nieminen 1993."
    Say
    Say "    [D:\] chname FILE ... [ /f /h /q ]"
    Say
    Say "Change long HPFS file names to FAT format or vice versa. When long"
    Say "HPFS file names are truncated to FAT format, long name is saved to"
    Say "`.LONGNAME'  extended  attribute,  and  the  resulting file can be"
    Say "copied to a FAT drive with the standard OS/2 copying commands."
    Say
    Say "With the /h switch,  file names formerly truncated formerly to FAT"
    Say "format can be restored."
    Say
    Say "Switches:"
    Say "    /f  HPFS to FAT (default)"
    Say "    /h  FAT to HPFS (reversal of /f)"
    Say "    /q  Quiet mode"
Exit 0

Error: Procedure Expose program_name
    Parse Arg errormsg

    Say program_name":" errormsg
Exit 1
