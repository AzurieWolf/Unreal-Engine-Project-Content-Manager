:: Remove the selected project from the Projects.json file
%jq% "del(.%selectedProject%)" "%ProjectsJsonData%" > "%ProjectsJsonData%.temp"
move /y "%ProjectsJsonData%.temp" "%ProjectsJsonData%" > nul

:: Append new setter and value to the Projects.json file
%jq% --arg newProperty "newValue" ". + { "newProperty": $newProperty }" "%ProjectsJsonData%" > "%ProjectsJsonData%.temp"
move /y "%ProjectsJsonData%.temp" "%ProjectsJsonData%" > nul