#!/bin/bash

# Путь к логам передается как первый аргумент
LOG_DIR=$1
# Процентное значение заполнения, передается как второй аргумент, по умолчанию 70%
THRESHOLD=${2:-70}
# Путь для архива, по умолчанию /backup
BACKUP_DIR="/backup"
# Количество файлов для архивации, по умолчанию 5
N=${3:-5}

# Проверка корректности ввода аргументов
if [ -z "$LOG_DIR" ]; then
  echo "Ошибка: Не указан путь к папке логов."
  exit 1
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 0 ] || [ "$THRESHOLD" -gt 100 ]; then
  echo "Ошибка: Некорректное значение порога. Укажите число от 0 до 100."
  exit 1
fi

if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -le 0 ]; then
  echo "Ошибка: Некорректное количество файлов для архивации. Укажите положительное число."
  exit 1
fi

# Проверка, существует ли папка
if [ ! -d "$LOG_DIR" ]; then
  echo "Папка $LOG_DIR не существует."
  exit 1
fi

# Создание папки для бэкапов, если её нет
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
fi

# Получение процента использования файловой системы для папки
usage=$(df "$LOG_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Использование диска: $usage%"

# Проверка превышения порога
if [ "$usage" -gt "$THRESHOLD" ]; then
  echo "Папка $LOG_DIR занята на $usage%, начинается архивация, следующих файлов..."

  # Выбор N самых старых файлов для архивации
  FILES_TO_ARCHIVE=$(find "$LOG_DIR" -type f -printf '%T@ %p\n' | sort -n | head -n "$N" | cut -d' ' -f2)

  if [ -z "$FILES_TO_ARCHIVE" ]; then
    echo "Нет файлов для архивации."
    exit 0
  fi

  # Создание архива
  ARCHIVE_NAME="$BACKUP_DIR/log_backup_$(date +%F_%T).tar.gz"
  tar vczf "$ARCHIVE_NAME" $FILES_TO_ARCHIVE
  if [ $? -eq 0 ]; then
    echo "Архивация завершена успешно. Файлы заархивированы в $ARCHIVE_NAME."

    # Удаление архивированных файлов
    rm $FILES_TO_ARCHIVE
  else
    echo "Ошибка при архивации файлов."
    exit 1
  fi
else
  echo "Использование диска ниже порога в $THRESHOLD%."
fi
