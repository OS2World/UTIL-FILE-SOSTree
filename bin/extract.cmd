/* -------
 * Extract (C) SuperOscar Softwares, Tommi Nieminen 1991-93.
 * -------
 * Extracts files from archives. Note: this script only forms the
 * command line necessary to run the archiver but doesn't REPLACE it.
 * You'll still need all the archivers you are likely to encounter.
 *
 * If you do not want to keep your archivers in PATH, you can modify
 * the value of 'arcdir' variable in line 48 (cf. comments there).
 *
 * Usage:
 *     [D:\] extract ARCHIVE [ FILE ... ] [ /jlp? /t DIR ]
 *
 * Switches:
 *     /j      Don't extract directories (junk paths)
 *     /l      Display archive listing only
 *     /p      Extract to standard output (pipe)
 *     /t      Set target directory
 *     /?      Display help page and quit
 *
 * Semantic ambiguities are not allowed in the command line, ie. /l and
 * /p cannot be used in connection with any other switch (/l output
 * always goes to standard output, it's no use /Piping it). However, /?
 * overrides all the other switches.
 *
 * 16-Aug-1993  v1.0: first PD version, based on private version 2.8.
 *              Supported archivers: Zip (.zip), Lh2 (.lzh), Zoo (.zoo),
 *              gzip (.gz), Compress (.Z), tar (.tar), UNARJ (.arj).
 * 5-Sep-1993   v1.0a: archiver location stated in `arcdir' variable;
 *              this makes it unnecessary to keep the programs in PATH.
 * 27-Sep-1993  v1.0b: added support for HPACK and ARC.
 * 3-Oct-1993   v1.0c: help page simplified.
 * 18-Oct-1993  v1.1: different internal structure (the code should be a
 *              bit easier to read now).
 */

"@echo off"

Parse Arg name files "/"switches

  /* Program name and version for messages */
prgname = "Extract v1.1"

  /* Directory where archivers are kept. The value must have a trailing
   * backslash (eg. "C:\Bin\Arc\"). If arcdir == "", Extract does a
   * normal PATH search.
   */
arcdir = ""

  /* Symbolic constants */
TRUE = 1
FALSE = 0

  /* Commands */
EXTRACT = 0             /* Extract file */
PIPE = 1                /* Pipe file, ie. extract to stdout */
LIST = 2                /* View archive directory */

  /* Defaults */
command = EXTRACT       /* Default command */
paths = TRUE            /* Extract directory structure? */
target_dir = "."        /* Current directory */

  /* Warning messages */
WRN_paths = "Archiver doesn't support /j. Directories will be created."
WRN_pipes = "Archiver doesn't support /p. Extracting to disk."

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
                Call Error "/l can't be used in this connection"
            command = LIST
        End

          /* /p: pipe output to standard output */
        When ch == "P" Then Do
            If Verify(switches, "Pp?") <> 0 Then
                Call Error "/p can't be used in this connection"
            command = PIPE
        End

          /* /t: give target directory */
        When ch == "T" Then Do
            end = SubStr(switches, i + 1)

              /* Are there still switches? */
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
If name == "" Then Call Error "no parameters (use /? to get help)"

  /* Get full path name for archive file.  This is necessary if the user
   * specified a target directory for extracting in a different drive
   * but didn't use full path name for the archive.
   */
archive = Stream(name, "c", "query exists")
If archive == "" Then
    Call Error "can't find archive file '"name"'"

  /* Pick out an archiver, and compose a parameter string for it */
ext = Translate(SubStr(archive, LastPos(".", archive)))
Select
      /* ARC */
    When ext == ".ARC" Then
        Select
            When command == PIPE Then
                prg = "arc p"
            When command == LIST Then
                prg = "arc l"
            Otherwise Do
                If paths == FALSE Then
                    If confirm(WRN_paths) == "N" Then Exit 1
                prg = "arc x"
            End
        End

      /* ARJ */
    When ext == ".ARJ" Then Do
        Select
            When command == PIPE Then Do
                If Confirm(WRN_pipes) == "N" Then Exit 1
                prg = "unarj x"
            End
            When command == LIST Then
                prg = "unarj l"
            Otherwise
                If paths == FALSE Then
                    prg = "unarj e"
                Else
                    prg = "unarj x"
        End
        If Confirm(WRN_filemask) == "N" Then
            Exit 1
        files = ""
    End

      /* GNU gzip */
    When ext == ".GZ" Then
        Select
            When command == PIPE Then
                prg = "gzip -dc"
            When command == LIST Then
                prg = "gzip -l"
            Otherwise Do
                If paths == FALSE Then
                    If Confirm(WRN_paths) == "N" Then Exit 1
                prg = "gzip -d"
            End
        End

      /* HPACK */
    When ext == ".HPK" Then
        Select
            When command == PIPE Then
                prg = "hpack p"
            When command == LIST Then
                prg = "hpack v"
            Otherwise Do
                If paths == FALSE Then
                    If Confirm(WRN_paths) == "N" Then Exit 1
                prg = "hpack x"
            End
        End

      /* Lh/2, C-LHarc, LHArc, LHA */
    When ext == ".LZH" Then
        Select
            When command == PIPE Then Do
                If Confirm(WRN_pipes) == "N" Then Exit 1
                prg = "lh2 x"
            End
            When command == LIST Then
                prg = "lh2 l"
            Otherwise Do
                prg = "lh2 x"
                If paths == TRUE Then files = files || " /s"
            End
        End

      /* tar */
    When ext == ".TAR" Then
        Select
            When command == PIPE Then
                prg = "tar -xvOf"
            When command == LIST Then
                prg = "tar -tf"
            Otherwise Do
                If paths == FALSE Then
                    If Confirm(WRN_paths) == "N" Then Exit 1
                prg = "tar -xvf"
            End
        End

      /* Compress */
    When ext == ".Z" Then
        Select
            When command == PIPE Then
                prg = "compress -dc"
            When command == LIST Then
                Call Error "can't display contents of Compress archive ('.Z')"
            Otherwise Do
                If paths == FALSE Then
                    If Confirm(WRN_paths) == "N" Then Exit 1
                prg = "compress -d"
            End
        End

      /* Zip, PKZip2, PKZip */
    When ext == ".ZIP" Then
        Select
            When command == PIPE Then
                prg = "unzip -p"
            When command == LIST Then
                prg = "unzip -l"
            Otherwise Do
                prg = "unzip -x"
                If paths == FALSE Then
                    prg = prg || "j"
            End
        End

      /* Zoo */
    When ext == ".ZOO" Then
        Select
            When command == PIPE Then
                prg = "zoo xpq"
            When command == LIST Then
                prg = "zoo la"
            Otherwise Do
                prg = "zoo x"
                If target_dir <> "." Then prg = prg || "."
                If paths == FALSE Then prg = prg || ":"
            End
        End

    Otherwise
        Call Error "unknown archive extension '"ext"'"
End

  /* Translate backslashes to slashes in path names if archiver is any
   * other than Lh/2 (all others use slashes internally).
   * NOTE: on the command line you have to use backslashes, or else the
   * file name parameters will be misinterpreted to contain switches.
   */
If ext <> ".LZH" Then
    files = Translate(files, "/", "\")

  /* If we are extracting to another directory than the current one,
   * we have to change to the target directory--this is the general
   * method; some archivers might have a capability to do this on their
   * own.
   */
If target_dir <> "." Then Do
    curr = Directory()
    new = Directory(target_dir)
    If new == "" Then Do
        If Confirm("'"target_dir"' not found. Extracting to current directory.") == "N" Then
            Exit 1
        target_dir = "."
    End
End

  /* Execute */
arcdir""prg archive files

  /* Restore previous directory if it was changed */
If target_dir <> "." Then Call Directory curr

  /* Nice exit */
Exit 0

  /* Ask for confirmation. Return "Y" or "N". */
Confirm: Procedure Expose prgname
    Parse Arg msg

    Say prgname":" msg
    Call CharOut CON, "Continue (y/n)? "
    Do Until Pos(ans, "YyNn") > 0
        ans = SysGetKey("NoEcho")
    End
    Say Translate(ans)
Return Translate(ans)

  /* Exit with an error message */
Error:
    Parse Arg errmsg

    Say prgname":" errmsg
Exit 1

Help: Procedure Expose prgname
    Say prgname "(C) SuperOscar Softwares, Tommi Nieminen 1991-93."
    Say
    Say "    [D:\] extract ARCHIVE [ FILE ... ] [ /jlp? /t DIR ]"
    Say
    Say "Extracts files or displays archive contents from archives made in"
    Say "several archivers. Currently known archivers are the following:"
    Say
    Say "    .arc   ARC                     .tar    GNU tar"
    Say "    .arj   ARJ                     .Z      Compress"
    Say "    .gz    gzip                    .zip    Zip (PKZip etc.)"
    Say "    .hpk   HPACK                   .zoo    Zoo"
    Say "    .lzh   Lh/2 (LHArc etc.)"
    Say
    Say "Switches:"
    Say "    /j      don't extract directories"
    Say "    /l      display contents only"
    Say "    /p      extract to standard output (pipe)"
    Say "    /t      target directory"
    Say "    /?      display this help page"
Exit 0
