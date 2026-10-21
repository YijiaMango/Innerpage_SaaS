@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo === Innerpage_SaaS 快速更新轉發網址 ===
echo.

if not exist ".git" (
  echo [錯誤] 這裡不是 git repo。
  pause
  exit /b 1
)
if not exist "scripts\update-redirect-url.ps1" (
  echo [錯誤] 找不到 scripts\update-redirect-url.ps1
  pause
  exit /b 1
)

set "APP_COUNT=0"
for /d %%D in (*) do (
  if exist "%%D\redirect.config.js" (
    set /a APP_COUNT+=1
    set "APP_!APP_COUNT!=%%D"
  )
)
if "!APP_COUNT!"=="0" (
  echo [錯誤] 找不到任何 redirect.config.js
  pause
  exit /b 1
)

set "APP=%~1"
set "NEWURL=%~2"

if "!APP!"=="" (
  echo 可選應用：
  for /l %%I in (1,1,!APP_COUNT!) do echo   %%I^) !APP_%%I!
  echo.
  set /p "CHOICE=選編號或輸入資料夾名: "
  if "!CHOICE!"=="" (
    echo 已取消。
    exit /b 0
  )
  set "APP="
  for /l %%I in (1,1,!APP_COUNT!) do (
    if /i "!CHOICE!"=="%%I" set "APP=!APP_%%I!"
    if /i "!CHOICE!"=="!APP_%%I!" set "APP=!APP_%%I!"
  )
  if "!APP!"=="" (
    echo [錯誤] 無效選擇：!CHOICE!
    pause
    exit /b 1
  )
)

if not exist "!APP!\redirect.config.js" (
  echo [錯誤] 找不到 !APP!\redirect.config.js
  pause
  exit /b 1
)

for /f "usebackq delims=" %%U in (`powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\update-redirect-url.ps1" -App "!APP!" -ReadOnly`) do set "OLDURL=%%U"

echo.
echo 應用：!APP!
echo 目前：!OLDURL!
echo.

if "!NEWURL!"=="" set /p "NEWURL=新網址 (https://...): "
if "!NEWURL!"=="" (
  echo 已取消。
  exit /b 0
)

set "IP_URL=!NEWURL!"
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -Command ".\scripts\update-redirect-url.ps1 -App '!APP!' -Url $env:IP_URL"`) do set "RESULT=%%R"
if errorlevel 1 (
  echo [錯誤] 寫入失敗
  pause
  exit /b 1
)

if /i "!RESULT:~0,9!"=="UNCHANGED" (
  echo 網址沒變，不推送。
  pause
  exit /b 0
)

echo !RESULT!
echo.
echo 準備 commit + push...
git pull --ff-only origin main
if errorlevel 1 echo [警告] pull 失敗，仍嘗試繼續...

git add "!APP!\redirect.config.js"
git -c user.name="YijiaMango" -c user.email="yijiacccsss@gmail.com" commit -m "Update !APP! redirect URL."
if errorlevel 1 (
  echo [錯誤] commit 失敗
  pause
  exit /b 1
)

git push origin main
if errorlevel 1 (
  echo [錯誤] push 失敗
  pause
  exit /b 1
)

echo.
echo 完成。Pages：https://yijiamango.github.io/Innerpage_SaaS/!APP!/
echo.
pause
endlocal
