@echo off
REM Script para Windows CMD que chama o script bash
REM Uso: generate-sts-token.bat <profile-name> [duration-seconds] [--export-cmd]

REM Verifica se Git Bash está disponível
where bash >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Erro: Git Bash nao encontrado. Instale o Git for Windows.
    echo Download: https://git-scm.com/download/win
    exit /b 1
)

REM Executa o script bash
if "%3"=="--export-cmd" (
    REM Modo export para CMD
    bash "%~dp0generate-sts-token.sh" %1 %2 --export-cmd
) else (
    REM Modo normal
    bash "%~dp0generate-sts-token.sh" %*
)
