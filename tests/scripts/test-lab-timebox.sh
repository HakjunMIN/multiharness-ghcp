#!/usr/bin/env bash
set -euo pipefail

total=0
for index in 0 1 2 3 4 5 6; do
  lab="$(ls docs/labs/lab${index}-*.md)"
  minutes="$(sed -n '1s/.*(\([0-9]\{1,\}\)분).*/\1/p' "$lab")"
  if [ -z "$minutes" ]; then
    echo "lab ${index} title is missing a duration" >&2
    exit 1
  fi
  if ! grep -qE "\| Lab ${index} [^|]*\| ${minutes}분 \|" docs/instructor/timebox.md; then
    echo "lab ${index} duration ${minutes}분 is not in the timebox table" >&2
    exit 1
  fi
  total=$((total + minutes))
done

lunch="$(sed -n 's/^| 점심 | \([0-9]\{1,\}\)분 .*/\1/p' docs/instructor/timebox.md)"
expected=$((total + lunch))
if [ "$expected" -ne 330 ]; then
  echo "total workshop time is ${expected}분, expected 330분" >&2
  exit 1
fi

for index in 0 1 2 3 4 5 6; do
  lab="$(ls docs/labs/lab${index}-*.md)"
  grep -Fq '## 종료 조건' "$lab"
  grep -Fq '## 막힐 때' "$lab"
done

for lab in docs/labs/lab0-*.md docs/labs/lab1-*.md docs/labs/lab2-*.md \
  docs/labs/lab3-*.md docs/labs/lab4-*.md docs/labs/lab5-*.md docs/labs/lab6-*.md; do
  grep -Fq '## 이 랩에서 배우는 것' "$lab"
done

printf 'OK: lab timebox and structure contract passed\n'
