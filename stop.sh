#!/usr/bin/env bash
set -euo pipefail

NETWORK="webnet"

info()  { echo -e "\033[1;34m[stop]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[ ok ]\033[0m $*"; }
err()   { echo -e "\033[1;31m[fail]\033[0m $*" >&2; }

# 1. Остановка всех запущенных контейнеров
running="$(docker ps -q)"

if [[ -n "$running" ]]; then
  info "Останавливаю все запущенные контейнеры..."
  docker stop $running >/dev/null
  docker rm $running >/dev/null
  ok "Все контейнеры остановлены"
else
  info "Запущенных контейнеров нет"
fi

# 2. Удаление сети (если существует и не занята контейнерами)
if docker network inspect "$NETWORK" >/dev/null 2>&1; then
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
