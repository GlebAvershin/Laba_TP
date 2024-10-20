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

# Тест 1: Проверка архивирования файлов при заполнении папки более чем на 50%
test_threshold_70() {
  echo "Тест 1: Архивирование при заполнении папки более чем на 50%..."
  ./cleanup_log.sh "$LOG_DIR" 50 5
}

# Тест 2: Проверка архивирования файлов при заполнении папки более чем на 70%
test_threshold_90() {
  echo "Тест 2: Архивирование при заполнении папки более чем на 70%..."
  ./cleanup_log.sh "$LOG_DIR" 70 5
}

# Тест 3: Проверка архивирования большего количества файлов
test_archive_more_files() {
  echo "Тест 3: Архивирование 10 файлов..."
  ./cleanup_log.sh "$LOG_DIR" 70 10
}

# Тест 4: Проверка отсутствия архивирования при низком заполнении папки
test_low_threshold() {
  echo "Тест 4: Отсутствие архивирование при заполнении менее 100%..."
  ./cleanup_log.sh "$LOG_DIR" 100 5
}

# Тест 5: Проверка корректности ввода пути к папке
test_right_path() {
  echo "Тест 5: Проверка корректности ввода пути к папке..."
  ./cleanup_log.sh
}

# Тест 6: Проверка корректности ввода лимита
test_right_limit() {
  echo "Тест 6: Проверка корректности ввода лимита..."
  ./cleanup_log.sh "$LOG_DIR" 230 5
}

# Тест 7: Проверка корректности ввода количества файлов для архивации
test_right_files() {
  echo "Тест 7: Проверка корректности ввода количества файлов для архивации..."
  ./cleanup_log.sh "$LOG_DIR" 70 -3
}

# Генерация файлов и запуск тестов
generate_test_files
test_threshold_70
test_threshold_90
test_archive_more_files
test_low_threshold
test_right_path
test_right_limit
test_right_files

# Очистка после тестов
rm -rf "$LOG_DIR"
rm -rf "$BACKUP_DIR"
