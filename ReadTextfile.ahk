#Requires AutoHotkey v2.0

directory := "log\"
fileNamePart := "solTest"
latestFile := ""
latestTime := 0

Loop Files directory . fileNamePart . "*.txt", "F"
    {
        FilePath := A_LoopFileFullPath
        fileTime := FileGetTime(FilePath, "C")
        if (fileTime > latestTime)
            {
                latestFile := FilePath
                latestTime := fileTime
                ;MsgBox "yes"
            }
    }

if (latestFile != "")
    {
        fileContents := FileRead(latestFile)
        fileContents2 := FileRead(latestFile)
        MsgBox "Contents of " . latestFile . ":`n" . fileContents
    }
    else
        {
            MsgBox "No File Found with the specified name part."
        }

Tgui := GUI("2")

Test := Tgui.Add("Edit", "ReadOnly w500 h500 ")

;AltusID := Tgui.Add("Edit", "ReadOnly W100")

ID := RegExMatch(fileContents2, "altusID.*", &Test2, "7")

;AltusID.Value := ID
beep := Tgui.Add("Edit", "ReadOnly W300")

beep.Value := Test2[]

Test.Value := fileContents


Tgui.show()