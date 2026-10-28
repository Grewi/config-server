#!/usr/bin/env bash
set -euo pipefail

NETWORK="webnet"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOVE_NETWORK="${REMOVE_NETWORK:-0}"   # REMOVE_NETWORK=1 ./stop.sh — удалит сеть
REMOVE_VOLUMES="${REMOVE_VOLUMES:-0}"   # REMOVE_VOLUMES=1 ./stop.sh — удалит тома БД

info()  { echo -e "\033[1;34m[stop]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[ ok ]\033[0m $*"; }
err()   { echo -e "\033[1;31m[fail]\033[0m $*" >&2; }

# 1. Остановка стеков в обратном порядке
for stack in site db proxy; do
  dir="$BASE_DIR/$stack"
  if [[ ! -f "$dir/docker-compose.yml" ]]; then
    continue
  fi
  info "Останавливаю стек '$stack'..."
  args=(down --remove-orphans)
  if [[ "$REMOVE_VOLUMES" == "1" ]]; then
    args+=(-v)
    info "  (тома будут удалены)"
  fi
  ( cd "$dir" && docker compose "${args[@]}" )
  ok "Стек '$stack' остановлен"
done

# 2. Удаление сети (только по флагу — иначе пригодится при следующем запуске)
if [[ "$REMOVE_NETWORK" == "1" ]]; then
  if docker network inspect "$NETWORK" >/dev/null 2>&1; then
    # Проверяем, что в сети не осталось контейнеров
    if [[ -n "$(docker network inspect "$NETWORK" -f '{{range .Containers}}{{.Name}} {{end}}')" ]]; then
      err "В сети '$NETWORK' ещё есть контейнеры, не удаляю"
    else
      info "Удаляю сеть '$NETWORK'..."
      docker network rm "$NETWORK" >/dev/null
      ok "Сеть '$NETWORK' удалена"
    fi
  else
    info "Сеть '$NETWORK' уже отсутствует"
  fi
else
  info "Сеть '$NETWORK' оставлена (REMOVE_NETWORK=1 для удаления)"
fi
