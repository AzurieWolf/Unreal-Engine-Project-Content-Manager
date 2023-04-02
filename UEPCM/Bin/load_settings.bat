for /f "delims=" %%x in ('call "%jq%" -r ".UE_ProjectContentDir" "Settings.json"') do ( set "Settings_ProjectContentDir=%%x" )
for /f "delims=" %%z in ('call "%jq%" -r ".UE_ContentProjectsDir" "Settings.json"') do ( set "Settings_ContentProjectsDir=%%z" )

if "%Settings_ProjectContentDir%" == "" (
    ::echo.The value of "Settings_ProjectContentDir" not set, setting to default directory "Content".
    Set content_folder=Content
)
if NOT "%Settings_ProjectContentDir%" == "" (
    ::echo.The value of "Settings_ProjectContentDir" is %Settings_ProjectContentDir%.
    Set content_folder=%Settings_ProjectContentDir%
)

if "%Settings_ContentProjectsDir%" == "" (
    ::echo.The value of "Settings_ContentProjectsDir" is empty, setting to default directory "Content_Projects".
    Set Content_Projects=Content_Projects
)
if NOT "%Settings_ContentProjectsDir%" == "" (
    ::echo.The value of "Settings_ContentProjectsDir" is %Settings_ContentProjectsDir%.
    Set Content_Projects=%Settings_ContentProjectsDir%
)

:: Directories and Folders
Set content_folder_temp=UEPCM\Temps\content_folder_temp
Set Content_Projects_temp=UEPCM\Temps\Content_Projects_temp
Set new_content_project_folder=UEPCM\New_Content_Project
Set UE_PCM_folder=UEPCM