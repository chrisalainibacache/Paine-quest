#!/usr/bin/env bash
# Corre las 3 pruebas y FALLA también si Godot imprime "SCRIPT ERROR" (un script que no compila
# o que se cae a medio camino). Sin esto, las pruebas pueden decir "OK (0 fallas)" aunque un
# script esté roto: pasó con audio_director.gd.
# Uso: GODOT=/ruta/godot ./tools/run_tests.sh
GODOT="${GODOT:-godot}"
status=0
for t in smoke systems levels; do
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
