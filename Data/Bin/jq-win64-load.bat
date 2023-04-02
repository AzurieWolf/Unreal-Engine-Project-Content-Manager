:: Update the JSON file with the selected directory
set jq=Data\Bin\jq-win64.exe
if not exist "%jq%" (
    echo Error: JSON processor not found at "%jq%".
    pause
    exit /b 1
)