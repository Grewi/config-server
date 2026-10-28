#!/usr/bin/env bash
set -euo pipefail

NETWORK="webnet"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Цветной вывод (по желанию)
info()  { echo -e "\033[1;34m[start]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[ ok ]\033[0m $*"; }
err()   { echo -e "\033[1;31m[fail]\033[0m $*" >&2; }

# 1. Проверка зависимостей
if ! command -v docker >/dev/null 2>&1; then
  err "Docker не установлен"
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  err "Плагин 'docker compose' недоступен"
  exit 1
fi

# 2. Создание сети, если её нет
if docker network inspect "$NETWORK" >/dev/null 2>&1; then
  info "Сеть '$NETWORK' уже существует"
else
  info "Создаю сеть '$NETWORK'..."
  docker network create "$NETWORK" >/dev/null
  ok "Сеть '$NETWORK' создана"
fi

# 3. Последовательный запуск стеков
#    Порядок важен: сначала главный Nginx и БД, потом сайт.

STACKS=(
  "."                         # Главный Nginx (корень)
  "db"                        # База
  "sites/course.grewi"        # Сайт
)

for stack in "${STACKS[@]}"; do
  dir="$BASE_DIR/$stack"
  if [[ ! -f "$dir/docker-compose.yml" ]]; then
    err "Не найден $dir/docker-compose.yml"
    exit 1
  fi
  info "Запускаю стек '$stack'..."
  ( cd "$dir" && docker compose up -d )
  ok "Стек '$stack' запущен"
done

# 4. Итог
echo
info "Статус контейнеров:"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
