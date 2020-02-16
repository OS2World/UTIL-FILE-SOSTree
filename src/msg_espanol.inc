/* ---------------
 * msg_espanol.inc
 * ---------------
 * Spanish messages for SOS Tree.
 *
 * 19-Oct-1993  File created (TN). Translations by Xavier Caballe.
 */

  /* Error messages */
const char *errormsg[] = {
    "Path no encontrado \"%s\"",
    "Par metro no v lido \"-%c\"",
    "S¡ntaxis ilegal en la l¡nea de ¢rdenes (\"-?\" para ayuda)",
    "Error interno del programa"
};

const char *header_line = "Estructura de directorios de \"%s\"\n";

  /* Number of lines in help screen; ie. number of message strings
   * in helpmsg[] table.
   */
#define HELP_SCREEN_HEIGHT      11

  /* Help screen */
const char *helpmsg[HELP_SCREEN_HEIGHT] = {
    "Visualiza la estructura de directorios, con o sin gr ficos. Uso:",
    "\n    [D:\\] sostree [ -adfhnqz | -? ] [ DIR ]\n",
    "La funci¢n de los par metros es la siguiente:",
    "    -a Mostrar los atributos de los ficheros.",
    "    -d Mostrar la fecha y la hora de los ficheros.",
    "    -f Mostrar el nombre de los fitxers.",
    "    -h Mostrar tambi‚n los ficheros ocultos y de sistema.",
    "    -n Mostrar el path completo sin gr ficos.",
    "    -q No visualizar la cabecera \"Estructura de directorios de...\"",
    "    -z Mostrar el tama¤o de los ficheros.",
    "    -? Visualizar esta pantalla de ayuda."
};
