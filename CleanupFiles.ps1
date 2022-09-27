$Path = “.”

$LogFile = ".\script.log"

Function LogWrite {
   Param ([string]$LogString)
   Add-Content $LogFile -value $LogString
}


$(Get-Item $Path; Get-ChildItem -Recurse -Directory -Path $Path) | ForEach {

	$NewVerFiles = Get-ChildItem -Path $($_.FullName) | Where Name -like "*.newVer*" | Sort LastWriteTime -Descending

	$SplitFileNames = New-Object System.Collections.ArrayList
	ForEach($File in $NewVerFiles) {
		If(-Not $SplitFileNames.Contains($File.Name.Split(".")[0])) {
			[void]$SplitFileNames.Add($File.Name.Split(".")[0])
		}
	}

	For($i=0; $i -lt $SplitFileNames.Count; $i++) {
		$SplitFileName = $SplitFileNames[$i]
		$NewestFiles = Get-ChildItem -Path $($_.FullName) | Where Name -like "$SplitFileName.newVer*" | Sort LastWriteTime -Descending
		$NewestFile = ""
		ForEach($File in $NewestFiles) {
			$NewestFile = $File
			break
		}
		LogWrite ("Newest file is: " + (Get-ChildItem -Path $($_.FullName) $NewestFile).FullName)

		$NewestFileName = $NewestFile.Name
		If(-Not $NewestFileName -eq 0) {
			$FileNameParts = $NewestFileName.Split(".")
			$NewFileName = $FileNameParts[0] + "." + $FileNameParts[2]
			If(Test-Path -Path "$($_.FullName)\$NewFileName") {
				LogWrite ("File already exists.. deleting.")
				Remove-Item -Path "$($_.FullName)\$NewFileName"
				Rename-Item -Path "$($_.FullName)\$NewestFile" $NewFileName
			}
			Else {
				LogWrite ("File doesn't exist.. renaming.")
				Rename-Item -Path "$($_.FullName)\$NewestFile" $NewFileName
			}
			LogWrite ("Filename renamed to: " + "$($_.FullName)\$NewFileName")
		}
		Else {
			LogWrite ("Skipped a null value")
		}
		LogWrite ""
	}
	
}
