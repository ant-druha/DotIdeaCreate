function testDirExists($dir_path, $dir_name, $arg_count) {
  if ((test-path -Path $dir_path) -eq $false) {
    Write-Error "'$dir_name' directory not found by the path: $dir_path`nEither place '$dir_name' directory in directory with this script or specify full path as $arg_count script argument."
    return $false
  }
  return $true
}
$sript_path = $PSCommandPath | Split-Path -Parent

#get .idea dir
if ($args.Length -gt 1) {
  $dot_idea_dir = $args[1]
}
else {
  $dot_idea_dir = $sript_path
}
if ((testDirExists $dot_idea_dir ".idea" 2) -eq $false) {
  exit -1
}

#get directory with .iml files
if ($args.Length -gt 0) {
  $imls_dir = $args[0]
}
else {
  $imls_dir = Join-Path $sript_path "imls"
}
testDirExists $imls_dir 'iml' 1


Write-Output "Scipt location: $sript_path"
Write-Output ".idea dir location: $dot_idea_dir"
Write-Output "iml files location: $imls_dir"

foreach ($line in Get-Content "$dot_idea_dir\.idea\modules.xml") {
  if ( [regex]::IsMatch($line, "^\s*<module fileurl")) {
    $start = $line.IndexOf('filepath="$PROJECT_DIR$')
    $filepath = $line.Substring($start)
    Write-Output "Processing file: $filepath"
    $dir_matches = ([regex]'/(\w|/|\.|\-)+/').Matches($filepath);
    $file_matches = ([regex]'(\w|\-|\.)+\.iml').Matches($filepath);
    $path = $dir_matches[0]
    $file_name = $file_matches[0]
    Write-Output "Dir name: $path"
    Write-Output "File name: $file_name"
    $full_path = Join-Path $dot_idea_dir $path
    if (!(test-path $full_path)) {
      Write-Output "Creating dir: $full_path"
      New-Item -path $full_path -type directory #-Force
    }
    else {
      Write-Output "Directory: '$full_path' already exists"
    }
    $iml_file_src = Join-Path $imls_dir $file_name
    $iml_file_dst = Join-Path $full_path $file_name
    Write-Output "Copy file from $iml_file_src to $iml_file_dst"
    Copy-Item -Path $iml_file_src -Destination $iml_file_dst
  }
}