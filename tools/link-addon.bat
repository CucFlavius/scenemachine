@echo off
REM Create symlinks/junctions for Scenemachine addon to multiple WoW clients
setlocal EnableExtensions

REM Source addon folder (where your addon lives)
set "TARGET=E:\Personal\wowAddon_Scenemachine\scenemachine"

REM Detect admin: use directory symlink (/D) if admin, else junction (/J)
net session >nul 2>&1
if %ERRORLEVEL%==0 (
    set "LINKCMD=mklink /D"
) else (
    set "LINKCMD=mklink /J"
)

echo Using: %LINKCMD%
echo Target: "%TARGET%"
echo.

for %%L in (
  "D:\Games\World of Warcraft\_retail_\Interface\AddOns\scenemachine"
  "D:\Games\World of Warcraft\_beta_\Interface\AddOns\scenemachine"
  "D:\Games\World of Warcraft\_ptr_\Interface\AddOns\scenemachine"
  "D:\Games\World of Warcraft\_xptr_\Interface\AddOns\scenemachine"
) do (
    echo Linking "%%~L" -> "%TARGET%"

    REM Remove old link/folder if it exists (safe: no /S, won’t delete non-empty real folders)
    if exist "%%~L" (
        echo   Removing existing folder or link...
        rmdir "%%~L"
    )

    REM Ensure parent directory exists
    if not exist "%%~dpL" (
        echo   Creating parent folder "%%~dpL"
        mkdir "%%~dpL"
    )

    %LINKCMD% "%%~L" "%TARGET%"
    echo.
)

pause
