#!/bin/bash

# Путь к логам для теста
LOG_DIR="./log"
BACKUP_DIR="./backup"

# Создаем папки для тестов
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

# Генерация тестовых файлов размером 0.5 GB минимум в папке /log
generate_test_files() {
  echo "Генерация файлов для тестов..."
  for i in {1..20}; do
    dd if=/dev/urandom of="$LOG_DIR/file$i.log" bs=50M count=1
  done
}

# Тест 1: Проверка архивирования файлов при заполнении папки более чем на 70%
test_threshold_70() {
  echo "Тест 1: Архивирование при заполнении папки более чем на 70%..."
  ./cleanup_log.sh "$LOG_DIR" 50 5
}

# Тест 2: Проверка архивирования файлов при заполнении папки более чем на 90%
test_threshold_90() {
  echo "Тест 2: Архивирование при заполнении папки более чем на 90%..."
  ./cleanup_log.sh "$LOG_DIR" 70 5
}

# Тест 3: Проверка архивирования большего количества файлов
test_archive_more_files() {
  echo "Тест 3: Архивирование 10 файлов..."
  ./cleanup_log.sh "$LOG_DIR" 70 10
}

# Тест 4: Проверка отсутствия архивирования при низком заполнении папки
test_low_threshold() {
  echo "Тест 4: Архивирование при заполнении менее 70%..."
  ./cleanup_log.sh "$LOG_DIR" 90 5
}

# Генерация файлов и запуск тестов
generate_test_files
test_threshold_70
test_threshold_90
test_archive_more_files
test_low_threshold

# Очистка после тестов
rm -rf "$LOG_DIR"
rm -rf "$BACKUP_DIR"
