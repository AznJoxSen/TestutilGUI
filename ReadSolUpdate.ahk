#Requires AutoHotkey v2.0

directory := "log\"
fileNamePart := "solUpdateTmsApp"
latestFile := ""
latestTime := 0

Loop Files directory . fileNamePart . "*.txt", "F"
    {
        FilePath := A_LoopFileFullPath
        fileTime := FileGetTime(FilePath, "M")
        
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
        ;MsgBox "Contents of " . latestFile . ":`n" . fileContents
    }
    else
        {
            MsgBox "No File Found with the specified name part."
        }


Tgui := GUI("2")


SetTimer CheckFile, 1000
Last := FileGetTime(latestFile, "M")
CheckFile(*){
    
    CurrentFileTime := FileGetTime(latestFile, "M")

    if (CurrentFileTime !=  Last){
        fileContents := FileRead(latestFile)
        global Last := CurrentFileTime
        Tts.Value := "Change"
    }
    else{
        Tts.Value := "No change"
    }
}
GuiClosed := Tgui.OnEvent("Close", CloseGui)

CloseGui(*){
    SetTimer CheckFile, 0
}

Test := Tgui.Add("Edit", "ReadOnly w500 h500 ")

SegAdd := "segmentAddress = "
;AltusID := Tgui.Add("Edit", "ReadOnly W100")

Tts := Tgui.Add("Edit", "ReadOnly w200 h50 ")

ID := RegExMatch(fileContents2, "altusID.*", &Test2, "7")

ToNotEraseFlash := RegExMatch(fileContents2, "To erase external flash", &EraseFlash, "1")

Progress1 := regExMatch(fileContents2, SegAdd . "0x1000", &Progressing1, "1")

regExMatch(fileContents2, SegAdd . "0x2000", &Progressing2, "1")

;AltusID.Value := ID
beep := Tgui.Add("Edit", "ReadOnly W300")

seet := Tgui.Add("Edit", "ReadOnly W300")
;seet.Value := LastFileTime

beep.Value := Test2[]

Test.Value := fileContents

leet := Tgui.Add("Edit", "ReadOnly W300")
leet.Value := EraseFlash[]

Prog := Tgui.AddProgress("W600 H20 cLime BackgroundBlack Smooth")
Prog.Value := 0

ProgBtn := Tgui.Add("Button","Default", "Adding")
ProgBtn.OnEvent("Click", ProgPlus)

Plead := EraseFlash[]

Po := Progressing1[]

Po2 := Progressing2[]

;MsgBox Po

if (Plead == "To erase external flash"){
    ;MsgBox "Whoop"
}
else{
    MsgBox "nhoi"
}

if (Po == SegAdd . "0x1000"){
    Prog.Value += 10
}

if(Po2 == SegAdd . "0x2000"){
    Prog.Value += 10
}
ProgPlus(*)
{
    Prog.Value += 10
}

Tgui.show()