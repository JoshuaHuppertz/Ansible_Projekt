#!/bin/bash

# Benutzerpfad korrekt auflösen, selbst wenn sudo verwendet wird
if [ -n "$SUDO_USER" ]; then
  RESULTS_DIR_H1=$(getent passwd "$SUDO_USER" | cut -d: -f6)/Ansible_Projekt/Results/H1
else
  RESULTS_DIR_H1="$HOME/Ansible_Projekt/Results/H1"
fi

# Sicherstellen, dass das Verzeichnis existiert
if [ -z "$RESULTS_DIR_H1" ] || [ ! -d "$RESULTS_DIR_H1" ]; then
  echo "Das Verzeichnis $RESULTS_DIR_H1 ist ungültig oder existiert nicht!"
  exit 1
fi

# Funktion zur Berechnung der Härtung
calculate_hardening() {
  local pass_file="$1"
  local fail_file="$2"

  # Zähle die Pass- und Fail-Einträge nur mit genauem Text '** PASS **' und '** FAIL **'
  local pass_count
  pass_count=$(grep -o '\*\* PASS \*\*' "$pass_file" | wc -l)

  local fail_count
  fail_count=$(grep -o '\*\* FAIL \*\*' "$fail_file" | wc -l)

  # Berechne die Gesamtzahl der Tests
  local total_count=$((pass_count + fail_count))

  if [ "$total_count" -gt 0 ]; then
    # Berechne Prozentwerte
    local pass_percentage
    pass_percentage=$(echo "scale=2; ($pass_count / $total_count) * 100" | bc)

    local fail_percentage
    fail_percentage=$(echo "scale=2; ($fail_count / $total_count) * 100" | bc)

    # Ausgabe der Ergebnisse für jede Datei
    echo -e "Ergebnis für $(basename "$pass_file" _pass.txt):\n  PASS: $pass_count (${pass_percentage}%)\n  FAIL: $fail_count (${fail_percentage}%)"
    echo "---------------------------------------------"
  else
    echo "Keine Einträge gefunden in $(basename "$pass_file" _pass.txt)"
  fi
}

# Funktion zur Berechnung der Härtung für Härtungsgrad 1
process_hardening_h1() {
  local RESULTS_DIR="$1"
  local max_audit_values=("${!2}") # Maximalwerte für Audits als Array
  local pass_audit_counts=("${!3}") # Zähler für PASS-Ergebnisse je Audit als Array
  local total_pass_count=0 total_fail_count=0 total_tests=0 file_count=0

  # Suche nach allen *_pass.txt-Dateien und sortiere nach IP
  pass_files=$(find "$RESULTS_DIR" -type f -name '*_pass.txt' | sort -V)

  if [ -z "$pass_files" ]; then
    echo "Keine passenden Dateien gefunden im Verzeichnis $RESULTS_DIR!"
    return 1
  fi

  # Verarbeite die Dateien
  for pass_file in $pass_files; do
    base_name=$(basename "$pass_file" _pass.txt)
    fail_file="${RESULTS_DIR}/${base_name}_fail.txt"  # Absolute Pfadangabe für fail.txt

    # Überprüfe, ob die pass.txt und fail.txt existieren
    if [ -f "$pass_file" ]; then
      echo "Gefundene Datei: $pass_file"
    else
      echo "WARNUNG: Keine _pass.txt-Datei gefunden für $base_name"
    fi

    if [ -f "$fail_file" ]; then
      echo "Gefundene Datei: $fail_file"
    else
      echo "WARNUNG: Keine _fail.txt-Datei gefunden für $base_name"
    fi

    # Wenn beide Dateien existieren, berechne die Härtung
    if [ -f "$pass_file" ] && [ -f "$fail_file" ]; then
      calculate_hardening "$pass_file" "$fail_file"

      # Zähle PASS-Ergebnisse für jedes Audit (1.1.1 bis 1.7.2 für Härtungsgrad 1)
      for audit_number in {1..7}; do
        audit_pass_count_h1=$(grep "Audit: $audit_number\.[0-9]*\.[0-9]*" "$pass_file" | grep -o '\*\* PASS \*\*' | wc -l)

        # Stelle sicher, dass die pass_audit_counts-Variable korrekt aktualisiert wird
        if [ -n "$audit_pass_count_h1" ]; then
          pass_audit_counts[$((audit_number-1))]=$((pass_audit_counts[$((audit_number-1))] + audit_pass_count_h1))
        fi
      done

      ((file_count++))  # Zähler für die verarbeiteten Dateien erhöhen
    else
      echo "WARNUNG: Eine oder beide Dateien (pass/fail) fehlen für $base_name"
    fi
  done

  # Berechne und gebe die Ergebnisse für jedes Audit in Härtungsgrad 1 aus
  for audit_number in {1..7}; do
    max_value=${max_audit_values[$((audit_number-1))]}
    pass_count=${pass_audit_counts[$((audit_number-1))]}

    if [ -z "$max_value" ] || [ "$max_value" -eq 0 ]; then
      max_value=0
    fi
    if [ -z "$pass_count" ]; then
      pass_count=0
    fi

    # Berechne Prozentsatz nur, wenn file_count > 0 ist
    if [ "$file_count" -gt 0 ]; then
      percentage=$(echo "scale=2; ($pass_count / $file_count) * 100" | bc)
      echo "Audit $audit_number: $pass_count von $file_count Tests bestanden (${percentage}%)"
    else
      echo "Audit $audit_number: Keine Tests verarbeitet, keine Daten verfügbar."
    fi
  done

  return 0
}

# Beispielhafte Werte für Maximalwerte der Audits (ersetze durch deine eigenen Werte)
max_audit_values_h1=(53 39 13 28 65 13 23)
pass_audit_counts_h1=(0 0 0 0 0 0 0)

# Verarbeite Härtungsgrad 1
echo "### Ergebnisse für Härtungsgrad 1 ###"
process_hardening_h1 "$RESULTS_DIR_H1" max_audit_values_h1[@] pass_audit_counts_h1[@]
