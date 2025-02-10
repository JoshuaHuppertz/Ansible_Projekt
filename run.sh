#!/bin/bash

# Benutzerpfad korrekt auflösen, selbst wenn sudo verwendet wird
if [ -n "$SUDO_USER" ]; then
  RESULTS_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)/Ansible_Projekt/Results/H1
else
  RESULTS_DIR="$HOME/Ansible_Projekt/Results/H1"
fi

# Sicherstellen, dass das Verzeichnis existiert
if [ ! -d "$RESULTS_DIR" ]; then
  echo "Das Verzeichnis $RESULTS_DIR existiert nicht!"
  exit 1
fi

# Funktion zur Berechnung der Härtung
calculate_hardening() {
  local pass_file="$1"
  local fail_file="$2"

  # Zähle die Pass- und Fail-Einträge nur mit genauem Text '** PASS **' und '** FAIL **'
  local pass_count
  pass_count=$(grep -o '** PASS **' "$pass_file" | wc -l || echo 0)
  
  local fail_count
  fail_count=$(grep -o '** FAIL **' "$fail_file" | wc -l || echo 0)

  # Berechne die Gesamtzahl der Tests
  local total_count=$((pass_count + fail_count))

  # Gesamtanzahl der Tests aus allen Dateien zusammenzählen
  total_pass_count=$((total_pass_count + pass_count))
  total_fail_count=$((total_fail_count + fail_count))
  total_tests=$((total_tests + total_count))

  if [ "$total_count" -gt 0 ]; then
    # Berechne Prozentwerte
    local pass_percentage
    pass_percentage=$(echo "scale=2; ($pass_count / $total_count) * 100" | bc)
    
    local fail_percentage
    fail_percentage=$(echo "scale=2; ($fail_count / $total_count) * 100" | bc)

    # Ausgabe der Ergebnisse für jede Datei
    echo "Ergebnis für $(basename "$pass_file" _pass.txt):"
    echo "  PASS: $pass_count (${pass_percentage}%)"
    echo "  FAIL: $fail_count (${fail_percentage}%)"
    echo "---------------------------------------------"
  else
    echo "Keine Einträge gefunden in $(basename "$pass_file" _pass.txt)"
  fi
}

# Gehe ins Verzeichnis
cd "$RESULTS_DIR" || { echo "Fehler beim Wechseln ins Verzeichnis $RESULTS_DIR!"; exit 1; }

# Suche nach allen *_pass.txt-Dateien und sortiere nach IP
pass_files=$(find . -type f -name '*_pass.txt' | sort -V)

if [ -z "$pass_files" ]; then
  echo "Keine passenden Dateien gefunden im Verzeichnis $RESULTS_DIR!"
  exit 1
fi

# Initialisiere Zähler für alle Tests und die Anzahl der verarbeiteten Dateien
total_pass_count=0
total_fail_count=0
total_tests=0
file_count=0

# Verarbeite die Dateien
for pass_file in $pass_files; do
  base_name=$(basename "$pass_file" _pass.txt)
  fail_file="${base_name}_fail.txt"

  if [ -f "$fail_file" ]; then
    calculate_hardening "$pass_file" "$fail_file"
    ((file_count++))  # Zähler für die verarbeiteten Dateien erhöhen
  else
    echo "WARNUNG: Keine _fail.txt-Datei gefunden für $pass_file!"
  fi
done

# Ausgabe des Gesamt-Ergebnisses nur, wenn mehr als eine Datei verarbeitet wurde
if [ "$file_count" -gt 1 ]; then
  if [ "$total_tests" -gt 0 ]; then
    total_pass_percentage=$(echo "scale=2; ($total_pass_count / $total_tests) * 100" | bc)
    total_fail_percentage=$(echo "scale=2; ($total_fail_count / $total_tests) * 100" | bc)

    echo "Gesamt-Ergebnis:"
    echo "  PASS: $total_pass_count (${total_pass_percentage}%)"
    echo "  FAIL: $total_fail_count (${total_fail_percentage}%)"
  else
    echo "Es wurden keine Tests gefunden!"
  fi
else
  echo "Gesamt-Ergebnis wird nur angezeigt, wenn mehr als eine Datei verarbeitet wurde."
fi
