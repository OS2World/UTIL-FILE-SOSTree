/* ---------------
 * msg_english.inc
 * ---------------
 * English messages for SOS Tree utility.
 *
 * 16.9.1993    File created (TN).
 */

  /* Error messages */
const char *errormsg[] = {
    "Path not found \"%s\"",
    "Unknown switch \"-%c\"",
    "Invalid command line syntax (use \"-?\" to get help)",
    "Program internal error"
};

const char *header_line = "Directory tree of \"%s\"\n";

  /* Number of lines in help screen; ie. number of message strings
   * in helpmsg[] table.
   */
#define HELP_SCREEN_HEIGHT      11

  /* Help screen */
const char *helpmsg[HELP_SCREEN_HEIGHT] = {
    "Display directory tree with or without graphics. Usage:",
    "\n    [D:\\] sostree [ -adfhnqz | -? ] [ DIR ]\n",
    "The meanings of the switches are the following:",
    "    -a  Show file attributes too.",
    "    -d  Show file dates and times too.",
    "    -f  Show files also (as leaves).",
    "    -h  Show hidden and system files too.",
    "    -n  Show full path names without graphics.",
    "    -q  Do not show \"Directory tree of ...\" header.",
    "    -z  Show file sizes too.\n",
    "    -?  Show this help screen."
};
