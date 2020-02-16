/* --------
 * FileFind (C) SuperOscar Softwares, Tommi Nieminen 1993.
 * --------
 * WhereIs written in REXX.
 *
 * Usage:
 *     [D:\] filefind [PATH\]MASK ... [ /h /n /? ]
 *
 * Switches:
 *     /h      Find hidden and system files too.
 *     /n      Brief format: display fully qualified file names only.
 *     /?      Display help page and quit.
 *
 * 24-Feb-1993  v1.0: first version ready.
 * 26-Feb-1993  v1.0a: bug corrections.
 * 26-Feb-1993  v1.1: multiple file parameters allowed.
 * 4-Jul-1993   v1.2: national date and time formats supported.
 * 12-Aug-1993  v1.3: bug fixes; enhanced switch handling; /n switch.
 * 17-Aug-1993  v1.4: /h switch.
 * 6-Sep-1993   v1.4a: unknown switches cause an error.
 */

Parse Arg find "/"switches

  /* Program name */
prgname = "FileFind v1.4a"

  /* Constants */
TRUE = 1
FALSE = 0

  /* Defaults */
hidden_files = FALSE
names_only = FALSE

  /* Examine switches */
switches = Translate(switches)
Do i = 1 To Length(switches)
    ch = SubStr(switches, i, 1)

    Select
        When ch == "H" Then
            hidden_files = TRUE

        When ch == "N" Then
            names_only = TRUE

        When ch == "?" Then
            Call Help

        Otherwise
            Call Error "unknown switch '/"ch"' (use /? to get help)"
    End
End

If find == "" Then Call Error "no parameters (use /? to get help)"

  /* Set attribute mask (format "ADHRS", "+" = set, "-" = not set, "*" =
   * ignore
   */
If hidden_files == FALSE Then
    attrib_mask = "*--*-"
Else
    attrib_mask = "*-***"

  /* Don't load anything unnecessary when viewing in brief format */
If names_only == FALSE Then Do
      /* Load SysFileTree() and SysIni() functions */
    Call RxFuncAdd "SysFileTree", "RexxUtil", "SysFileTree"
    Call RxFuncAdd "SysIni", "RexxUtil", "SysIni"

      /* Read national language settings from "os2.ini" */
    iDate = SysIni("user", "PM_National", "iDate")
    iTime = SysIni("user", "PM_National", "iTime")
    sDate = SysIni("user", "PM_National", "sDate")
    sTime = SysIni("user", "PM_National", "sTime")

      /* Bug warning: in certain situations strange results may be
       * returned by SysIni().
       */
    datefmt = Abs(Left(iDate, 1))
    time24 = Abs(Left(iTime, 1))
    datesep = Left(sDate, 1)
    timesep = Left(sTime, 1)
End

  /* Go through all parameters */
Do i = 1 To Words(find)

      /* Find files */
    ok = SysFileTree(Word(find, i), files, "fst", attrib_mask)

      /* Display results in national format */
    Do j = 1 To files.0

        If names_only == FALSE Then Do

              /* Separate different parts of date-time string */
            datetime = Translate(Word(files.j, 1), " ", "/")
            year = Format(Word(datetime, 1), 2)
            mon = Format(Word(datetime, 2), 2)
            day = Format(Word(datetime, 3), 2)
            hour = Format(Word(datetime, 4), 2)
            min = Word(datetime, 5)

            Select
                When datefmt == 0 Then
                    date = mon || datesep || day || datesep || year
                When datefmt == 1 Then
                    date = day || datesep || mon || datesep || year
                When datefmt == 2 Then
                    date = year || datesep || mon || datesep || day
                Otherwise
                    Call Error "Date format code ==" datefmt"!!??"
            End

            Select
                When time24 == 0 Then Do
                    ampm = "am"
                    If hour > 12 Then Do
                        ampm = "pm"
                        hour = Format(hour - 12, 2)
                    End
                    time = hour || timesep || min || ampm
                End
                When time24 == 1 Then
                    time = hour || timesep || min
                Otherwise
                    Call Error "Time format code ==" timefmt"!!??"
            End

              /* Other information */
            size = Format(Word(files.j, 2), 8)
            attr = Word(files.j, 3)
            fname = Word(files.j, 4)

              /* Display information */
            Say date time size attr fname
        End /* If !names_only */

        Else
            Say Word(files.j, 4)

    End /* Do j */

End /* Do i */

Exit 0

Error: Procedure Expose prgname
    Parse Arg msg

    Say prgname":" msg
Exit 1

Help: Procedure Expose prgname
    Say prgname "(C) SuperOscar Softwares, Tommi Nieminen 1993."
    Say
    Say "    [D:\] filefind [PATH\]MASK ... [ /h /n /? ]"
    Say
    Say "FileFind is a file find program written in REXX. It finds files that"
    Say "match given MASK(s) under given PATH(s). Hidden and system files and"
    Say "directories are NOT found."
    Say
    Say "If PATH is not given, its default value is the current directory."
    Say
    Say "Switches:"
    Say "    /h      find hidden and system files too"
    Say "    /n      brief format: display only full path names"
    Say "    /?      display this help"
Exit 0
