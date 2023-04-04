@Echo off
cd /d "%~dp0"
setlocal EnableDelayedExpansion

:: Program Version
Set programVersion=v1.1.0.5
:: Program Author
Set programAuthor=AzurieWolf
:: Set window Title
Title Unreal Engine Project Content Manager !programVersion! by !programAuthor!
:: Set CmdMenuSel path
Set "Path=%Path%;%~dp0Data\Bin"
:: Set background color
Color 0F
:: Set window width and height
Mode 120,30

:: Log file
Set log_file=log.txt

:: Settings file
Set SettingsJsonData=Settings.json
Set ProjectsJsonData=Projects.json
Set Content_Project_Json_Data_File_Name=UEPCM_Data

:: Get the JSON data processor
CALL Data\Bin\jq-win64-load.bat
CALL Data\Bin\load_settings.bat

IF NOT EXIST "%Content_Projects%" (
    Echo.Creating %Content_Projects% folder...
    mkdir "%Content_Projects%"
)

set ProjectFolder=
for /f "delims=" %%a in ('dir /a /b "%Content_Projects%"') do set ProjectFolder=%%a

:StartMenu
CALL Data\Bin\load_settings.bat
cls
Echo.Welcome to Unreal Engine Project Content Manager !programVersion! by !programAuthor!.
Echo.
Echo.This program allows you to quickly create and/or switch your content folders for your Hogwarts Legacy UE project.
Echo.
Echo.You should start by going to Settings to set your Directories for both your
Echo.Projects Content Folder and your Content Projects Folder.
Echo.
Echo.This is temporary until i finish this feature but
Echo.If you have an existing project with content inside of it.
Echo.You'll have to add the UEPCM_Data file to your content folder manually
Echo.before setting the directory of the project content folder.
Echo.Navigate to the root folder of this program and open the
Echo.UEPCM_Data File Folder and open the README.txt file for what to do next.
Echo.
Echo.Use your Keyboard or Mouse to navigate Menu Options.
Echo.
CmdMenuSel 0FF0 "Create A New Content Project" "Manage Projects" "Settings" "About" "Exit"
If /I "%Errorlevel%" == "1" (
    Goto :CreateNewProjectContentFolder
)
If /I "%Errorlevel%" == "2" (
    for /F %%i in ('dir /b "%Content_Projects%"') do (
        :: Folder is not empty
        goto :ProjectsManager
    )
    :: Folder is empty
    echo.
    echo.Your projects folder is empty...
    pause
    Goto :StartMenu
)
If /I "%Errorlevel%" == "3" (
    Goto :Settings
)
If /I "%Errorlevel%" == "4" (
    Goto :about
)
If /I "%Errorlevel%" == "5" (
    Goto :Exit
)

:about
cls
echo.Unreal Engine Project Content Manager !programVersion!
echo.
echo.Created by AzurieWolf
echo.
echo.You can find me and all my socials/projects by opening the link below.
echo.
CmdMenuSel 0FF0 "Open Link in Browser" "Back"
If /I "%Errorlevel%" == "1" (
    echo.
    echo.
    start https://linktr.ee/azuriewolf
    Goto :about
)
If /I "%Errorlevel%" == "2" (
    Goto :StartMenu
)

:CreateNewProjectContentFolder
CALL Data\Bin\load_settings.bat
cls
Echo.Create a new content project.
Echo.
echo.WARNING... Project names cannot contain spaces.
echo.
echo.You can use Underscores, Dashes or Uppercase Letters
echo.
echo.Example:
echo."ProjectName, Project_Name, Project-Name"
echo."projectname, project_name, project-name"
echo.
for /F %%i in ('dir /b "%Content_Projects%"') do (
    echo.content projects = %%i
    echo.
    if /I "%%i"=="" (
        :: Folder is empty
        Goto :CreateNewProjectMenuA
    ) else (
        :: Folder is not empty
        Goto :CreateNewProjectMenuB
    )
)

:CreateNewProjectMenuA
CmdMenuSel 0FF0 "New Content Project" "Back"
If /I "%Errorlevel%" == "1" (
    Goto :NameNewProject
)
If /I "%Errorlevel%" == "2" (
    Goto :StartMenu
)

:CreateNewProjectMenuB
CmdMenuSel 0FF0 "New Content Project" "Open Projects Manager" "Back"
If /I "%Errorlevel%" == "1" (
    Goto :NameNewProject
)
If /I "%Errorlevel%" == "2" (
    Goto :ProjectsManager
)
If /I "%Errorlevel%" == "3" (
    Goto :StartMenu
)

:NameNewProject
:InputProjectName
cls
set NewProjectNameInput=
set vbscript="Data\Temps\inputbox.vbs"
set title="Please Enter Your Projects Name:"
set default=""

echo Set objShell = CreateObject("WScript.Shell") > %vbscript%
echo response = InputBox(%title%, "Input", %default%) >> %vbscript%
echo if response = "" then wscript.quit(1) >> %vbscript%
echo wscript.echo response>>%vbscript%

for /f "delims=" %%I in ('cscript //nologo %vbscript%') do set "NewProjectNameInput=%%I"

del %vbscript%

if "%NewProjectNameInput%"=="" (
    echo.Error: You either left the project name field empty or you cancelled the operation.
    pause
    Goto :CreateNewProjectContentFolder
) else (
    IF EXIST "%Content_Projects%\!NewProjectNameInput!" (
        Goto :NewCreateProjectError
    ) else (
        Goto :ContinueToCreateProject
    )
)

:NewCreateProjectError
cls
echo.A project with the name '!NewProjectNameInput!' already exists...
echo.
echo.Please enter a different name to continue...
echo.
pause
Goto :CreateNewProjectContentFolder

:ContinueToCreateProject
cls
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
IF NOT EXIST "%Content_Projects%\!NewProjectNameInput!" (
    CALL Data\Bin\jq-win64-load.bat
    mkdir "%Content_Projects%\%NewProjectNameInput%"

    robocopy /E "%New_PhoenixUProj_Content_Folder%" "%Content_Projects%\!NewProjectNameInput!"

    echo.Creating UEPCM_Data file...

    :: Create the UEPCM_Data file
    type nul > "%Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!"
    :: Set first property
    echo.{ "projectName": "!NewProjectNameInput!" } >> "%Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!"
    :: Add another property
    %jq% --arg newProperty "Inactive" ". + { "projectState": $newProperty }" "%Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!" > "%Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!.temp"
    move /y "%Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!.temp" "%Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!" > nul

    Goto :NewProjectCreated
)
Goto :CreateNewProjectContentFolder

:NewProjectCreated
IF EXIST "%Content_Projects%\!NewProjectNameInput!" (
    echo.
    echo.Successfully Created !NewProjectNameInput!.
    echo.
) ELSE (
    echo.
    echo.Failed to create !NewProjectNameInput!.
    echo.
)
pause
Goto :CreateNewProjectContentFolder

:: With the Project Manager you can Set your active project, Rename a project or Delete a project.
:ProjectsManager
cls
CALL Data\Bin\load_settings.bat

Set "folders="
Set "folderIndex=1"
Set "source_folder="
Set "selectedProject="

for /d %%a in ("%Content_Projects%\*") do (
    set "folder=%%~nxa"
    set "folders=!folders!|!folder!"
    set "folders[!folderIndex!]=!folder!"
    set /a "folderIndex+=1"
)

Set "LastIndex=!folderIndex!"
Set /a TotalProjectsCount="!folderIndex!-1"

CALL Data\Bin\jq-win64-load.bat

Set "currentlyActiveProject="

if exist "%content_folder%\%Content_Project_Json_Data_File_Name%" (
    for /f "delims=" %%i in ('call "%jq%" -r ".projectName" "%content_folder%\%Content_Project_Json_Data_File_Name%"') do ( set "projectName=%%i" )
    Set "currentlyActiveProject=!projectName!"
    Set currentlyActiveSourceDir="%Content_Projects%\!projectName!"
) else (
    Set "currentlyActiveProject=No Active Project"
)

Echo.Manage Projects
Echo.
Echo.Total Projects in Storage: %TotalProjectsCount%
Echo.
Echo.Currently Active Project: !currentlyActiveProject!
Echo.
CmdMenuSel 0FF0 %folders:|= % "Back"
If /I "%Errorlevel%" == "%LastIndex%" (
    Goto :StartMenu
)

Set selectedProject=!folders[%Errorlevel%]!
Set "source_folder=%Content_Projects%\!folders[%Errorlevel%]!"

:: Project Manage Options
cls
echo.Selected Project: !selectedProject!
echo.
CmdMenuSel 0FF0 "Set As Active Project" "Rename" "Permanently Delete" "Back"
If /I "%Errorlevel%" == "1" (
    for /F %%i in ('dir /b "%Content_Projects%"') do (
        :: Folder is not empty
        goto :SetAsActiveProject
    )
    :: Folder is empty
    echo.
    echo.Your projects folder is empty...
    pause
    Goto :ProjectsManager
)
If /I "%Errorlevel%" == "2" (
    Goto :RenameSelectedProject
)
If /I "%Errorlevel%" == "3" (
    Goto :DeleteSelectedProject
)
If /I "%Errorlevel%" == "4" (
    Goto :ProjectsManager
)

:SetAsActiveProject
if exist "%content_folder%\%Content_Project_Json_Data_File_Name%" (
    If "!selectedProject!" == "!currentlyActiveProject!" (
        Goto :SetAsActiveProject
    ) else (
        Goto :SwitchActiveProjectToSelectedProject
    )
) else (
    echo.No project files were found in the content folder.
)

:SetAsActiveProject
cls
echo.Are you sure you want to set '!selectedProject!' as the active project?
echo.
CmdMenuSel 0FF0 "Confirm" "Cancel"
If /I "%Errorlevel%" == "1" (
    Goto :ContinueToSetActiveProject
)
If /I "%Errorlevel%" == "2" (
    Goto :ProjectsManager
)

:ContinueToSetActiveProject
Set "Content_Folder_Name=Content"
echo.Moving for the first time!
robocopy /move /s /e "%source_folder%" "%content_folder%"
Echo.Finished moving selected project!
pause
Goto :ProjectsManager

:SwitchActiveProjectToSelectedProject
cls
echo.Switch Currently Active Project
echo.
echo.You Selected: !selectedProject!
echo.Currently Active Project: !currentlyActiveProject!
echo.
echo.Would you like to switch to !selectedProject!?
echo.
CmdMenuSel 0FF0 "Confirm" "Cancel"
If /I "%Errorlevel%" == "1" (
    Goto :ContinueToSwitchActiveProjectToSelectedProject
)
If /I "%Errorlevel%" == "2" (
    Goto :ProjectsManager
)
:ContinueToSwitchActiveProjectToSelectedProject
CALL Data\Bin\jq-win64-load.bat
:: Create a temp directory and move existing contents there
mkdir "!content_folder_temp!"
echo.Moving %content_folder% to temp dir
robocopy /move /s /e "%content_folder%" !content_folder_temp!
rmdir %content_folder% /s /q
mkdir "%content_folder%"

:: Create a temp directory and move selected project from Content_Projects to temp dir
mkdir "!Content_Projects_temp!"
echo.Moving %Content_Projects%\!selectedProject! to temp dir
robocopy /move /s /e "%Content_Projects%\%selectedProject%" !Content_Projects_temp!
rmdir "%Content_Projects%\%selectedProject%" /s /q

:: Move temp files from the Content_Projects_temp folder to the content folder.
echo.Moving Content_Projects_temp files Content folder
robocopy /move /s /e "!Content_Projects_temp!" "%content_folder%"

:: Move temp files from content_folder_temp to the Content_Projects folder.
for /f "delims=" %%i in ('call "%jq%" -r ".projectName" "%content_folder_temp%\%Content_Project_Json_Data_File_Name%"') do ( set "GetProjectNameFromTemp=%%i" )
mkdir "%Content_Projects%\%GetProjectNameFromTemp%"
robocopy /move /s /e "!content_folder_temp!" "%Content_Projects%\%GetProjectNameFromTemp%"

cls
echo.Your active project has been successfully set to "%selectedProject%".
echo.
pause
Goto :ProjectsManager
:::::::::

:RenameSelectedProject
cls
CALL Data\Bin\jq-win64-load.bat

set "oldProjectName=%Content_Projects%\!selectedProject!"

set projectRename=
set vbscript="Data\Temps\inputbox.vbs"
set title="Rename !selectedProject! to:"
set default="!selectedProject!"

echo Set objShell = CreateObject("WScript.Shell") > %vbscript%
echo response = InputBox(%title%, "Input", %default%) >> %vbscript%
echo if response = "" then wscript.quit(1) >> %vbscript%
echo wscript.echo response>>%vbscript%

for /f "delims=" %%I in ('cscript //nologo %vbscript%') do set "projectRename=%%I"

if "%projectRename%"=="" (
    echo There was a problem: You either left the project name field empty or you cancelled the operation.
    pause
    Goto :ProjectsManager
) else (
    if "%projectRename%"=="!selectedProject!" (
        Goto :RenameError
    ) else (
        echo User entered "%projectRename%".
        Goto :ContinueToRenameProject
    )
)

:RenameError
echo.Error: You're trying to rename !selectedProject! to !projectRename!...
echo.
echo.Please enter a different name to continue...
echo.
pause
Goto :RenameSelectedProject

:ContinueToRenameProject
cls
Echo.Are you sure you'd like to rename your project '!selectedProject!' to '!projectRename!'?
echo.
CmdMenuSel 0FF0 "Confirm" "Cancel"
If /I "%Errorlevel%" == "1" (
    Goto :ProjectManagerRename
)
If /I "%Errorlevel%" == "2" (
    Goto :ProjectsManager
)
:ProjectManagerRename
cls
IF EXIST "%Content_Projects%\!selectedProject!" (
    echo.Attempting to rename '!selectedProject!'...

    echo.Using jq to update the projectName property in the UEPCM_Data file...
    %jq% ".projectName=\"%projectRename%\"" "%Content_Projects%\!selectedProject!\!Content_Project_Json_Data_File_Name!" > "%Content_Projects%\!selectedProject!\%Content_Project_Json_Data_File_Name%.tmp"

    echo.Replacing the original JSON file with the updated project name...
    move /y "%Content_Projects%\!selectedProject!\%Content_Project_Json_Data_File_Name%.tmp" "%Content_Projects%\!selectedProject!\%Content_Project_Json_Data_File_Name%" > nul 2>&1

    echo.Renaming the project folder...
    ren "%Content_Projects%\!selectedProject!" "%projectRename%"
)
IF NOT EXIST "%Content_Projects%\!selectedProject!" (
    echo.Successfully Renamed '!selectedProject!' to '!projectRename!'...
    echo.
) else (
    echo.Failed to Rename '!selectedProject!' to '!projectRename!'...
    echo.
)
pause
Goto :ProjectsManager

:DeleteSelectedProject
cls
echo.Are you sure you'd like to delete '!selectedProject!'?
echo.
echo.WARNING: Once deleted this cannot be undone!
echo.
CmdMenuSel 0FF0 "Confirm" "Cancel"
If /I "%Errorlevel%" == "1" (
    Goto :ConfirmDeleteProject
)
If /I "%Errorlevel%" == "2" (
    Goto :ProjectsManager
)
:ConfirmDeleteProject
IF EXIST "%Content_Projects%\!selectedProject!" (
    cls
    ::Echo.Deleting '!selectedProject!'
    rmdir "%Content_Projects%\!selectedProject!" /s /q
)
IF NOT EXIST "%Content_Projects%\!selectedProject!" (
    echo.Successfully deleted '!selectedProject!'
    echo.
    pause
) else (
    echo.Failed to delete '!selectedProject!'
    echo.
    pause
)
Goto :ProjectsManager

:Settings
cls
echo.Settings
echo.
CmdMenuSel 0FF0 "Set Directories" "Back"
If /I "%Errorlevel%" == "1" (
    Goto :SetDirectories
)
If /I "%Errorlevel%" == "2" (
    Goto :StartMenu
)

:SetDirectories
CALL Data\Bin\load_settings.bat
cls
echo.Set Directories
echo.
echo.Set the directory of your unreal project content folder.
echo.(The Project Content Folder Directory is the location of your UE Project Content Folder)
echo.Current Directory: (%content_folder%)
echo.
echo.Set the directory of your Projects Folder.
echo.(The Projects Directory is where all of your projects are created and/or stored)
echo.Current Directory: (%Content_Projects%)
echo.
CmdMenuSel 0FF0 "Set Project Content Folder Directory" "Set Projects Directory" "Back"
If /I "%Errorlevel%" == "1" (
    Goto :ProjectContentDir
)
If /I "%Errorlevel%" == "2" (
    Goto :ContentProjectsDir
)
If /I "%Errorlevel%" == "3" (
    Goto :Settings
)
Goto :StartMenu

:ProjectContentDir
set ps_fn=Data\Temps\PowerShell_Temp.ps1
echo [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") ^| out-null > %ps_fn%
echo $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog >> %ps_fn%
echo $FolderBrowserDialog.RootFolder = "Desktop" >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath = "%~dp0" >> %ps_fn%
echo $FolderBrowserDialog.Description = "Select your content projects directory:" >> %ps_fn%
echo $FolderBrowserDialog.ShowDialog() ^| Out-Null >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath >> %ps_fn%

for /F "tokens=* usebackq" %%a in (`powershell -executionpolicy bypass -file %ps_fn%`) do if not "%%a"=="Cancel" set "ProjectContentFolder=%%a"
del %ps_fn%

CALL Data\Bin\jq-win64-load.bat

set tempFile=%SettingsJsonData%.tmp

%jq% --arg newDir "%ProjectContentFolder%" ".UE_ProjectContentDir = $newDir" "%SettingsJsonData%" > "%tempFile%"

if errorlevel 1 (
    echo Error: Failed to update JSON file "%SettingsJsonData%".
    del %tempFile%
    Goto :SetDirectories
)

:: Replace original JSON file with updated file
move /y "%tempFile%" "%SettingsJsonData%" > nul

echo.
echo Updated path in %SettingsJsonData% to %ProjectContentFolder%
pause
Goto :SetDirectories

:ContentProjectsDir
set ps_fn=Data\Temps\PowerShell_Temp.ps1
echo [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") ^| out-null > %ps_fn%
echo $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog >> %ps_fn%
echo $FolderBrowserDialog.RootFolder = "Desktop" >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath = "%~dp0" >> %ps_fn%
echo $FolderBrowserDialog.Description = "Select your content projects directory:" >> %ps_fn%
echo $FolderBrowserDialog.ShowDialog() ^| Out-Null >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath >> %ps_fn%

for /F "tokens=* usebackq" %%a in (`powershell -executionpolicy bypass -file %ps_fn%`) do if not "%%a"=="Cancel" set "ContentProjectsDirectory=%%a"
del %ps_fn%

CALL Data\Bin\jq-win64-load.bat

set tempFile=%SettingsJsonData%.tmp

%jq% --arg newDir "%ContentProjectsDirectory%" ".UE_ContentProjectsDir = $newDir" "%SettingsJsonData%" > "%tempFile%"

if errorlevel 1 (
    echo Error: Failed to update JSON file "%SettingsJsonData%".
    del %tempFile%
    Goto :SetDirectories
)

:: Replace original JSON file with updated file
move /y "%tempFile%" "%SettingsJsonData%" > nul

echo.
echo Updated path in %SettingsJsonData% to %ContentProjectsDirectory%
pause
Goto :SetDirectories

:Exit
Echo.Exiting...
timeout /t 1 >nul
exit