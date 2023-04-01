for /f "delims=" %%i in ('call "%jq%" -r ".UE_ContentProjectsDir" "Settings.json"') do ( set "UE_ContentProjectsDir=%%i" )
for /f "delims=" %%i in ('call "%jq%" -r ".UE_ProjectContentDir" "Settings.json"') do ( set "UE_ProjectContentDir=%%i" )

:: Directories and Folders
Set default_content_folder=Content
Set default_UE_Content_Projects=UE_Content_Projects
Set content_folder=%UE_ProjectContentDir%
Set UE_Content_Projects=%UE_ContentProjectsDir%
Set UE_PCM_folder=UE-PCM
Set new_content_project_folder=UE-PCM\New_Content_Project
Set content_folder_temp=UE-PCM\Temps\content_folder_temp
Set UE_Content_Projects_temp=UE-PCM\Temps\UE_Content_Projects_temp