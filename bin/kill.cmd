extproc C:\Bin\UNIX\perl -Sx
#!perl
# --------
# kill.cmd -- (C) SuperOscar Softwares, Tommi Nieminen 1993.
# --------
# `As simple a kill as kill can be.'
#
# 4-Oct-1993    v1.0: first version ready.

if ($#ARGV >= 0) {
    kill(9, @ARGV);
}
else {
    print "Usage: [D:\\] kill PID ...\n";
}
