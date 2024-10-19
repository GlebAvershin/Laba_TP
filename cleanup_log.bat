@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Проверка количества аргументов
if "%~1"=="" (
    echo Использование: %~nx0 ^<путь_к_папке^> [порог_заполненности%%] [количество_файлов]
    exit /b 1
)

set "LOG_DIR=%~1"
set "THRESHOLD=%~2"
if "%THRESHOLD%"=="" set "THRESHOLD=70"
set "N=%~3"
if "%N%"=="" set "N=5"
set "BACKUP_DIR=D:\backup"

:: Проверка существования папки
if not exist "%LOG_DIR%" (
    echo Папка %LOG_DIR% не существует.
    exit /b 1
)

:: Создание папки для бэкапов, если её нет
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Получение буквы диска из пути
for %%D in ("%LOG_DIR%") do set "DRIVE=%%~dD"

:: Отладка: вывод буквы диска
echo DRIVE %DRIVE%

:: Получение FreeSpace и Size с помощью WMIC
for /f "tokens=2 delims==" %%a in (
    'wmic logicaldisk where "DeviceID='%DRIVE%'" get FreeSpace /value'
) do set "FREE_SPACE=%%a"

for /f "tokens=2 delims==" %%a in (
    'wmic logicaldisk where "DeviceID='%DRIVE%'" get Size /value'
) do set "TOTAL_SPACE=%%a"

:: Отладка: вывод свободного и общего места
echo FREE_SPACE: %FREE_SPACE%
echo TOTAL_SPACE: %TOTAL_SPACE%

:: Проверка, удалось ли получить значения
if "%FREE_SPACE%"=="" (
    echo Ошибка: не удалось получить свободное место на диске.
    exit /b 1
)

if "%TOTAL_SPACE%"=="" (
    echo Ошибка: не удалось получить общий размер диска.
    exit /b 1
)

:: Используем PowerShell для вычисления процента использования
for /f "usebackq tokens=*" %%a in (
    `powershell -NoProfile -Command "([math]::Floor(((%TOTAL_SPACE% - %FREE_SPACE%) * 100) / %TOTAL_SPACE%))"`
) do set "USAGE_PERCENT=%%a"

:: Отладочная информация: вывод процента использования
echo Использование диска: %USAGE_PERCENT%%%


:: Проверка, превышен ли порог использования
if %USAGE_PERCENT% GTR %THRESHOLD% (
    echo Папка %LOG_DIR% занята на %USAGE_PERCENT%%%, начинается архивация...

    :: Поиск N самых старых файлов без ограничения по дате с использованием dir
    set "FILES_TO_ARCHIVE="
    set /a count=0
    for /f "delims=" %%f in ('dir /b /a:-d /o:d "%LOG_DIR%"') do (
        set "FILE_PATH=%LOG_DIR%\%%f"
        echo Добавление файла в архив: !FILE_PATH!
        set "FILES_TO_ARCHIVE=!FILES_TO_ARCHIVE! "!FILE_PATH!""
        set /a count+=1
        if !count! GEQ %N% goto :archive
    )

    :archive
    if "!FILES_TO_ARCHIVE!"=="" (
        echo Нет файлов для архивации.
        exit /b 0
    )

    :: Создание архива с текущей датой и временем
    set "CURRENT_DATE=%DATE:~-4,4%-%DATE:~-10,2%-%DATE:~-7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%"
    set "CURRENT_DATE=!CURRENT_DATE: =0!"

    set "ARCHIVE_NAME=%BACKUP_DIR%\log_backup_%CURRENT_DATE%.tar.gz"

    echo Архивирование файлов: !FILES_TO_ARCHIVE!
    tar -czf "!ARCHIVE_NAME!" !FILES_TO_ARCHIVE!

    if !ERRORLEVEL! EQU 0 (
        echo Архивация завершена успешно. Файлы заархивированы в !ARCHIVE_NAME!.
        :: Удаление архивированных файлов
        for %%f in (!FILES_TO_ARCHIVE!) do (
            echo Удаление файла %%f
            del "%%~f"
        )
        echo Архивированные файлы удалены из %LOG_DIR%.
    ) else (
        echo Ошибка при архивации файлов.
        exit /b 1
    )
) else (
    echo Использование диска ниже порога в %THRESHOLD%%."
)

endlocal
exit /b 0
