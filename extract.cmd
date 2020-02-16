/* -------
 * Extract (C) SuperOscar Softwares, Tommi Nieminen 1991-93.
 * -------
 * Extracts files from archives. Usage:
 *
 *      [D:\] extract ARCHIVE [ FILE ... ] [ /jlp? /t DIR ]
 *
 * NOTE: if /l or /p switch is used, no other switch (well, I allowed
 * /? because help is always needed...) can be used at the same time
 * due to the semantics of these switches: if you're /Listing contents,
 * it makes no sense /Piping files, or /Junking them, or /Targeting
 * them to another directory, etc.
 *
 * 16-Aug-1993  v1.0: first PD version, based on private version 2.8.
 *              Supported archivers: Zip (.zip), Lh2 (.lzh), Zoo (.zoo),
 *              gzip (.gz), Compress (.Z), tar (.tar), UNARJ (.arj).
 */

"@echo off"

Parse Arg name files "/"switches

  /* Program name and version for messages */
program_name = "Extract v1.0"

  /* Symbolic constants */
TRUE = 1
FALSE = 0

  /* Defaults */
contents = FALSE        /* Display just contents? */
paths = TRUE            /* Extract directory structure? */
pipe_output = FALSE     /* Pipe output to CON? */
target_dir = "."        /* Target directory */

  /* Load SysGetKey() function */
Call RxFuncAdd "SysGetKey", "RexxUtil", "SysGetKey"

Do i = 1 To Length(switches)
    ch = Translate(SubStr(switches, i, 1))
    Select
          /* Ignore separators */
        When ch == " " | ch == "/" Then
            Iterate

          /* /j: junk directories */
        When ch == "J" Then
            paths = FALSE

          /* /l: look at contents */
        When ch == "L" Then Do
            If Verify(switches, "Ll?") <> 0 Then
                Call Error "/l can't be used together with /j, /p or /t!"
            contents = TRUE
        End

          /* /p: pipe output to standard output */
        When ch == "P" Then Do
            If Verify(switches, "Pp?") <> 0 Then
                Call Error "/p can't be used together with /j, /l or /t!"
            pipe_output = TRUE
        End

          /* /t: give target directory */
        When ch == "T" Then Do
            end = SubStr(switches, i + 1)

              /* Are there switches yet? */
            If Pos("/", end) == 0 Then Do
                target_dir = Strip(end)
                  /* Switches exhausted */
                Leave
            End
            Else Do
                target_dir = Strip(Left(end, Pos("/", end) - 1))
                  /* Move pointer to the next switch char */
                i = Pos("/", end)
            End
        End

          /* /?: help request */
        When ch == "?" Then
            Call Help

        Otherwise
            Call Error "unknown switch '"ch"'"
    End
End

  /* No parameters */
If name == "" Then
    Call Error "no parameters (use /? to get help)"

  /* Get full path name for archive file; this is needed if you specify
   * a target directory in a different drive with /t switch and don't
   * use full path name yourself.
   */
archive = Stream(name, "c", "query exists")
If archive == "" Then
    Call Error "can't find archive file '"name"'"

  /* Pick out an archiver, and compose a parameter string for it */
ext = Translate(SubStr(archive, LastPos(".", archive)))
Select
    When ext == ".ARJ" Then Do
        If files <> "" Then Do
            If Confirm("UNARJ always extracts all files!") == "N" Then
                Exit 1
            files = ""
        End
        If contents == FALSE & paths == FALSE Then
            prg = "unarj e"
        Else If contents == FALSE & paths == TRUE Then
            prg = "unarj x"
        Else
            prg = "unarj l"
        If pipe_output = TRUE Then Do
            If Confirm("can't pipe .ARJ to stdout, /p has to be ignored!") == "N" Then
                Exit 1
        End
    End

    When ext == ".GZ" Then Do
        If contents == FALSE Then
            prg = "gzip -d"
        Else
            prg = "gzip -l"
        If paths == FALSE Then
            If Confirm("gzip always extracts paths, /j has to be ignored!") == "N" Then
                Exit 1
        If pipe_output == TRUE Then
            prg = prg || "c"
    End

    When ext == ".LZH" Then Do
        If contents == FALSE Then
            prg = "lh2 x"
        Else
            prg = "lh2 l"
        If paths == TRUE Then
            files = files || " /s"
        If pipe_output == TRUE Then
            If Confirm("can't pipe .LZH to stdout, /p has to be ignored!") == "N" Then
                Exit 1
    End

    When ext == ".TAR" Then Do
        If contents == FALSE Then
            prg = "tar -xv"
        Else
            prg = "tar -t"
        If paths == FALSE Then
            If Confirm("tar always extracts paths, /j has to be ignored!") == "N" Then
                Exit 1
        If pipe_output == TRUE Then
            prg = prg || "O"
        prg = prg || "f"
    End

    When ext == ".Z" Then Do
        If contents == TRUE Then
            Call Error "can't display contents of Compress archive ('.Z')"
        prg = "compress -d"
        If pipe_output == TRUE
            Then prg = prg || "c"
    End

    When ext == ".ZIP" Then Do
        If contents == FALSE Then
            prg = "unzip"
        Else
            prg = "unzip -l"
        If paths == FALSE Then
            prg = prg || " -j"
        If pipe_output == TRUE Then
            prg = prg || " -p"
    End

    When ext == ".ZOO" Then Do
        If contents == FALSE Then
            prg = "zoo x"
        Else
            prg = "zoo la"
        If target_dir <> "." Then
            prg = prg || "."
        If paths == FALSE Then
            prg = prg || ":"
        If pipe_output == TRUE Then
            prg = prg || "pq"
    End

    Otherwise
        Call Error "unknown archive extension '"ext"'"
End

  /* Translate backslashes to slashes in path names if archiver is any
   * other than lh2 (all others use slashes internally).
   * NOTE: you have to use backslashes on the command line, or else
   * file name parameters will be misinterpreted to contain switches.
   */
If ext <> ".LZH" Then
    files = Translate(files, "/", "\")

  /* If we are extracting to another directory than the default "."... */
If target_dir <> "." Then Do
    curr = Directory()
    new = Directory(target_dir)
    If new == "" Then Do
        msg = "Can't find '" || target_dir || "', extracting to current directory"
        If Confirm(msg) == "N" Then
            Exit 1
        target_dir = "."
    End
End

  /* Run chosen program */
prg archive files

  /* Restore previous directory if it was changed */
If target_dir <> "." Then
    Call Directory curr

  /* Nice exit */
Exit 0

  /* Ask for confirmation. Return "Y" or "N". */
Confirm: Procedure Expose program_name
    Parse Arg wrnmsg

    Say program_name":" wrnmsg
    Call CharOut CON, "Continue (y/n)? "
    Do Until Pos(ans, "YyNn") > 0
        ans = SysGetKey("NoEcho")
    End
    Say Translate(ans)
Return Translate(ans)

  /* Exit with an error message */
Error: Procedure Expose program_name
    Parse Arg errmsg

    Say program_name":" errmsg
Exit 1

Help: Procedure Expose program_name
    Say program_name": (C) SuperOscar Softwares, Tommi Nieminen 1991-93."
    Say
    Say "Usage: [D:\] extract ARCHIVE [ FILE ... ] [ /jlp? /t DIR ]"
    Say
    Say "Extracts files or displays archive contents from archives made in"
    Say "several archivers. Currently known archivers are the following:"
    Say
    Say "  ==========================================================="
    Say "    Ext    Archivers                          Archiver used"
    Say "  ==========================================================="
    Say "   .arj    ARJ                                UNARJ 2.41"
    Say "   .gz     gzip                               GNU gzip 1.2.2"
    Say "   .lzh    OS/2:    Lh2, C-LHarc              Lh2 2.14"
    Say "           MS-DOS:  LHArc, LHA"
    Say "   .tar    tar                                GNU tar 1.10"
    Say "   .Z      Compress                           Compress v 4.2"
    Say "   .zip    OS/2:    PKZip2, Zip               UnZip v5.0"
    Say "           MS-DOS:  PKZip"
    Say "   .zoo    Zoo                                Zoo 2.1"
    Say
    Say "Switches:          /j      don't extract directories"
    Say "                   /l      display contents only"
    Say "                   /p      extract to standard output (pipe)"
    Say "                   /t      target directory"
    Say "                   /?      display this help page"
Exit 0
