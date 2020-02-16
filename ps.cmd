/* ------
 * ps.cmd (C) Tommi Nieminen 1993.
 * ------
 * Changes output coming from PStat to shorter and more readable format.
 *
 * NOTE: it took a long time until I found a method for piping something
 * to REXX programs INSIDE a REXX program. Why, oh why, IBM doesn't send
 * decent manuals with OS/2? Why, oh why, `rxqueue.exe' isn't documented
 * in the online command reference guide?
 *
 * 31-Mar-1993  v1.0: first usable AWK version.
 * 2-Jun-1993   v2.0: translation to Perl.
 * 3-Jul-1993   v3.0: whole process done from within Perl.
 * 20-Aug-1993  v4.0: translation to REXX. Uses queues.
 */

"@echo off"

Say " PID  PPID   SID  PROCESS"
"pstat /c |rxqueue"
Do While Queued() <> 0
    Pull line
    If Words(line) == 8 & DataType(Word(line, 1)) == "NUM" Then Do
        pid = Format(X2D(Word(line, 1)), 4)
        ppid = Format(X2D(Word(line, 2)), 4)
        sid = Format(X2D(Word(line, 3)), 4)

          /* Translate process names to lower case */
        name = Translate(Word(line, 4), XRange("a", "z"), XRange("A", "Z"))

        Say pid"  "ppid"  "sid"  "name
    End
End
