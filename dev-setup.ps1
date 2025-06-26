# Script per configurare l'ambiente di sviluppo node-red-contrib-s7
# Configurazione per Windows 10 con Visual Studio Code

param(
    [string]$NodeRedPath = "C:\Users\gem\.node-red",
    [string]$ProjectPath = "C:\Users\gem\Documents\_gemCode\node-red-contrib-s7",
    [switch]$Force
)

function Write-Status {
    param([string]$Message, [string]$Color = "Green")
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $Color
}

function Write-Error-Status {
    param([string]$Message)
    Write-Status $Message "Red"
}

function Write-Warning-Status {
    param([string]$Message)
    Write-Status $Message "Yellow"
}

# Verifica che Node-RED sia installato
if (-not (Test-Path $NodeRedPath)) {
    Write-Error-Status "Cartella Node-RED non trovata: $NodeRedPath"
    Write-Status "Installando Node-RED..." "Yellow"
    npm install -g --unsafe-perm node-red
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Status "Errore nell'installazione di Node-RED"
        exit 1
    }
}

# Verifica che il progetto esista
if (-not (Test-Path $ProjectPath)) {
    Write-Error-Status "Cartella progetto non trovata: $ProjectPath"
    exit 1
}

Write-Status "Configurazione ambiente di sviluppo node-red-contrib-s7"
Write-Status "Node-RED Path: $NodeRedPath"
Write-Status "Project Path: $ProjectPath"

# Crea la cartella node_modules se non esiste
$nodeModulesPath = Join-Path $NodeRedPath "node_modules"
if (-not (Test-Path $nodeModulesPath)) {
    Write-Status "Creando cartella node_modules..."
    New-Item -ItemType Directory -Path $nodeModulesPath -Force | Out-Null
}

# Percorso del link simbolico
$linkPath = Join-Path $nodeModulesPath "node-red-contrib-s7"

# Rimuovi link esistente se presente e Force è specificato
if ((Test-Path $linkPath) -and $Force) {
    Write-Warning-Status "Rimuovendo link esistente..."
    if ((Get-Item $linkPath).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Remove-Item $linkPath -Force
    } else {
        Remove-Item $linkPath -Recurse -Force
    }
}

# Crea il link simbolico se non esiste
if (-not (Test-Path $linkPath)) {
    Write-Status "Creando link simbolico da $ProjectPath a $linkPath"
    
    # Verifica privilegi amministratore per i link simbolici
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($isAdmin) {
        cmd /c mklink /D "`"$linkPath`"" "`"$ProjectPath`""
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Link simbolico creato con successo"
        } else {
            Write-Error-Status "Errore nella creazione del link simbolico"
            exit 1
        }
    } else {
        Write-Warning-Status "Privilegi amministratore richiesti per i link simbolici"
        Write-Status "Copiando i file invece..."
        Copy-Item -Path $ProjectPath -Destination $linkPath -Recurse -Force
    }
} else {
    Write-Warning-Status "Link già esistente: $linkPath"
}

# Installa le dipendenze del progetto
Write-Status "Installando dipendenze del progetto..."
Push-Location $ProjectPath
try {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Status "Errore nell'installazione delle dipendenze"
        exit 1
    }
    Write-Status "Dipendenze installate con successo"
} finally {
    Pop-Location
}

# Crea file di configurazione per VSCode se non esiste
$vscodeDir = Join-Path $ProjectPath ".vscode"
if (-not (Test-Path $vscodeDir)) {
    Write-Status "Creando configurazione VSCode..."
    New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
}

# File launch.json per debug
$launchJsonPath = Join-Path $vscodeDir "launch.json"
if (-not (Test-Path $launchJsonPath)) {
    $launchConfig = @"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Node-RED",
            "type": "node",
            "request": "launch",
            "program": "${env:APPDATA}\\npm\\node_modules\\node-red\\red.js",
            "args": [
                "--userDir",
                "C:\\Users\\gem\\.node-red",
                "--verbose"
            ],
            "console": "integratedTerminal",
            "restart": true,
            "env": {
                "NODE_ENV": "development"
            },
            "runtimeArgs": ["--inspect"]
        },
        {
            "name": "Debug Current Node",
            "type": "node",
            "request": "launch",
            "program": "${workspaceFolder}/red/s7.js",
            "console": "integratedTerminal",
            "env": {
                "NODE_ENV": "development"
            }
        }
    ]
}
"@
    Set-Content -Path $launchJsonPath -Value $launchConfig -Encoding UTF8
    Write-Status "File launch.json creato"
}

# File tasks.json per build tasks
$tasksJsonPath = Join-Path $vscodeDir "tasks.json"
if (-not (Test-Path $tasksJsonPath)) {
    $tasksConfig = @"
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Start Node-RED",
            "type": "shell",
            "command": "node-red",
            "args": [
                "--userDir",
                "C:\\Users\\gem\\.node-red",
                "--verbose"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "Install Dependencies",
            "type": "shell",
            "command": "npm",
            "args": ["install"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            }
        },
        {
            "label": "Restart Node-RED Link",
            "type": "shell",
            "command": "powershell",
            "args": [
                "-File",
                "${workspaceFolder}\\dev-setup.ps1",
                "-Force"
            ],
            "group": "build"
        }
    ]
}
"@
    Set-Content -Path $tasksJsonPath -Value $tasksConfig -Encoding UTF8
    Write-Status "File tasks.json creato"
}

# File settings.json per VSCode
$settingsJsonPath = Join-Path $vscodeDir "settings.json"
if (-not (Test-Path $settingsJsonPath)) {
    $settingsConfig = @"
{
    "files.associations": {
        "*.json": "jsonc"
    },
    "editor.insertSpaces": true,
    "editor.tabSize": 4,
    "files.encoding": "utf8",
    "files.eol": "\n",
    "javascript.suggest.autoImports": true,
    "typescript.suggest.autoImports": true
}
"@
    Set-Content -Path $settingsJsonPath -Value $settingsConfig -Encoding UTF8
    Write-Status "File settings.json creato"
}

Write-Status "Setup completato!" "Green"
Write-Status ""
Write-Status "Passi successivi:" "Cyan"
Write-Status "1. Apri il progetto in VSCode: code '$ProjectPath'" "White"
Write-Status "2. Usa Ctrl+Shift+P -> 'Tasks: Run Task' -> 'Start Node-RED' per avviare Node-RED" "White"
Write-Status "3. Apri http://localhost:1880 per accedere all'interfaccia Node-RED" "White"
Write-Status "4. Usa F5 per debuggare Node-RED direttamente da VSCode" "White"
Write-Status ""
Write-Status "Per testare le modifiche:" "Cyan"
Write-Status "- Modifica i file in '$ProjectPath'" "White"
Write-Status "- Riavvia Node-RED per vedere i cambiamenti" "White"
Write-Status "- Usa il debugger di VSCode per analizzare il codice" "White"