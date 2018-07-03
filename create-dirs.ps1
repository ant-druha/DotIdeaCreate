$regex = "<module fileurl"
$root = $PSCommandPath | Split-Path -Parent
$sep = [IO.Path]::DirectorySeparatorChar
Write-Output "Root path: $root"
foreach ($line in Get-Content "$root\.idea\modules.xml") {
  if ( [regex]::IsMatch($line, "^\s*<module fileurl")) {
    $start = $line.IndexOf('filepath="$PROJECT_DIR$')
    $filepath = ([String]$line).Substring($start)
    Write-Output "Processing path: $filepath"
    #    $line -match '/\w+/'
    $matches = ([regex]'/(\w+|/)+/').Matches($filepath);
    $matches.ForEach({
      $path = $_.Value
      Write-Output "====================>"
      #      $full_path = $root$sep$path
      $full_path = Join-Path $root $path
      if (!(test-path $full_path)) {
        Write-Output "Creating dir: $full_path"
        New-Item -path $full_path -type directory
        #        New-Item -ItemType Directory -Force -Path $full_path
      } else {
        Write-Output "Directory: $full_path already exists"
      }
      Write-Output "<===================="

    })
  }
}