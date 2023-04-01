@Echo off
setlocal EnableDelayedExpansion

:: Program Version
Set programVersion=v1.0
:: Program Author
Set programAuthor=AzurieWolf
:: Set window Title
Title Unreal Engine Project Content Manager !programVersion! by !programAuthor!
:: Set CmdMenuSel path
Set "Path=%Path%;%~dp0UE-PCM\Bin"
:: Set background color
Color 0F
:: Set window width and height
Mode 120,30

:: Log file
Set log_file=log.txt

:: Settings file
Set SettingsJsonData=Settings.json

:: Get the JSON data processor
Set "jq=%~dp0UE-PCM\Bin\jq-win64.exe"
if not exist "%jq%" (
    echo Error: JSON processor not found at "%jq%".
    pause
    exit /b 1
)

CALL UE-PCM\Bin\load_settings.bat

set ProjectFolder=
for /f "delims=" %%a in ('dir /a /b "%UE_Content_Projects%"') do set ProjectFolder=%%a

:StartMenu
CALL UE-PCM\Bin\load_settings.bat
cls
Echo.Welcome to Unreal Engine Project Content Manager !programVersion! by !programAuthor!.
Echo.
Echo.This program allows you to quickly create and/or switch your content folders for your Hogwarts Legacy UE project.
Echo.
Echo.Use your Keyboard or Mouse to navigate Menu Options.
Echo.
CmdMenuSel 0FF0 "Create New Project Content Folder" "Project Switcher" "Delete A Project" "Set Directories" "Exit"
If /I "%Errorlevel%" == "1" (
    Goto :CreateNewProjectContentFolder
)
If /I "%Errorlevel%" == "2" (
    for /F %%i in ('dir /b "%UE_Content_Projects%"') do (
        :: Folder is not empty
        goto :ProjectSwitcher
    )
    :: Folder is empty
    echo.
    echo.You have not created any projects yet...
    timeout /t 2 >nul
    Goto :StartMenu
)
If /I "%Errorlevel%" == "3" (
    for /F %%i in ('dir /b "%UE_Content_Projects%"') do (
        :: Folder is not empty
        goto :ProjectsManager
    )
    :: Folder is empty
    echo.
    echo.You have not created any projects yet...
    timeout /t 2 >nul
    Goto :StartMenu
)
If /I "%Errorlevel%" == "4" (
    Goto :SetDirectories
)
If /I "%Errorlevel%" == "5" (
    Goto :Exit
)

:CreateNewProjectContentFolder
CALL UE-PCM\Bin\load_settings.bat
cls
Echo.Create a new project content folder.
Echo.
CmdMenuSel 0FF0 "Create New Project" "Cancel"
If /I "%Errorlevel%" == "1" (
    Goto :ContinueToCreateProject
)
If /I "%Errorlevel%" == "2" (
    Goto :StartMenu
)
:ContinueToCreateProject
Echo.
set /p NewProjectNameInput=Enter project name: 
set NewProjectNameInput=%NewProjectNameInput: =%
IF EXIST "%UE_Content_Projects%\!NewProjectNameInput!" (
    Goto :ProjectAlreadyExists
)
Echo.
Echo.Are you sure you'd like to create !NewProjectNameInput!?
Echo.
CmdMenuSel 0FF0 "Confirm" "Cancel"
If /I "%Errorlevel%" == "1" (
    Goto :CreateContentFolder
)
If /I "%Errorlevel%" == "2" (
    Goto :StartMenu
)

:CreateContentFolder
Echo.
Echo.Creating !NewProjectNameInput! project folder...
IF NOT EXIST "%UE_Content_Projects%\!NewProjectNameInput!" (
    mkdir "%UE_Content_Projects%\%NewProjectNameInput%"
    timeout /t 1 >nul

    robocopy /E "%new_content_project_folder%" "%UE_Content_Projects%\!NewProjectNameInput!"
    timeout /t 1 >nul

    echo.Creating UE-PCM_Data file...
    set "UE-PCM_Data={"
    set "UE-PCM_Data=!UE-PCM_Data!"projectName": "!NewProjectNameInput!"
    set "UE-PCM_Data=!UE-PCM_Data!"}"

    echo.!UE-PCM_Data! > "%UE_Content_Projects%\%NewProjectNameInput%\UE-PCM_Data"

    Goto :NewProjectCreated
)
Goto :CreateNewProjectContentFolder

:ProjectAlreadyExists
echo.
echo.A project already exists with that name.
echo.Please try again with a different name.
echo.
timeout /t 3 >nul
Goto :CreateNewProjectContentFolder

:NewProjectCreated
IF EXIST "%UE_Content_Projects%\!NewProjectNameInput!" (
    echo.
    echo.Successfully Created !NewProjectNameInput!.
    echo.
) ELSE (
    echo.
    echo.Failed to create !NewProjectNameInput!.
    echo.
)

timeout /t 3 >nul
Goto :StartMenu

:ProjectSwitcher
CALL UE-PCM\Bin\load_settings.bat
:: Directories and folders
Set "folders="
Set "folderIndex=1"
Set "source_folder="
Set "selectedProject="

:: Get the JSON data processor
Set "jq=%~dp0UE-PCM\Bin\jq-win64.exe"
if not exist "%jq%" (
    echo Error: JSON processor not found at "%jq%".
    pause
    exit /b 1
)

Set "PCM_JSON_Data=UE-PCM_Data"

if exist "%content_folder%\%PCM_JSON_Data%" (
    for /f "delims=" %%i in ('call "%jq%" -r ".projectName" "%content_folder%\%PCM_JSON_Data%"') do ( set "projectName=%%i" )
    Set "currentlyActiveProject=!projectName!"
    Set currentlyActiveSourceDir="%UE_Content_Projects%\!projectName!"
)

Set "projectName="

for /d %%a in ("%UE_Content_Projects%\*") do (
    set "folder=%%~nxa"
    set "folders=!folders!|!folder!"
    set "folders[!folderIndex!]=!folder!"
    set /a "folderIndex+=1"
)

Set "LastIndex=!folderIndex!"

cls
Echo.Project Content Switcher
Echo.
Echo.Currently Active Project: !currentlyActiveProject!
Echo.

CmdMenuSel 0FF0 %folders:|= % "Back"
If /I "%Errorlevel%" == "%LastIndex%" (
    Goto :StartMenu
)

cls

::Echo.You Selected Project: !folders[%Errorlevel%]!
Set selectedProject=!folders[%Errorlevel%]!

set "source_folder=%UE_Content_Projects%\!folders[%Errorlevel%]!"
::Echo.
::Echo.Source folder "!source_folder!"
::Echo.Destination folder: "%content_folder%"
::Echo.

if exist "%content_folder%\%PCM_JSON_Data%" (
    echo.A project already exists in the content folder.
    echo.
    echo.You Selected: !selectedProject!
    echo.Currently Active Project: !currentlyActiveProject!
    echo.
    echo.Would you like to switch to !selectedProject!?
    echo.

    If "!selectedProject!" == "!currentlyActiveProject!" (
        Goto :ProjectSwitcher
    ) else (
        Goto :existingProject
    )
) else (
    echo No project files were found in the content folder.
)

Goto :moveSelectedProject

Goto :ProjectSwitcher

:existingProject
CmdMenuSel 0FF0 "Switch Active Project To !selectedProject!" "Back"
IF /I "%Errorlevel%" == "1" (
    cls
    echo.Switching current project to !selectedProject!...
    echo.
    Goto :moveActiveProject
)
IF /I "%Errorlevel%" == "2" (
    Goto :ProjectSwitcher
    echo.%Errorlevel%
)
Goto :ProjectSwitcher

:moveSelectedProject
robocopy /MOVE /E "%source_folder%" "%content_folder%"
IF NOT EXIST "%source_folder%\%folder_name%" (
  ECHO "%source_folder%\!folder_name!" Folder does not exist
  mkdir "%source_folder%\%folder_name%"
)
Echo.Finished moving selected project!
Goto :ProjectSwitcher

:moveActiveProject
:: Create a temp directory and move existing contents there
mkdir "!content_folder_temp!"
echo.Moving %content_folder% to temp dir
robocopy /E "%content_folder%" !content_folder_temp!

rmdir %content_folder% /s /q
mkdir "%content_folder%"

:: Create a temp directory and move selected project from UE_Content_Projects to temp dir
mkdir "!UE_Content_Projects_temp!"
echo.Moving %UE_Content_Projects%\!selectedProject! to temp dir
robocopy /E "%UE_Content_Projects%\%selectedProject%" !UE_Content_Projects_temp!
rmdir "%UE_Content_Projects%\%selectedProject%" /s /q

:: Move temp files from the UE_Content_Projects_temp folder to the content folder.
echo.Moving UE_Content_Projects_temp files Content folder
robocopy /E "!UE_Content_Projects_temp!" "%content_folder%"

:: Move temp files from content_folder_temp to the UE_Content_Projects folder.
for /f "delims=" %%i in ('call "%jq%" -r ".projectName" "%content_folder_temp%\%PCM_JSON_Data%"') do ( set "GetProjectNameFromTemp=%%i" )
mkdir "%UE_Content_Projects%\%GetProjectNameFromTemp%"
echo.Moving content_folder_temp files UE_Content_Projects folder.
robocopy /E "!content_folder_temp!" "%UE_Content_Projects%\%GetProjectNameFromTemp%"

echo.Removing UE_Content_Projects_temp files
rmdir !UE_Content_Projects_temp! /s /q
echo.Removing content_folder_temp files
rmdir !content_folder_temp! /s /q
timeout /t 1 >nul

IF NOT EXIST %content_folder% (
  ECHO !content_folder! Folder does not exist
  mkdir %content_folder%
)
Echo.Finished switching active project!
Goto :ProjectSwitcher

:: Project manager is used to delete unwanted projects.
:ProjectsManager
CALL UE-PCM\Bin\load_settings.bat
cls
echo.Delete unwanted projects from here.
echo.
echo.WARNING: Once deleted this cannot be undone!
echo.
echo.Currently Active Project: !currentlyActiveProject!
echo.
Set "folders="
Set "folderIndex=1"
Set "source_folder="
Set "selectedProject="

for /d %%a in ("%UE_Content_Projects%\*") do (
    set "folder=%%~nxa"
    set "folders=!folders!|!folder!"
    set "folders[!folderIndex!]=!folder!"
    set /a "folderIndex+=1"
)
Set "LastIndex=!folderIndex!"
CmdMenuSel 0FF0 %folders:|= % "Back"
If /I "%Errorlevel%" == "%LastIndex%" (
    Goto :StartMenu
)
Set selectedProject=!folders[%Errorlevel%]!
echo.!selectedProject!
echo.
echo.Are you sure you'd like to delete this project?
echo.
CmdMenuSel 0FF0 "Permanently Delete Project '!selectedProject!' From Projects" "Cancel"
If /I "%Errorlevel%" == "1" (
    Goto :DeleteSelectedProject
)
If /I "%Errorlevel%" == "2" (
    Goto :StartMenu
)

:DeleteSelectedProject
IF EXIST "%UE_Content_Projects%\!selectedProject!" (
    echo.
    Echo.Deleting '!selectedProject!'
    rmdir "%UE_Content_Projects%\!selectedProject!" /s /q
)
timeout /t 1 >nul
IF NOT EXIST "%UE_Content_Projects%\!selectedProject!" (
    echo.
    echo.Successfully deleted '!selectedProject!'
    echo.
) else (
    echo.
    echo.Failed to delete '!selectedProject!'
    echo.
)
timeout /t 3 >nul
Goto :StartMenu

:SetDirectories
CALL UE-PCM\Bin\load_settings.bat
cls
echo.Set the directory of your unreal project content folder.
echo.(The Project Content Folder Directory is the location of your UE Project Content Folder)
echo.Current Directory: (%UE_ProjectContentDir%)
echo.
echo.Set the directory of your Projects Folder.
echo.(The Projects Directory is where all of your projects are created and/or stored)
echo.Current Directory: (%UE_ContentProjectsDir%)
echo.
CmdMenuSel 0FF0 "Set Project Content Folder Directory" "Set Projects Directory" "Back"
If /I "%Errorlevel%" == "1" (
    Goto :UE_ProjectContentDir
)
If /I "%Errorlevel%" == "2" (
    Goto :UE_ContentProjectsDir
)
If /I "%Errorlevel%" == "3" (
    Goto :StartMenu
)
Goto :StartMenu

:UE_ProjectContentDir
set ps_fn=ofd.ps1
echo [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") ^| out-null > %ps_fn%
echo $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog >> %ps_fn%
echo $FolderBrowserDialog.RootFolder = "Desktop" >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath = "%~dp0" >> %ps_fn%
echo $FolderBrowserDialog.Description = "Select your content projects directory:" >> %ps_fn%
echo $FolderBrowserDialog.ShowDialog() ^| Out-Null >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath >> %ps_fn%

for /F "tokens=* usebackq" %%a in (`powershell -executionpolicy bypass -file %ps_fn%`) do if not "%%a" == "Cancel" set "ProjectContentFolder=%%a"
del %ps_fn%

:: Update the JSON file with the selected directory
set jq=UE-PCM\Bin\jq-win64.exe
if not exist "%jq%" (
    echo Error: JSON processor not found at "%jq%".
    pause
    exit /b 1
)

set tempFile=%SettingsJsonData%.tmp

%jq% --arg newDir "%ProjectContentFolder%" ".UE_ProjectContentDir = $newDir" "%SettingsJsonData%" > "%tempFile%"

if errorlevel 1 (
    echo Error: Failed to update JSON file "%SettingsJsonData%".
    del %tempFile%
    timeout /t 2 >nul
    Goto :SetDirectories
)

:: Replace original JSON file with updated file
move /y "%tempFile%" "%SettingsJsonData%" > nul

echo.
echo Updated path in %SettingsJsonData% to %ProjectContentFolder%
timeout /t 3 >nul
Goto :SetDirectories

:UE_ContentProjectsDir
set ps_fn=ofd.ps1
echo [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") ^| out-null > %ps_fn%
echo $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog >> %ps_fn%
echo $FolderBrowserDialog.RootFolder = "Desktop" >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath = "%~dp0" >> %ps_fn%
echo $FolderBrowserDialog.Description = "Select your content projects directory:" >> %ps_fn%
echo $FolderBrowserDialog.ShowDialog() ^| Out-Null >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath >> %ps_fn%

for /F "tokens=* usebackq" %%a in (`powershell -executionpolicy bypass -file %ps_fn%`) do if not "%%a" == "Cancel" set "ContentProjectsDirectory=%%a"
del %ps_fn%

:: Update the JSON file with the selected directory
set jq=UE-PCM\Bin\jq-win64.exe
if not exist "%jq%" (
    echo Error: JSON processor not found at "%jq%".
    pause
    exit /b 1
)

set tempFile=%SettingsJsonData%.tmp

%jq% --arg newDir "%ContentProjectsDirectory%" ".UE_ContentProjectsDir = $newDir" "%SettingsJsonData%" > "%tempFile%"

if errorlevel 1 (
    echo Error: Failed to update JSON file "%SettingsJsonData%".
    del %tempFile%
    timeout /t 2 >nul
    Goto :SetDirectories
)

:: Replace original JSON file with updated file
move /y "%tempFile%" "%SettingsJsonData%" > nul

echo.
echo Updated path in %SettingsJsonData% to %ContentProjectsDirectory%
timeout /t 3 >nul
Goto :SetDirectories

:Exit
Echo.Exiting...
timeout /t 1 >nul
exit