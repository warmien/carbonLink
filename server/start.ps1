$env:Path = "C:\Users\warminen\AppData\Local\nvm\v20.20.2;" + $env:Path
Set-Location "C:\Users\warminen\DevEcoStudioProjects\CarbonLink\server"
npx ts-node --transpile-only src/index.ts