/* -------------
 * msg_suomi.inc
 * -------------
 * Suomalaiset ilmoitukset SOS Tree -ohjelmaa varten.
 *
 * 16.9.1993    Tiedosto luotu (TN).
 */

const char *errormsg[] = {
    "Polkua \"%s\" ei l”ydy",
    "Tuntematon valitsin \"-%c\"",
    "Virheellinen komentorivi (\"-?\" antaa apua)",
    "Sis„inen ohjelmavirhe"
};

const char *header_line = "Hakemistopuu \"%s\"\n";

#define HELP_SCREEN_HEIGHT      11

const char *helpmsg[HELP_SCREEN_HEIGHT] = {
    "N„yt„ hakemistorakenne kaaviona tai luettelona. K„ytt”:",
    "\n    [D:\\] sostree [ -adfhnqz | -? ] [ HAK ]\n",
    "Valitsimien merkitykset ovat seuraavat:",
    "    -a  N„yt„ my”s tiedostom„„reet.",
    "    -d  N„yt„ my”s p„iv„ykset ja ajat.",
    "    -f  N„yt„ my”s tiedostot (lehtin„).",
    "    -h  N„yt„ my”s piilotetut ja j„rjestelm„tiedostot.",
    "    -n  N„yt„ t„ydet polkunimet puukaaviotta.",
    "    -q  Žl„ n„yt„ \"Hakemistopuu ...\" -tunnisterivi„.",
    "    -z  N„yt„ my”s tiedostojen koot.\n",
    "    -?  N„yt„ t„m„ avustusn„ytt”."
};
