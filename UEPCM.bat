@Echo off
cd /d "%~dp0"
setlocal EnableDelayedExpansion

:: Program Version
Set programVersion=v1.1.1.0
:: Program Author
Set programAuthor=AzurieWolf
:: Set window Title
Title Unreal Engine Project Content Manager !programVersion! by !programAuthor!
:: Set CmdMenuSel path
set "Path=%Path%;%~dp0Data\Bin"
:: Set background color
Color 0F
:: Set window width and height
Mode 120,30

:: Log file
set log_file=log.txt

:: Settings file
set SettingsJsonData=Settings.json
set ProjectsJsonData=Projects.json
set Content_Project_Json_Data_File_Name=UEPCM_Data
set TimeoutTime=10

:: Get the JSON data processor
CALL Data\Bin\jq-win64-load.bat
CALL Data\Bin\load_settings.bat

IF NOT EXIST "%UEPCM_Content_Projects%" (
    Echo.Creating %UEPCM_Content_Projects% folder...
    mkdir "%UEPCM_Content_Projects%"
)

set ProjectFolder=
for /f "delims=" %%a in ('dir /a /b "%UEPCM_Content_Projects%"') do set ProjectFolder=%%a

:StartMenu
CALL Data\Bin\load_settings.bat
cls
echo.Welcome to Unreal Engine Project Content Manager !programVersion! by !programAuthor!.
echo.
echo.Go to Getting Started for info on how this program works.
echo.
echo.Use your Keyboard or Mouse to navigate Menu Options.
echo.
CmdMenuSel 0FF0 "Create A New Content Project" "Manage Projects" "Settings" "Getting Started" "Download PhoenixUProj Content Files" "About" "Exit"
If /I "%Errorlevel%" == "1" (
    Goto :CreateNewProjectContentFolder
)
If /I "%Errorlevel%" == "2" (
    for /F %%i in ('dir /b "%UEPCM_Content_Projects%"') do (
        :: Folder is not empty
        goto :ProjectsManager
    )
    :: Folder is empty
    echo.
    echo.Your projects storage folder is empty.
    timeout /t %TimeoutTime%
    Goto :StartMenu
)
If /I "%Errorlevel%" == "3" (
    Goto :Settings
)
If /I "%Errorlevel%" == "4" (
    Goto :GettingStarted
)
If /I "%Errorlevel%" == "5" (
    Goto :DownloadOrUpdatePhoenixContentFiles
)
If /I "%Errorlevel%" == "6" (
    Goto :About
)
If /I "%Errorlevel%" == "7" (
    Goto :Exit
)

:GettingStarted
cls
echo.^<==== Setting your UE Project Content Directory ====^>
echo.
echo.To get started using UEPCM go to Settings ^> Set Directories ^> Set UE Project Content Folder Directory.
echo.
echo.(Your "UE Project Content Folder" is the folder called "Content", located inside of your "PhoenixUProj" folder)
echo.
echo.
echo.^<==== Setting your UEPCM Content Projects Storage Directory ====^>
echo.
echo.You can also change the location of where UEPCM stores your Content Projects.
echo.
echo.(By default, UEPCM stores your content projects in the root folder of the program,
echo.located inside of the folder called "%UEPCM_Content_Projects_Default_Folder_Name%")
echo.
CmdMenuSel 0FF0 "Back"
If /I "%Errorlevel%" == "1" (
    Goto :StartMenu
)

:About
cls
echo.Unreal Engine Project Content Manager !programVersion!
echo.
echo.Created by AzurieWolf
echo.
echo.This program allows you to manage your project content folder for your Hogwarts Legacy UE project.
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
echo.Create a new content project.
echo.
for /f %%i in ('dir /b "%UEPCM_Content_Projects%"') do (
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
:InputLoop
cls
set NewProjectNameInput=
set vbscript="Data\Temps\inputbox.vbs"
set title="Please Enter Your Projects Name:"
set default="%EnteredText%"

echo Set objShell = CreateObject("WScript.Shell") > %vbscript%
echo response = InputBox(%title%, "Input", %default%) >> %vbscript%
echo if response = "" then wscript.quit(1) >> %vbscript%
echo wscript.echo response>>%vbscript%

for /f "delims=" %%I in ('cscript //nologo %vbscript%') do set "NewProjectNameInput=%%I"

set EnteredText=%NewProjectNameInput%

:: Check if the input contains spaces
echo "%NewProjectNameInput%"| find " " > nul
if %errorlevel% equ 0 (
    :: Replace spaces with underscores
    set "NewProjectNameInput=%NewProjectNameInput: =_%"
    set "EnteredText=%EnteredText: =_%"
)

del %vbscript%

if "%NewProjectNameInput%"=="" (
    echo.Error: You either left the project name field empty or you cancelled the operation.
    timeout /t %TimeoutTime%
    Goto :CreateNewProjectContentFolder
) else (
    IF EXIST "%UEPCM_Content_Projects%\!NewProjectNameInput!" (
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
timeout /t %TimeoutTime%
Goto :InputProjectName

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
IF NOT EXIST "%UEPCM_Content_Projects%\!NewProjectNameInput!" (
    CALL Data\Bin\jq-win64-load.bat
    mkdir "%UEPCM_Content_Projects%\%NewProjectNameInput%"

    robocopy /E "%New_PhoenixUProj_Content_Folder%" "%UEPCM_Content_Projects%\!NewProjectNameInput!"

    echo.Creating UEPCM_Data file...

    :: Create the UEPCM_Data file
    type nul > "%UEPCM_Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!"
    :: Set first property
    echo.{ "projectName": "!NewProjectNameInput!" } >> "%UEPCM_Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!"
    :: Add another property
    %jq% --arg newProperty "Inactive" ". + { "projectState": $newProperty }" "%UEPCM_Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!" > "%UEPCM_Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!.temp"
    move /y "%UEPCM_Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!.temp" "%UEPCM_Content_Projects%\%NewProjectNameInput%\!Content_Project_Json_Data_File_Name!" > nul

    Goto :NewProjectCreated
)
Goto :CreateNewProjectContentFolder

:NewProjectCreated
IF EXIST "%UEPCM_Content_Projects%\!NewProjectNameInput!" (
    echo.
    echo.Successfully Created !NewProjectNameInput!.
    echo.
    set EnteredText=
) ELSE (
    echo.
    echo.Failed to create !NewProjectNameInput!.
    echo.
    set EnteredText=
)
timeout /t %TimeoutTime%
Goto :CreateNewProjectContentFolder

:: With the Project Manager you can Set your active project, Rename a project or Delete a project.
:ProjectsManager
cls
CALL Data\Bin\load_settings.bat

Set "folders="
Set "folderIndex=1"
Set "source_folder="
Set "selectedProject="

for /d %%a in ("%UEPCM_Content_Projects%\*") do (
    set "folder=%%~nxa"
    set "folders=!folders!|!folder!"
    set "folders[!folderIndex!]=!folder!"
    set /a "folderIndex+=1"
)

Set "LastIndex=!folderIndex!"
Set /a TotalProjectsCount="!folderIndex!-1"

CALL Data\Bin\jq-win64-load.bat

Set "currentlyActiveProject="

if exist "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%" (
    for /f "delims=" %%i in ('call "%jq%" -r ".projectName" "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%"') do ( set "projectName=%%i" )
    Set "currentlyActiveProject=!projectName!"
    Set currentlyActiveSourceDir="%UEPCM_Content_Projects%\!projectName!"
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
Set "source_folder=%UEPCM_Content_Projects%\!folders[%Errorlevel%]!"

:: Project Manage Options
cls
echo.Selected Project: !selectedProject!
echo.
CmdMenuSel 0FF0 "Set As Active Project" "Rename" "Permanently Delete" "Back"
If /I "%Errorlevel%" == "1" (
    for /F %%i in ('dir /b "%UEPCM_Content_Projects%"') do (
        :: Folder is not empty
        goto :SetAsActiveProject
    )
    :: Folder is empty
    echo.
    echo.Your projects storage folder is empty.
    timeout /t %TimeoutTime%
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
if exist "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%" (
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
robocopy /move /s /e "%source_folder%" "%Project_Content_Folder%"

IF NOT EXIST "%UEPCM_Content_Projects%\!selectedProject!" (
    goto :ContinueAfterSuccessfulActivation
) else (
    echo.Failed to active project "%selectedProject%".
    echo.
    timeout /t %TimeoutTime%
    goto :ProjectsManager
)

:ContinueAfterSuccessfulActivation
dir /b "%UEPCM_Content_Projects%\*" | findstr . >nul && (
    :: The projects folder isn't empty.
    cls
    echo.Your active project has been successfully set to "%selectedProject%".
    echo.
    timeout /t %TimeoutTime%
    Goto :ProjectsManager
) || (
    :: The projects folder is empty.
    cls
    echo.Your active project has been successfully set to "%selectedProject%".
    echo.
    echo.Your projects storage folder is empty.
    echo.
    timeout /t %TimeoutTime%
    Goto :StartMenu
)

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
mkdir "!Project_Content_Folder_Temp!"
echo.Moving %Project_Content_Folder% to temp dir
robocopy /move /s /e "%Project_Content_Folder%" !Project_Content_Folder_Temp!
mkdir "%Project_Content_Folder%"

:: Create a temp directory and move selected project from Content_Projects to temp dir
mkdir "!UEPCM_Content_Projects_Temp!"
echo.Moving %UEPCM_Content_Projects%\!selectedProject! to temp dir
robocopy /move /s /e "%UEPCM_Content_Projects%\%selectedProject%" !UEPCM_Content_Projects_Temp!

:: Move temp files from the Content_Projects_temp folder to the content folder.
echo.Moving Content_Projects_temp files Content folder
robocopy /move /s /e "!UEPCM_Content_Projects_Temp!" "%Project_Content_Folder%"

:: Move temp files from content_folder_temp to the Content_Projects folder.
for /f "delims=" %%i in ('call "%jq%" -r ".projectName" "%Project_Content_Folder_Temp%\%Content_Project_Json_Data_File_Name%"') do ( set "GetProjectNameFromTemp=%%i" )
mkdir "%UEPCM_Content_Projects%\%GetProjectNameFromTemp%"
robocopy /move /s /e "!Project_Content_Folder_Temp!" "%UEPCM_Content_Projects%\%GetProjectNameFromTemp%"

IF NOT EXIST "%UEPCM_Content_Projects%\!selectedProject!" (
    goto :ContinueAfterSuccessfulActivation
) else (
    echo.Failed to active project "%selectedProject%".
    echo.
    timeout /t %TimeoutTime%
    goto :ProjectsManager
)

:ContinueAfterSuccessfulActivation
dir /b "%UEPCM_Content_Projects%\*" | findstr . >nul && (
    :: The projects folder isn't empty.
    cls
    echo.Your active project has been successfully set to "%selectedProject%".
    echo.
    timeout /t %TimeoutTime%
    Goto :ProjectsManager
) || (
    :: The projects folder is empty.
    cls
    echo.Your active project has been successfully set to "%selectedProject%".
    echo.
    echo.Your projects storage folder is empty.
    echo.
    timeout /t %TimeoutTime%
    Goto :StartMenu
)

:RenameSelectedProject
cls
CALL Data\Bin\jq-win64-load.bat

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
    timeout /t %TimeoutTime%
    Goto :ProjectsManager
) else (
    if "%projectRename%"=="!selectedProject!" (
        Goto :ErrorexistingProjectSetName
    ) else (
        echo User entered "%projectRename%".
        Goto :ContinueToRenameProject
    )
)

:ErrorexistingProjectSetName
echo.Error: You're trying to rename !selectedProject! to !projectRename!...
echo.
echo.Please enter a different name to continue...
echo.
timeout /t %TimeoutTime%
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
IF EXIST "%UEPCM_Content_Projects%\!selectedProject!" (
    echo.Attempting to rename '!selectedProject!'...

    echo.Using jq to update the projectName property in the UEPCM_Data file...
    %jq% ".projectName=\"%projectRename%\"" "%UEPCM_Content_Projects%\!selectedProject!\!Content_Project_Json_Data_File_Name!" > "%UEPCM_Content_Projects%\!selectedProject!\%Content_Project_Json_Data_File_Name%.tmp"

    echo.Replacing the original JSON file with the updated project name...
    move /y "%UEPCM_Content_Projects%\!selectedProject!\%Content_Project_Json_Data_File_Name%.tmp" "%UEPCM_Content_Projects%\!selectedProject!\%Content_Project_Json_Data_File_Name%" > nul 2>&1

    echo.Renaming the project folder...
    ren "%UEPCM_Content_Projects%\!selectedProject!" "%projectRename%"
)
IF NOT EXIST "%UEPCM_Content_Projects%\!selectedProject!" (
    echo.Successfully Renamed '!selectedProject!' to '!projectRename!'...
    echo.
) else (
    echo.Failed to Rename '!selectedProject!' to '!projectRename!'...
    echo.
)
timeout /t %TimeoutTime%
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
IF EXIST "%UEPCM_Content_Projects%\!selectedProject!" (
    cls
    ::Echo.Deleting '!selectedProject!'
    rmdir "%UEPCM_Content_Projects%\!selectedProject!" /s /q
)
IF NOT EXIST "%UEPCM_Content_Projects%\!selectedProject!" (
    goto :ContinueAfterSuccessfulDeletion
) else (
    echo.Failed to delete '!selectedProject!'
    echo.
    timeout /t %TimeoutTime%
    goto :ProjectsManager
)

:ContinueAfterSuccessfulDeletion
dir /b "%UEPCM_Content_Projects%\*" | findstr . >nul && (
    :: The projects folder isn't empty.
    cls
    echo.Successfully deleted '!selectedProject!'
    echo.
    timeout /t %TimeoutTime%
    Goto :ProjectsManager
) || (
    :: The projects folder is empty.
    cls
    echo.Successfully deleted '!selectedProject!'
    echo.
    echo.Your projects storage folder is empty.
    echo.
    timeout /t %TimeoutTime%
    Goto :StartMenu
)

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

:DownloadOrUpdatePhoenixContentFiles
cls
echo.If you'd like you to, you can download PhoenixUProj Content Files.
echo.
echo.These files are optional, but you can download them if you'd like to.
echo.
echo.The download opens in your internet browser.
echo.
CmdMenuSel 0FF0 "Open Download Link" "Back"
If /I "%Errorlevel%" == "1" (
    cls
    echo.Opening Link to download PhoenixUProj Content Files...
    echo.
    start https://github.com/narknon/PhoenixUProj/tree/main/Content
    timeout /t 3
    Goto :DownloadPhoenixContentFiles
)
If /I "%Errorlevel%" == "2" (
    Goto :StartMenu
)
goto :Settings

:DownloadPhoenixContentFiles
cls
echo.When your download is finished, ^extract all files to the PhoenixUProj_Content folder.
echo.
echo.You can open the PhoenixUProj_Content Folder or your Downloads folder by selecting the option below.
echo.
CmdMenuSel 0FF0 "Open PhoenixUProj_Content Folder" "Open Your Downloads Folder" "Back to Start Menu"
If /I "%Errorlevel%" == "1" (
    explorer.exe "%New_PhoenixUProj_Content_Folder%"
    echo.
    echo.Opening your "%New_PhoenixUProj_Content_Folder%" Folder.
    echo.
    timeout /t 1
    goto :DownloadPhoenixContentFiles
)
If /I "%Errorlevel%" == "2" (
    explorer.exe "%userprofile%\Downloads"
    echo.
    echo.Opening your "Downloads" Folder.
    echo.
    timeout /t 1
    goto :DownloadPhoenixContentFiles
)
If /I "%Errorlevel%" == "3" (
    Goto :StartMenu
)
goto :StartMenu

:SetDirectories
CALL Data\Bin\load_settings.bat
cls
echo.Set Directories
echo.
echo.Set the directory of your unreal project content folder.
echo.(The Project Content Folder Directory is the location of your UE Project Content Folder)
echo.Current Directory: (%Project_Content_Folder%)
echo.
echo.Set the directory of your UEPCM Content Projects Storage Folder.
echo.(The Projects Directory is where all of your projects are created and stored)
echo.Current Directory: (%UEPCM_Content_Projects%)
echo.
CmdMenuSel 0FF0 "Set UE Project Content Folder Directory" "Set UEPCM Content Projects Storage Directory" "Back"
If /I "%Errorlevel%" == "1" (
    Goto :UE_Project_Content_Folder_Directory
)
If /I "%Errorlevel%" == "2" (
    Goto :UEPCM_Content_Projects_Storage_Directory
)
If /I "%Errorlevel%" == "3" (
    Goto :Settings
)
Goto :StartMenu

:UE_Project_Content_Folder_Directory
cls
echo.Setting the project content folder path...
echo.
set ps_fn=Data\Temps\PowerShell_Temp.ps1
echo [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") ^| out-null > %ps_fn%
echo $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog >> %ps_fn%
echo $FolderBrowserDialog.RootFolder = "Desktop" >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath = "%~dp0" >> %ps_fn%
echo $FolderBrowserDialog.Description = "Select your projects content folder:" >> %ps_fn%
echo $FolderBrowserDialog.ShowDialog() ^| Out-Null >> %ps_fn%
echo $FolderBrowserDialog.SelectedPath >> %ps_fn%

for /F "tokens=* usebackq" %%a in (`powershell -executionpolicy bypass -file %ps_fn%`) do if not "%%a"=="Cancel" set "ProjectContentFolder=%%a"
del %ps_fn%

CALL Data\Bin\jq-win64-load.bat

set tempFile=%SettingsJsonData%.tmp

%jq% --arg newDir "%ProjectContentFolder%" ".UE_Project_Content_Folder_Dir = $newDir" "%SettingsJsonData%" > "%tempFile%"

if errorlevel 1 (
    echo Error: Failed to update JSON file "%SettingsJsonData%".
    del %tempFile%
    Goto :SetDirectories
)

if not exist "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%" (
    echo.The Content folder you selected doesn't contain a UEPCM_Data file...
    echo.
    echo.Creating !Content_Project_Json_Data_File_Name! file...
    echo.
    echo.Please enter a name for your project...

    :: Create the UEPCM_Data file
    type nul > "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%"
) else (
    echo.The Content folder you selected contains a !Content_Project_Json_Data_File_Name! file.
    Goto :ContinueToUpdateProjectContentFolderPath
)

:InputExistingProjectName
set setExistingProjectName=
set vbscript="Data\Temps\inputbox.vbs"
set title="Set currently active project name: "
set default="MyProjectName"

echo Set objShell = CreateObject("WScript.Shell") > %vbscript%
echo response = InputBox(%title%, "Input", %default%) >> %vbscript%
echo if response = "" then wscript.quit(1) >> %vbscript%
echo wscript.echo response>>%vbscript%

if exist "%vbscript%" (
    for /f "delims=" %%I in ('cscript //nologo %vbscript%') do set "setExistingProjectName=%%I"
)

cls

if "%setExistingProjectName%"=="" (
    echo.Error: You either left the project name field empty or you cancelled the operation.
    timeout /t %TimeoutTime%
    if exist "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%" (
        echo.Deleting "%Content_Project_Json_Data_File_Name%" file...
        del "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%"
    )
    Goto :SetDirectories
) else (
    IF EXIST "%UEPCM_Content_Projects%\%setExistingProjectName%" (
        :: Project already exists
        Goto :ErrorExistingProjectName
    ) else (
        :: Project does not exist
        Goto :ContinueToUpdateSettingsAndExistingProjectName
    )
)

:ErrorExistingProjectName
echo.Error: You already have an existing project in storage named '%setExistingProjectName%'...
echo.
echo.Please enter a different name and try again...
echo.

del %vbscript%

timeout /t %TimeoutTime%
Goto :InputExistingProjectName

:ContinueToUpdateSettingsAndExistingProjectName
if exist "%Project_Content_Folder%\%Content_Project_Json_Data_File_Name%" (
    :: Set first property
    echo.{ "projectName": "%setExistingProjectName%" } >> "%Project_Content_Folder%\!Content_Project_Json_Data_File_Name!"

    :: Add another property
    %jq% --arg newProperty "Inactive" ". + { "projectState": $newProperty }" "%Project_Content_Folder%\!Content_Project_Json_Data_File_Name!" > "%Project_Content_Folder%\!Content_Project_Json_Data_File_Name!.temp"

    :: Replace the previously created UEPCM_Data file with the updated file
    move /y "%Project_Content_Folder%\!Content_Project_Json_Data_File_Name!.temp" "%Project_Content_Folder%\!Content_Project_Json_Data_File_Name!" > nul
)

echo.Successfully created UEPCM_Data File for project '%setExistingProjectName%'

:ContinueToUpdateProjectContentFolderPath

:: Replace original JSON file with updated file
move /y "%tempFile%" "%SettingsJsonData%" > nul

if exist "%vbscript%" (
    :: Delete the input box
    del %vbscript%
)

echo.
echo.Updated Project Content Folder Directory in "%SettingsJsonData%"
echo.to "%ProjectContentFolder%"
echo.
timeout /t %TimeoutTime%
Goto :SetDirectories

:UEPCM_Content_Projects_Storage_Directory
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

%jq% --arg newDir "%ContentProjectsDirectory%" ".UEPCM_Content_Projects_Storage_Dir = $newDir" "%SettingsJsonData%" > "%tempFile%"

cls

if errorlevel 1 (
    echo Error: Failed to update JSON file "%SettingsJsonData%".
    del %tempFile%
    Goto :SetDirectories
)

:: Replace original JSON file with updated file
move /y "%tempFile%" "%SettingsJsonData%" > nul

echo.Updated UEPCM Content Projects Directory in "%SettingsJsonData%"
echo.to "%ContentProjectsDirectory%"
echo.
timeout /t %TimeoutTime%
Goto :SetDirectories

:Exit
Echo.Exiting...
timeout /t 1 >nul
exit