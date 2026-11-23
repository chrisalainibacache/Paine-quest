#!/usr/bin/env bash
# Corre las 5 pruebas y FALLA también si Godot imprime "SCRIPT ERROR".
# Uso: GODOT=/ruta/godot ./tools/run_tests.sh
GODOT="${GODOT:-godot}"
status=0
for t in smoke systems levels credits enemies; do
    out=$("$GODOT" --headless --path . -s "res://tests/${t}_test.gd" 2>&1)
    code=$?
    echo "== $t: $(echo "$out" | grep 'RESULTADO' | tail -1)"
    echo "$out" | grep -E "^  XX" | head -20
    if echo "$out" | grep -q "SCRIPT ERROR"; then
        echo "✗ $t: errores de script:"
        echo "$out" | grep -A2 "SCRIPT ERROR" | head -40
        status=1
    fi
    if [ $code -ne 0 ] || ! echo "$out" | grep -q "RESULTADO: OK"; then
        echo "✗ $t falló (código $code)"
        status=1
    fi
done
exit $status
