#!/usr/bin/env bash

# Ergebnisverzeichnis festlegen
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Verzeichnis erstellen, falls es nicht existiert

# Auditnummer festlegen
AUDIT_NUMBER="6.2.1.2.3"

# Ergebnisvariablen initialisieren
l_output=""
l_output2=""

# Überprüfen, ob systemd-journal-upload aktiviert ist
l_enabled=$(systemctl is-enabled systemd-journal-upload.service 2>/dev/null)
if [ "$l_enabled" == "enabled" ]; then
    l_output+="\n- systemd-journal-upload.service is enabled."
else
    l_output2+="\n- systemd-journal-upload.service is not enabled."
fi

# Überprüfen, ob systemd-journal-upload aktiv ist
l_active=$(systemctl is-active systemd-journal-upload.service 2>/dev/null)
if [ "$l_active" == "active" ]; then
    l_output+="\n- systemd-journal-upload.service is active."
else
    l_output2+="\n- systemd-journal-upload.service is not active."
fi

# Ergebnis überprüfen und ausgeben
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Ergebnis:\n ** FAIL **\n - Gründe für das Fehlschlagen der Prüfung:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Erfolgreich konfiguriert:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Ergebnis in die entsprechende Datei schreiben
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
