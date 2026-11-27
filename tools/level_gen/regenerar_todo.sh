#!/usr/bin/env bash
# Regenera TODAS las piezas y salas desde sus generadores (.py). En un PR, si después de
# esto `git diff` muestra cambios, hay un .tscn que no coincide con su generador.
set -e
cd "$(dirname "$0")/../.."
for s in train_props station_props props props2 props3 items food ammo_items buin_props tunnels \
         platform waiting_room ticket_office service_corridor storeroom south_platform oficina_jefe banos sala_maquinas cabina_senales \
         track_north derailed_train wagon_interior convoy_side underpass switch_house sala_locomotora galpon_carga pasarela_convoy cuarto_drenaje \
         buin_bridge buin_checkpoint buin_field buin_station buin_warehouse buin_vineyard buin_shed canal_riego caseta_bomba patio_cosecha pasarela_vina zone_buin \
         maestranza_acceso maestranza_guardia maestranza_enfermeria maestranza_taller maestranza_vestuario maestranza_pasillo_cuarentena maestranza_puesto_sanitario \
         title chapter_end inventory creature_door puzzle_lab skull_arena; do
    python3 "tools/level_gen/$s.py" > /dev/null
done
echo "regenerado"
