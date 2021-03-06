/* ---------------
 * msg_catala.inc
 * ---------------
 * Catalan messages for SOS Tree.
 *
 * 19-Oct-1993  File created (TN). Translations by Xavier Caballe.
 */

  /* Error messages */
const char *errormsg[] = {
    "Path no trobat \"%s\"",
    "Par�metre no v�lid \"-%c\"",
    "S�ntaxi il�legal a la l�nia d\'ordres (\"-?\" per ajuda)",
    "Error intern del programa"
};

const char *header_line = "Estructura de directoris de \"%s\"\n";

  /* Number of lines in help screen; ie. number of message strings
   * in helpmsg[] table.
   */
#define HELP_SCREEN_HEIGHT      11

  /* Help screen */
const char *helpmsg[HELP_SCREEN_HEIGHT] = {
    "Visualitza l\'estructura de directoris, amb o sense gr�fics. S�ntaxi:",
    "\n    [D:\\] sostree [ -adfhnqz | -? ] [ DIR ]\n",
    "La funci� dels par�metres �s la seg�ent:",
    "    -a Mostrar els atributs dels fitxers.",
    "    -d Mostrar la data i l\'hora dels fitxers.",
    "    -f Mostrar el nom dels fitxers.",
    "    -h Mostrar tamb� els fitxers ocults i de sistema.",
    "    -n Mostrar el path complet sense gr�fics.",
    "    -q No visualitzar la cap�alera \"Estructura de directoris de...\"",
    "    -z Indicar el tamany dels fitxers.",
    "    -? Visualitzar aquesta pantalla d\'ajuda."
};
