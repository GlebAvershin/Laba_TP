@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Определение путей
set "LOG_DIR=D:\log"
set "BACKUP_DIR=D:\backup"

:: Очистка предыдущих данных
if exist "%LOG_DIR%" rd /s /q "%LOG_DIR%"
if exist "%BACKUP_DIR%" rd /s /q "%BACKUP_DIR%"

:: Создание папок для теста
mkdir "%LOG_DIR%"
mkdir "%BACKUP_DIR%"

:: Генерация тестовых файлов размером 50 МБ в папке /log (итого 500 МБ)
echo Генерация файлов для тестов...
for /L %%i in (1,1,20) do (
    fsutil file createnew "%LOG_DIR%\file%%i.log" 52428800 >nul
    echo Файл %LOG_DIR%\file%%i.log создан
)

:: Тест 1: Проверка архивирования при заполнении папки более чем на 1% (для теста)
echo.
echo Тест 1: Архивирование при заполнении папки более чем на 1% (для теста)...
call cleanup_log.bat "%LOG_DIR%" 1 5

:: Тест 2: Проверка архивирования при заполнении папки более чем на 10% (для теста)
echo.
echo Тест 2: Архивирование при заполнении папки более чем на 50% (для теста)...
call cleanup_log.bat "%LOG_DIR%" 10 5

:: Тест 3: Архивирование 10 файлов при заполнении более чем на 1% (для теста)
echo.
echo Тест 3: Архивирование 10 файлов при заполнении более чем на 1% (для теста)...
call cleanup_log.bat "%LOG_DIR%" 1 10

:: Тест 4: Отсутствие архивирования при заполнении менее чем 100% (для теста)
echo.
echo Тест 4: Архивирование при заполнении менее чем 100% (для теста)...
call cleanup_log.bat "%LOG_DIR%" 100 5

:: Очистка после тестов
echo.
echo Очистка после тестов...
rd /s /q "%LOG_DIR%"
rd /s /q "%BACKUP_DIR%"

echo.
echo Все тесты завершены.

endlocal
exit /b 0
