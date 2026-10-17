#!/bin/bash
# Сессия curl по сущностям темы: register → 401 без token-а → создание → список с search=
B=${1:-http://localhost:8080}
set -x
curl -s $B/health; echo
curl -s -i $B/products | head -1
TOKEN=$(curl -s -X POST $B/auth/register -H 'Content-Type: application/json' \
  -d "{\"email\":\"user$RANDOM@test.md\",\"password\":\"parola123\",\"name\":\"Test\"}" \
  | sed -E 's/.*"token":"([^"]+)".*/\1/')
AUTH="Authorization: Bearer $TOKEN"
curl -s -X POST $B/products -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"sku\":\"SKU-T$RANDOM\",\"name\":\"Тестовый товар\",\"category\":\"Упаковка\",\"unit\":\"шт\",\"quantity\":5,\"locationId\":1}"; echo
curl -s -G $B/products -H "$AUTH" --data-urlencode 'search=Тестовый'; echo
curl -s -X POST $B/stock-movements -H "$AUTH" -H 'Content-Type: application/json' \
  -d '{"productId":1,"type":"receipt","quantity":10,"toLocationId":4,"note":"smoke"}'; echo
curl -s "$B/stock-movements?limit=3" -H "$AUTH"; echo
