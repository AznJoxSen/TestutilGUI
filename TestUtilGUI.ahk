Run "tkToolUtility.exe"
Sleep 600
ControlSend  "{Enter}", , "tkToolUtility.exe"
SetWorkingDir(A_ScriptDir)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon (iconPath)

MyGui := Gui(, "V2.1 TestUtilityGUI For Use With TestUtilityV40")

SetDarkWindowFrame(MyGui)
MyGui.Setfont("s10 cWhite")
MyGui.BackColor := "424242"
WinMove(0,0,,, "ahk_exe tkToolUtility.exe")

CmdExist(*){
    if WinExist("cmd.exe")
        WinHide "Ahk_exe cmd.exe"
    SetTimer CmdExist, 0

}

FileAppend("test","ComPorts.txt",)

RunWaitOne(command) {
    shell := ComObject("WScript.Shell")
    
    exec := shell.Exec(A_ComSpec " /C " command )
    
    output := exec.StdOut.ReadAll()
    SetTimer CmdExist, 10
    

    output := StrReplace(output, ":","")
    FileDelete("ComPorts.txt")
    

    

    FileAppend(output "`n", "ComPorts.txt", )

    }
    


output := RunWaitOne("mode")



SetDarkWindowFrame(hwnd, boolEnable:=1) {
    hwnd := WinExist(hwnd)
    if VerCompare(A_OSVersion, "10.0.17763") >= 0
        attr := 19
    if VerCompare(A_OSVersion, "10.0.18985") >= 0
        attr := 20
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", boolEnable, "int", 4)
}

Text := FileRead("ComPorts.txt")

Lines := StrSplit(Text, "`n")

Words := []

for index, line in Lines {
    if (RegExMatch(line, "COM\d+", &match)) {
        Words.push(match[])
    }
}

/*
Does not work properly

Directory := "log\"
SolTest := "solTest"
SolTestLatestFile := "" 
SolTestLatestTime := 0
SolTestContents := ""
Last := ""

SolTestFileRead(*){
    Sleep 2000
    Loop Files Directory . SolTest . "*.txt", "F"
        {
            SolFilePath := A_LoopFileFullPath
            SolFileTime := FileGetTime(SolFilePath, "M")

            if (SolFileTime > SolTestLatestTime)
                {
                    global SolTestLatestFile := SolFilePath
                    global SolTestLatestTime := SolFileTime
                    ;global Last := FileGetTime(SolTestLatestFile, "M")
                }
        }
    
    if (SolTestLatestFile != "")
        {
            global SolTestContents := FileRead(SolTestLatestFile)
            SolDisplay.Value := SolTestContents
            SetTimer CheckFile, 1000

            if (SolTestLatestFile != ""){
                global Last := FileGetTime(SolTestLatestFile, "M")
             }
            
        }
        else
            {
                MsgBox "No File Found with the specified name part."
            }

}

CheckFile(*){
    
    CurrentSolFileTime := FileGetTime(SolTestLatestFile, "M")
    FileRead(SolTestLatestFile)

    if (CurrentSolFileTime != Last){
        global SolTestContents := FileRead(SolTestLatestFile)
        global Last := CurrentSolFileTime
        SolDisplay.Value := SolTestContents
        ;MsgBox "ts"
        ;Sleep 50
        SendMessage(0x0115, 7, 0, "Edit5", "V2.1 TestUtilityGUI For Use With TestUtilityV40")
        
    }
    ;else{
    ;    MsgBox "fuck"
    ;}
}

*/

;Create tabs
Tab := MyGui.Add("Tab3",, ["Q-Telemetry", "Solenoid", "TC Node"])
Tab.Font := "Bold"

;, "1-Wire", "RSS", "Anchor", "Orientation"

;For Q-Telemetry Tab
Tab.UseTab("Q-telemetry")

MyGui.Add("Button","x800 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

;Choose Modem Type
MyGui.Add("Text","x26 y39", "Choose Modem Type")
QTComChoice := MyGui.AddDropDownList("W80", ["QPSK", "OFDM"])
QTComChoice.Choose("QPSK")

MyGui.Add("Text",, "Select COM Port Number")
QTCOMPort := MyGui.AddDropDownList("W75", Words)
;QTCOMPort.SetFont("cBlack")
;MyGui.Add("UpDown") 
;MyGui.Add("Button",, "OK").OnEvent("Click", QTCOMPortSelect)

RefreshQT := MyGui.Add("Button","x121 y114", "Refresh")
RefreshQT.OnEvent("Click", Refreshbut)

;Choose Board
MyGui.Add("Text","x26 y147", "Choose Board Type")
BoardChoice := MyGui.AddDropDownList("W150", ["Master Controller", "DCDC Converter", "Relay Board"])
BoardChoice.OnEvent("Change", BoardSelect)


;For Master Controller
MyGui.Add("Text","x250 y39", "For Master Controller")
MyGui.Add("Text",,"Update AltusID/Board ID")
MCID := MyGui.Add("Edit")
MCID.SetFont("cBlack")

MyGui.Add("Text",,"Update Q-Telemetry Module ID")
QTID := MyGui.Add("Edit")
QTID.SetFont("cBlack")

MCID.OnEvent("Focus", McQtBtnFocus)
MCID.OnEvent("LoseFocus", McQtBtnUnFocus)

QTID.OnEvent("Focus", McQtBtnFocus)
QTID.OnEvent("LoseFocus", McQtBtnUnFocus)

MCBtn := MyGui.Add("Button","", "Update")
MCBtn.OnEvent("Click", EnterToSaveQT)

MyGui.Add("Text",, "Check Current Settings")
MyGui.Add("Button",, "Check").OnEvent("Click", QTCheck)


;For DCDC
MyGui.Add("Text","x500 y39", "For DCDC Converter")
MyGui.Add("Text",, "Change to Raised Startup")
MyGui.Add("Button",, "Raised Startup").OnEvent("Click", RaisedStartup)

MyGui.Add("Text",, "Change to Default Startup")
MyGui.Add("Button",, "Default Startup").OnEvent("Click", DefaultStartup)

MyGui.Add("Text",, "Update AltusID/Board ID")
DCDCID := MyGui.Add("Edit")
DCDCID.SetFont("cBlack")
DCDCBtn := MyGui.Add("Button",, "Update")
DCDCBtn.OnEvent("Click", EnterToSaveQT)

DCDCID.OnEvent("Focus", DCDCBtnFocus)
DCDCID.OnEvent("LoseFocus", DCDCBtnUnFocus)

MyGui.Add("Text",, "Check Current Settings")
MyGui.Add("Button",, "Check").OnEvent("Click", QTCheck)

MyGui.Add("Text",, "Save Changes")
DCDCSaveButton := MyGui.Add("Button",, "Save")
DCDCSaveButton.OnEvent("Click", DCDCSave)


;For Relay Board
MyGui.Add("Text", "x750 y39", "For Relay Board")
MyGui.Add("Text",,"Update AltusID/Board ID")
RBID := MyGui.Add("Edit")
RBID.SetFont("cBlack")
RBBtn := MyGui.Add("Button",, "Update")
RBBtn.OnEvent("Click", EnterToSaveQT)

RBID.OnEvent("Focus", RBBtnFocus)
RBID.OnEvent("LoseFocus", RBBtnUnFocus)

MyGui.Add("Text",, "Check Current Settings")
MyGui.Add("Button",, "Check").OnEvent("Click", QTCheck)


;For Solenoid Tab
Tab.UseTab("Solenoid")

MyGui.Add("Button","x800 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

;Selecting communication option for solenoid
MyGui.Add("Text","x26 y39","Select Communication Choice")
ComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
;ComChoice.OnEvent("Change", SendKeystrokeFromListbox)
ComChoice.Choose("PCAN")


;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
COMPort := MyGui.AddDropDownList("W75", Words)


Refresh := MyGui.Add("Button","x121 y114", "Refresh")
Refresh.OnEvent("Click", Refreshbut)

Refreshbut(*)
{

FileAppend("test","ComPorts.txt",)

COMPort.Delete()

RunWaitOne(command) {
    shell := ComObject("WScript.Shell")
    
    exec := shell.Exec(A_ComSpec " /C " command )
    
    output := exec.StdOut.ReadAll()
    SetTimer CmdExist, 10
    
    output := StrReplace(output, ":","")
    FileDelete("ComPorts.txt")
    
    FileAppend(output "`n", "ComPorts.txt", )
    }
    
output := RunWaitOne("mode")

Text := FileRead("ComPorts.txt")

Lines := StrSplit(Text, "`n")

Words := []

for index, line in Lines {
    if (RegExMatch(line, "COM\d+", &match)) {
        Words.push(match[])
    }
}
COMPort.Add(Words)

}

/*

SolDisplay := MyGui.Add("Edit", " ReadOnly x26 y600 W900 H200")
SolDisplay.SetFont("cBlack")

SolDisplay.Value := SolTestContents

*/
MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
SolInput := MyGui.Add("Edit", "")
SolInput.SetFont("cBlack")

MyGui.Add("Text","x26 y147", "FW Selected for Installing")
SolFW := MyGui.Add("Edit", "ReadOnly")
SolFW.SetFont("cBlack")

file1Contents := FileRead("hexFiles_SOL\SOL_leinApp_bl.hex")
Folder := ("Solenoid FW\Main FW - SM470 Processor\*.hex")

Loop Files Folder, "F"
    {

        FilePath := A_LoopFileFullPath

        CurrentFile := FileRead(FilePath)
if (file1Contents == CurrentFile) 
    {
    FWSolenoidFile := A_LoopFileName
        SolFW.Text := FWSolenoidFile

    break
    }


    }


;file2Contents := FileRead("\\Solenoid FW\Main FW - SM470 Processor\OFF-054531_30.hex\\")
CheckFWLoopSol(*){
Loop Files Folder, "F"
    {
        file1Contents := FileRead("hexFiles_SOL\SOL_leinApp_bl.hex")
        FilePath := A_LoopFileFullPath

        CurrentFile := FileRead(FilePath)
if (file1Contents == CurrentFile) 
    {
    FWSolenoidFile := A_LoopFileName
        SolFW.Text := FWSolenoidFile
        FWSolenoidFile := ""
        CurrentFile := ""
    break
    }


    }
}

;Browse for FW for Solenoid
MyGui.Add("Text",, "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogSolenoid)

MyGui.Add("Text",, "Choose a Solenoid if more than one connected")
ChooseSolFWIns := MyGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])


;Install FW to Solenoid
MyGui.Add("Text",, "Install Firmware to Solenoid")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
MyGui.Add("Button",, "Install").OnEvent("Click", InstallSolenoidEz)


;Access solenoid board
MyGui.Add("Text",, "Get to Access Solenoid Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", AccessSolenoidEz)



;Rescan of Solenoid CANIDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x100 y483", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

;Choose what solenoid to access
MyGui.Add("Text","x26 y518", "Choose Solenoid Board")
SolenoidAccess := MyGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidAccess.OnEvent("Change", SolenoidIDs)
;CBS_DISABLENOSCROLL

;Changing Solenoid Usage
MyGui.Add("Text","x360 y39", "Change Solenoid Usage")
SolenoidUse := MyGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidUse.OnEvent("Change", SolenoidUsage)

;Changing sensor types
MyGui.Add("Text","" , "Choose Sensor Type")
SensorType := MyGui.AddDropDownList("W170",["HallEffect", "QuadEncoder", "Mech", "Unknown"])
SensorType.OnEvent("Change", SensorTypeChange)

;Changing sensor values
MyGui.Add("Text","" , "Update Sensor Data For:")
SolenoidSensors := MyGui.AddDropDownList("W170", ["DDP3 '9a' Linear", "DDP3 '9b' Linear", "Comp '10' Linear", "AncUpper '13a' Quad", "AncLower '13b' Quad", "Sensor6 'Not in Use'", "Sensor7 'Not in Use'"])
SolenoidSensors.OnEvent("Change", SensorIDs)

MyGui.Add("Text","" , "Check Current Settings")
MyGui.Add("Button",,"Check").OnEvent("Click", CheckSet)

MyGui.Add("Text","" , "Check Calibration Table")
MyGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

;Test Solenoid
MyGui.Add("Text","x360 y360" , "For EL.LAB Use Only!")
MyGui.Add("Text","" ,"Test Solenoid Switching")
MyGui.Add("Button",, "Test Switching").OnEvent("Click", SolenoidSwitching)

;Text for sensor values
MyGui.Add("Text","x600 y60", "SensorLinear m")
MyGui.Add("Text",, "SensorLinear b")
MyGui.Add("Text",, "SensorQuadtratic Cb")
MyGui.Add("Text",, "SensorQuadtratic Cm")
MyGui.Add("Text",, "SensorQuadtratic Bb")
MyGui.Add("Text",, "SensorQuadtratic Bm")
MyGui.Add("Text",, "SensorQuadtratic Ab")
MyGui.Add("Text",, "SensorQuadtratic Am")
MyGui.Add("Text",, "Update Sensor Values")

;Text for IDs
MyGui.Add("Text",, "Update Altus/Board ID")
MyGui.Add("Text",, "Update Tool ID")

;Input edit box for sensor values
MyGui.Add("Text","x750 y39","Add Sensor values")
Sensorm := MyGui.Add("Edit",)
Sensorb := MyGui.Add("Edit")
SensorCb := MyGui.Add("Edit")
SensorCm := MyGui.Add("Edit")
SensorBb := MyGui.Add("Edit")
SensorBm := MyGui.Add("Edit")
SensorAb := MyGui.Add("Edit")
SensorAm := MyGui.Add("Edit")
SensorValuesBTN := MyGui.Add("Button",, "Update")
SensorValuesBTN.OnEvent("Click", UpdateSensorValues)

;Set font for sensor value edit box
Sensorm.SetFont("cBlack")
Sensorb.SetFont("cBlack")
SensorCb.SetFont("cBlack")
SensorCm.SetFont("cBlack")
SensorBb.SetFont("cBlack")
SensorBm.SetFont("cBlack")
SensorAb.SetFont("cBlack")
SensorAm.SetFont("cBlack")

Sensorm.OnEvent("Focus", SolSensorUpdateBTNFocus)
Sensorm.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

Sensorb.OnEvent("Focus", SolSensorUpdateBTNFocus)
Sensorb.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

SensorCb.OnEvent("Focus", SolSensorUpdateBTNFocus)
SensorCb.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

SensorCm.OnEvent("Focus", SolSensorUpdateBTNFocus)
SensorCm.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

SensorBb.OnEvent("Focus", SolSensorUpdateBTNFocus)
SensorBb.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

SensorBm.OnEvent("Focus", SolSensorUpdateBTNFocus)
SensorBm.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

SensorAb.OnEvent("Focus", SolSensorUpdateBTNFocus)
SensorAb.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

SensorAm.OnEvent("Focus", SolSensorUpdateBTNFocus)
SensorAm.OnEvent("LoseFocus", SolSensorUpdateBTNUnFocus)

;Input edit box for IDs
AltusID := MyGui.Add("Edit")
ToolID := MyGui.Add("Edit")
SolUpdateIDBtn := MyGui.Add("Button",, "Update IDs")
SolUpdateIDBtn.OnEvent("Click", UpdateIDs)
AltusID.OnEvent("Focus", SolIdBTNFocus)
AltusID.OnEvent("LoseFocus", SolIdBTNUnFocus) 

ToolID.OnEvent("Focus", SolIdBTNFocus)
ToolID.OnEvent("LoseFocus", SolIdBTNUnFocus)


;Set font for ID value edit box
AltusID.SetFont("cBlack")
ToolID.SetFont("cBlack")

; For TC Node tab
Tab.UseTab("TC Node")

MyGui.Add("Button","x800 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

;Selecting communication option for TC Node
MyGui.Add("Text","x26 y39","Select Communication Choice")
TCComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])
TCComChoice.Choose("PCAN")


;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
TCCOMPort := MyGui.AddDropDownList("W75", Words)
;TCCOMPort.SetFont("cBlack")
;MyGui.Add("UpDown") 

RefreshTC := MyGui.Add("Button","x121 y114", "Refresh")
RefreshTC.OnEvent("Click", Refreshbut)

MyGui.Add("Text","x26 y147", "FW Selected for Installing")
TCFW := MyGui.Add("Edit", "ReadOnly")
TCFW.SetFont("cBlack")

file2Contents := FileRead("hexFiles_TC\TC_leinApp_bl.hex")
TCFolder := ("TC FW\Main FW\*.hex")

Loop Files TCFolder, "F"
    {
        FilePath2 := A_LoopFileFullPath
        CurrentFile2 := FileRead(FilePath2)

if (file2Contents == CurrentFile2) 
    {      
    FWTCFile := A_LoopFileName
        TCFW.Text := FWTCFile

    break
    }
    }

CheckFWLoopTC(*){
Loop Files TCFolder, "F"
    {
        file2Contents := FileRead("hexFiles_TC\TC_leinApp_bl.hex")
        FilePath2 := A_LoopFileFullPath

        CurrentFile2 := FileRead(FilePath2)
if (file2Contents == CurrentFile2) 
    {
    FWTCFile := A_LoopFileName
        TCFW.Text := FWTCFile
        FWTCFile := ""
        CurrentFile2 := ""
    break
    }
    }
}




;Browse for FW for TC Node
MyGui.Add("Text","", "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogTC)

MyGui.Add("Text",, "Choose a TC Node if more than one connected")
ChooseTCFWIns := MyGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])

;Install FW to TC Node
MyGui.Add("Text",, "Install Firmware to TC Node")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWTC)

;Access TC NOde
MyGui.Add("Text",, "Get to Access TC Node Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", TCMenu)

;Rescan of TC Nodes CAN IDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x100 y483", "Re-Initialize PCAN").OnEvent("Click", TCPCANReinitialize)

MyGui.Add("Text","x26 y518", "Choose TC Node")
TCAccess := MyGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCAccess.OnEvent("Change", UseTCID)

MyGui.Add("Text","x360 y39", "Change TC Node Usage")
TCUsage := MyGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCUsage.OnEvent("Change", ChangeTCID)

MyGui.Add("Text","" , "Check Current Settings")
MyGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

;Text for IDs
MyGui.Add("Text","x600 y39", "Update Altus/Board ID")
MyGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
TCAltusID := MyGui.Add("Edit","x750 y39")
TCToolID := MyGui.Add("Edit")

TCAltusID.SetFont("cBlack")
TCToolID.SetFont("cBlack")

TCTCIdBtn := MyGui.Add("Button",, "Update IDs")
TCTCIdBtn.OnEvent("Click", UpdateTCIDs)

TCAltusID.OnEvent("Focus", TCBtnFocus)
TCAltusID.OnEvent("LoseFocus", TCBtnUnFocus)

TCToolID.OnEvent("Focus", TCBtnFocus)
TCToolID.OnEvent("LoseFocus", TCBtnUnFocus)



;Disable Wheel scrolling

#HotIf WinActive(MyGui)
WheelUp::return

WheelDown::return

;Close Both windows
SetTimer CheckProgram, 500

GuiClosed := MyGui.OnEvent("Close", CloseGui)

MyGui.Show()

CloseGui(*){
    ProcessClose "tkToolUtility.exe"
}

SolSensorUpdateBTNFocus(*){
    SensorValuesBTN.Opt("+Default")
}

SolSensorUpdateBTNUnFocus(*){
    SensorValuesBTN.Opt("-Default")
}

SolIdBTNFocus(*){
    SolUpdateIDBtn.Opt("+Default")
}

SolIdBTNUnFocus(*){
    SolUpdateIDBtn.Opt("-Default")
}

CheckProgram(*){
    if !WinExist("ahk_exe tkToolUtility.exe")
        {
            
            Sleep 500
            ExitApp
            Sleep 500
            SetTimer CheckProgram, 0
            ;SetTimer CheckFile, 0
            ;SetTimer CheckForNewFile, 0
        }
        
}

RestartTestUtil(*){
    SetTimer CheckProgram, 0
    WinClose("ahk_exe tkToolUtility.exe")
    Sleep 200
    Run "tkToolUtility.exe"
    Sleep 700
    MCID.Value := ""
    QTID.Value := ""
    DCDCID.Value := ""
    RBID.Value := ""
    SolInput.Value := ""
    Sensorm.Value := ""
    Sensorb.Value := ""
    SensorCb.Value := ""
    SensorCm.Value := ""
    SensorBb.Value := ""
    SensorBm.Value := ""
    SensorAb.Value := ""
    SensorAm.Value := ""
    AltusID.Value := ""
    ToolID.Value := ""
    TCAltusID.Value := ""
    TCToolID.Value := ""

    QTComChoice.Choose 0
    QTCOMPort.Choose 0
    BoardChoice.Choose 0
    ComChoice.Choose 0
    COMPort.Choose 0
    ChooseSolFWIns.Choose 0
    SolenoidAccess.Choose 0
    SolenoidUse.Choose 0
    SensorType.Choose 0
    SolenoidSensors.Choose 0
    TCComChoice.Choose 0
    TCCOMPort.Choose 0
    ChooseTCFWIns.Choose 0
    TCAccess.Choose 0
    TCUsage.Choose 0
    WinMove(0,0,,, "ahk_exe tkToolUtility.exe")
    Sleep 200
    WinActivate ("V2.1 TestUtilityGUI For Use With TestUtilityV40")
    ControlSend  "{Enter}", , "tkToolUtility.exe"
    SetTimer CheckProgram, 500
}

InstallSolenoidEz(*){
    Enter()
    SendKeystrokeFromListbox()
    ;COMPortSelect()
    InstallFWSolenoid()
    Sleep 909000
    Sleep 5000
    ControlSend  "{n}", , "tkToolUtility.exe"
    SetTimer CheckProgram, 0
    Sleep 1000
    ControlSend  "{Enter}", , "tkToolUtility.exe"
    Sleep 1000
    
    Run "tkToolUtility.exe"
    Sleep 500
    SetTimer CheckProgram, 500
    Sleep 500
    WinMove(0,0,,, "ahk_exe tkToolUtility.exe")
    Sleep 500
    WinActivate ("V2.1 TestUtilityGUI For Use With TestUtilityV40") 
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

 AccessSolenoidEz(*){
    Enter()
    SendKeystrokeFromListbox()
    Keystroke1()
    TestOption := ComChoice.Text
    switch TestOption {
        case "PCAN":
            ;return
        case "QPSK/MasterBox":
            
            ControlSend  COMPort.Text ,, "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "OFDM":
           ;return
    }
    Sleep 200
    ;SolTestFileRead()
    
}


QTCOMPortSelect(*){

    ;ControlSend  "{C}", , "tkToolUtility.exe"
    ;ControlSend  "{O}", , "tkToolUtility.exe"
    ;ControlSend  "{M}", , "tkToolUtility.exe"
    ControlSend  QTCOMPort.Text ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 500
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 600

    if (BoardChoice.Text == "Master Controller"){
        Sleep 500
        ControlSend  "{3}", , "tkToolUtility.exe"
        Keystroke8()
        Sleep 200
        ControlSend "{Enter}", , "tkToolUtility.exe"
    }
    else{
        return
    }
}

BoardSelect(*){
    SelectedBoard := BoardChoice.Text
    Switch SelectedBoard{
        Case "Master Controller" :
            MasterController()
            QTCOMPortSelect()
        Case "DCDC Converter" :
            DCDC()
            QTCOMPortSelect()
        Case "Relay Board" :
            RelayBoard()
            QTCOMPortSelect()
    }
}

McQtBtnFocus(*){
    MCBtn.Opt("+Default")
}
McQtBtnUnFocus(*){
    MCBtn.Opt("-Default")
}

DCDCBtnFocus(*){
    DCDCBtn.Opt("+Default")
}

DCDCBtnUnFocus(*){
    DCDCBtn.Opt("-Default")
}

RBBtnFocus(*){
    RBBtn.Opt("+Default")
}

RBBtnUnFocus(*){
    RBBtn.Opt("-Default")
}

EnterToSaveQT(*){
    BoardSave := BoardChoice.Text
    Switch BoardSave{
        Case "Master Controller" :
            UpdateQIDs()
        Case "DCDC Converter" :
            UpdateDCDCID()
        Case "Relay Board" :
            UpdateRBID()
    }
}

MasterController(*){
    SelectedQTCom := QTComChoice.Text
    Switch SelectedQTCom {
        Case "QPSK" :
            Keystroke1()
            Sleep 100
            Keystroke2()
            Sleep 100
            Keystroke1()
        Case "OFDM" :
            Keystroke1()
            Sleep 100
            Keystroke3()
            Sleep 100
            Keystroke1()
    }
}

DCDC(*){
    SelectedQTCom := QTComChoice.Text
    Switch SelectedQTCom {
        Case "QPSK" :
            Keystroke1()
            Sleep 100
            Keystroke2()
            Sleep 100
            Keystroke2()
        Case "OFDM" :
            Keystroke1()
            Sleep 100
            Keystroke3()
            Sleep 100
            Keystroke2()
    }
}

RelayBoard(*){
    SelectedQTCom := QTComChoice.Text
    Switch SelectedQTCom {
        Case "QPSK" :
            Keystroke1()
            Sleep 100
            Keystroke2()
            Sleep 100
            Keystroke3()
        Case "OFDM" :
            Keystroke1()
            Sleep 100
            Keystroke3()
            Sleep 100
            Keystroke3()
    }
}



WriteLowerWindow(*){
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
}

WriteUpperWindow(*){
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend  "{4}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
}

RaisedStartup(*){
    WriteLowerWindow()
    Sleep 300
    ControlSend  "{8}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 1000
    WriteUpperWindow()
    Sleep 300
    ControlSend  "{9}", , "tkToolUtility.exe"
    ControlSend  "{5}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    
}


DefaultStartup(*){
    WriteLowerWindow()
    Sleep 300
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 1000
    WriteUpperWindow()
    Sleep 300
    ControlSend  "{4}", , "tkToolUtility.exe"
    ControlSend  "{5}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
}

UpdateMCID(*){
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend  "{5}", , "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

UpdateQTID(*){
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend  "{6}", , "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

UpdateQIDs(*){

    if (MCID.Value != "" && QTID.Value == ""){
        UpdateMCID()
        Sleep 400
        ControlSend  MCID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        MCID.Value := ""
        Sleep 300
        MCSave()
}
    else if QTID.Value != "" && MCID.Value == ""{
        UpdateQTID()
        Sleep 400
        ControlSend  QTID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        QTID.Value := ""
        Sleep 300
        MCSave()
}
    else if MCID.Value != "" && QTID.Value != ""{
        UpdateMCID()
        Sleep 200
        ControlSend  MCID.Value,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}",, "tkToolUtility.exe"
        Sleep 600
        MCID.Value := ""
        Sleep 400
        UpdateQTID()
        Sleep 200
        ControlSend  QTID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        QTID.Value := ""
        Sleep 300
        MCSave()
    }
    else{
        return
    }
}


UpdateDCDCID(*){
    ControlSend  "{2}", , "tkToolUtility.exe"
    ControlSend  "{4}", , "tkToolUtility.exe"
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  DCDCID.Value, , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    DCDCID.Value := ""
}


UpdateRBID(*){
    ControlSend  "{2}", , "tkToolUtility.exe"
    ControlSend  "{4}", , "tkToolUtility.exe"
    ControlSend  "{3}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  RBID.Value, , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend  "{6}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    RBID.Value := ""
    Sleep 300
    ControlSend  "{y}", , "tkToolUtility.exe"
}


SendKeystrokeFromListbox(*){
    SelectedOption := ComChoice.Text
    switch SelectedOption {
        case "PCAN":
            Keystroke1()
        case "QPSK/MasterBox":
            Keystroke2()
            
        case "OFDM":
            Keystroke3()
    }
}

COMPortSelect(*){

    ;ControlSend  "{C}", , "tkToolUtility.exe"
    ;ControlSend  "{O}", , "tkToolUtility.exe"
    ;ControlSend  "{M}", , "tkToolUtility.exe"
    ControlSend  COMPort.Text ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 500
    ControlSend "{Enter}", , "tkToolUtility.exe"
}

TCCOMPortSelect(*){

    ;ControlSend  "{C}", , "tkToolUtility.exe"
    ;ControlSend  "{O}", , "tkToolUtility.exe"
    ;ControlSend  "{M}", , "tkToolUtility.exe"
    ControlSend  TCCOMPort.Text ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 500
    ControlSend "{Enter}", , "tkToolUtility.exe"
}



PingNodes(*){
    Keystroke3()
    Sleep 500
}

PCANReinitialize(*){
    Keystroke9()
    Sleep 500
}

TCPCANReinitialize(*){
    Keystroke7()
    Sleep 500
}

AccessSolenoid(*){
    Keystroke1()
    Sleep 600
}

SolenoidIDs(*){
    SolenoidIDAccess := SolenoidAccess.Text
    Sleep 200
    Keystroke4()
    Sleep 150
    Hex0x1()
    Sleep 250
    Switch SolenoidIDAccess {
        case "FlexDrive - 0x12": 
        Keystroke2()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "MotorPump - 0x13":
        Keystroke3()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "CompactTracMP - 0x13":
        Keystroke3()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "SJR - 0x14":
        Keystroke4()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "PrimeStroker - 0x15":
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "ShortStroker - 0x15":
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "ShortStrokerV2 - 0x15":
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "Puncher - 0x16":
        Keystroke6()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
}
}
    

OpenFiledialogSolenoid(*){
    SelectedFWFile := FileSelect(1,,"Select Firmware","Firmware (*.hex)")
    if (SelectedFWFile != "")
    {
        destinationDir := A_ScriptDir . "\\hexFiles_SOL\\"
        newName := "SOL_leinApp_bl.hex"

        destinationFile := destinationDir . newName

        FileCopy(SelectedFWFile, destinationFile, 1)
        
        if (FileExist(destinationFile))
            {
            
                Sleep 1000
                CheckFWLoopSol()

            }


    }

}

InstallFWSolenoid(*){
    SelectedCom := ComChoice.Text
    SolChosen := ChooseSolFWIns.Text
    switch SelectedCom {
        case "PCAN":
        ControlSend "{3}",, "tkToolUtility.exe"
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100 
        Switch SolChosen {
            Case "":
            ControlSend "{N}",, "tkToolUtility.exe"
            InsSID()
            case "FlexDrive - 0x12": 
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke2()
            Sleep 200
            InsSID()
            case "MotorPump - 0x13":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke3()
            Sleep 200
            InsSID()
            case "CompactTracMP - 0x13":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke3()
            Sleep 200
            InsSID()
            case "SJR - 0x14":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke4()
            Sleep 200
            InsSID()
            case "PrimeStroker - 0x15":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke5()
            Sleep 200
            InsSID()
            case "ShortStroker - 0x15":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke5()
            Sleep 200
            InsSID()
            case "ShortStrokerV2 - 0x15":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke5()
            Sleep 200
            InsSID()
            case "Puncher - 0x16":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke6()
            Sleep 200
            InsSID()
        }
        case "QPSK/MasterBox":
        Keystroke3()
        Sleep 100
        ;ControlSend  "{C}", , "tkToolUtility.exe"
       ; ControlSend  "{O}", , "tkToolUtility.exe"
        ;ControlSend  "{M}", , "tkToolUtility.exe"
        ControlSend  COMPort.Text ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100 
        Switch SolChosen {
            Case "":
            ControlSend "{N}",, "tkToolUtility.exe"
            InsSID()
            case "FlexDrive - 0x12": 
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke2()
            Sleep 200
            InsSID()
            case "MotorPump - 0x13":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke3()
            Sleep 200
            InsSID()
            case "CompactTracMP - 0x13":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke3()
            Sleep 200
            InsSID()
            case "SJR - 0x14":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke4()
            Sleep 200
            InsSID()
            case "PrimeStroker - 0x15":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke5()
            Sleep 200
            InsSID()
            case "ShortStroker - 0x15":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke5()
            Sleep 200
            InsSID()
            case "ShortStrokerV2 - 0x15":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke5()
            Sleep 200
            InsSID()
            case "Puncher - 0x16":
            ControlSend  "{y}", , "tkToolUtility.exe"
            Hex0x1()
            Keystroke6()
            Sleep 200
            InsSID()
        }
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "OFDM":
            Keystroke3()
    }
}

InsSID(*){
    ControlSend "{n}",, "tkToolUtility.exe"     
    Sleep 200
    ControlSend  "{Enter}", , "tkToolUtility.exe"    
}

SolenoidUsage(*){
    SolenoidSelected := SolenoidUse.Text
    Sleep 100
    Hex0xF4()
    Sleep 200
    switch SolenoidSelected {
        case "FlexDrive - 0x12": 
        Keystroke3()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "MotorPump - 0x13":
        Keystroke1()
        Sleep 200
        ControlSend  "{n}", , "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "CompactTracMP - 0x13":
        Keystroke2()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "SJR - 0x14":
        Keystroke4()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "PrimeStroker - 0x15":
        Keystroke5()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStroker - 0x15":
        Keystroke6()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStrokerV2 - 0x15":
        Keystroke7()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "Puncher - 0x16":
        Keystroke8()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
    }

}

SensorTypeChange(*){
    Hex0x8F()
    Sleep 200
    SelectedSensorType := SensorType.Text
    switch SelectedSensorType {
        case "Unknown":
            Keystroke0()
            Sleep 200
            Hex0xCB()
            Sleep 200
            ControlSend  "{y}", , "tkToolUtility.exe"
        case "Mech":
            Keystroke1()
            Sleep 200
            Hex0xCB()
            Sleep 200
            ControlSend  "{y}", , "tkToolUtility.exe"
        case "HallEffect":
            Keystroke2()
            Sleep 200
            Hex0xCB()
            Sleep 200
            ControlSend  "{y}", , "tkToolUtility.exe"
        Case "QuadEncoder":
            Keystroke3()
            Sleep 200
            Hex0xCB()
            Sleep 200
            ControlSend  "{y}", , "tkToolUtility.exe"

}
}

SensorIDs(*){
    Hex0xFA()
    Sleep 200
    SelectedSensorIDs := SolenoidSensors.Text
    switch SelectedSensorIDs {
        case "DDP3 '9a' Linear":
            Keystroke1()
            Sleep 100
            Keystroke1()
        case "DDP3 '9b' Linear":
            Keystroke2()
            Sleep 100
            Keystroke1()
        case "Comp '10' Linear":
            Keystroke3()
            Sleep 100
            Keystroke1()
        Case "AncUpper '13a' Quad":
            Keystroke4()
            Sleep 100
            Keystroke2()
        Case "AncLower '13b' Quad":
            Keystroke5()
            Sleep 100
            Keystroke2()
        Case "Sensor6 'Not in Use'":
            ;Keystroke6()
            MsgBox "Not in use currently"
        Case "Sensor7 'Not in Use'":
            ;Keystroke7()
            MsgBox "Not in use currently"

}
}

UpdateSensorValues(*){
    
    SelectedSensors := SolenoidSensors.Text
    switch SelectedSensors {
        case "DDP3 '9a' Linear":
            ControlSend  Sensorm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  Sensorb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        case "DDP3 '9b' Linear":
            ControlSend  Sensorm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  Sensorb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        case "Comp '10' Linear":
            ControlSend  Sensorm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  Sensorb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        Case "AncUpper '13a' Quad":
            ControlSend  SensorCb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorCm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorBb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorBm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorAb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorAm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        Case "AncLower '13b' Quad":
            ControlSend  SensorCb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorCm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorBb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorBm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorAb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Space}", , "tkToolUtility.exe"
            ControlSend  SensorAm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        Case "Sensor6 'Not in Use'":
            MsgBox "Not in use currently"
        Case "Sensor7 'Not in Use'":
            MsgBox "Not in use currently"

}
Sleep 500
Sensorm.Value := ""
Sensorb.Value := ""
SensorCb.Value := ""
SensorCm.Value := ""
SensorBb.Value := ""
SensorBm.Value := ""
SensorAb.Value := ""
SensorAm.Value := ""
}

CheckSet(*){
    Hex0xF2()
}

CheckCal(*){
    Hex0xF1()
}

SolenoidSwitching(*){
    Hex0xA2()
    Sleep 200
    ControlSend  "{n}", , "tkToolUtility.exe"
    Sleep 200
    ControlSend  "{n}", , "tkToolUtility.exe"
    Sleep 200
    ControlSend  "{n}", , "tkToolUtility.exe"
    Sleep 200
    ControlSend  "{n}", , "tkToolUtility.exe"
    Sleep 200
    ControlSend  "{n}", , "tkToolUtility.exe"
    Sleep 200
    ControlSend  "{n}", , "tkToolUtility.exe"
    Sleep 300
    Hex0xDA()
}

UpdateIDs(*){

    if (AltusID.Value != "" && ToolID.Value == ""){
        Hex0x8A()
        Sleep 400
        ControlSend  AltusID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        AltusID.Value := ""
        Sleep 300
        Hex0xCB()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if ToolID.Value != "" && AltusID.Value == ""{
        Hex0x8C()
        Sleep 400
        ControlSend  ToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        ToolID.Value := ""
        Sleep 300
        Hex0xCB()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if AltusID.Value != "" && ToolID.Value != ""{
        Hex0x8A()
        Sleep 200
        ControlSend  AltusID.Value,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}",, "tkToolUtility.exe"
        Sleep 600
        AltusID.Value := ""
        Sleep 400
        Hex0x8C()
        Sleep 200
        ControlSend  ToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        ToolID.Value := ""
        Sleep 300
        Hex0xCB()
        ControlSend  "{y}", , "tkToolUtility.exe"
    }
    else{
        return
    }
}

OpenFiledialogTC(*){
    SelectedTCFWFile := FileSelect(1,,"Select Firmware","Firmware (*.hex)")
    if (SelectedTCFWFile != "")
    {
        destinationTCDir := A_ScriptDir . "\\hexFiles_TC\\"
        newName := "TC_leinApp_bl.hex"

        destinationTCFile := destinationTCDir . newName

        FileCopy(SelectedTCFWFile, destinationTCFile, 1)

        if (FileExist(destinationTCFile))
            {
            
                Sleep 1000
                CheckFWLoopTC()

            }

    }
}



InstallFWTC(*){
    SelectedTCCom := TCComChoice.Text
    switch SelectedTCCom {
        case "PCAN":
        Keystroke3()
        Sleep 100 
        Keystroke1()
        Sleep 100 
        Keystroke3()
        Sleep 100 
        ChooseTC := ChooseTCFWIns.Text
        Switch ChooseTC{
            Case "":
            ControlSend "{N}",, "tkToolUtility.exe"
            InsSID()
            Case "Upper PR STR - 0x30" :
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke0()
            InsSID()
            Case "Lower PR STR - 0x31" :
            Hex0x3()
            Sleep 100
            Keystroke1()
            InsSID()
            Case "Upper TC - 0x32" :
            Hex0x3()
            Sleep 100
            Keystroke2()
            InsSID()
            Case "Lower TC - 0x33" :
            Hex0x3()
            Sleep 100
            Keystroke3()
            InsSID()
            Case "DDR TC SJR - 0x34" :
            Hex0x3()
            Sleep 100
            Keystroke4()
            InsSID()
        }

        ReopenAfterIns()

        case "QPSK/MasterBox":
        Keystroke3()
        Sleep 100
        Keystroke3()
        ;ControlSend  "{C}", , "tkToolUtility.exe"
        ;ControlSend  "{O}", , "tkToolUtility.exe"
        ;ControlSend  "{M}", , "tkToolUtility.exe"
        ControlSend  TCCOMPort.Text ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100 
        ChooseTC := ChooseTCFWIns.Text
        Switch ChooseTC{
            Case "":
            ControlSend "{N}",, "tkToolUtility.exe"
            InsSID()
            Case "Upper PR STR - 0x30" :
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke0()
            InsSID()
            Case "Lower PR STR - 0x31" :
            Hex0x3()
            Sleep 100
            Keystroke1()
            InsSID()
            Case "Upper TC - 0x32" :
            Hex0x3()
            Sleep 100
            Keystroke2()
            InsSID()
            Case "Lower TC - 0x33" :
            Hex0x3()
            Sleep 100
            Keystroke3()
            InsSID()
            Case "DDR TC SJR - 0x34" :
            Hex0x3()
            Sleep 100
            Keystroke4()
            InsSID()
        }
        ReopenAfterIns()

        case "OFDM":
            Keystroke3()
    }
}


ReopenAfterIns(*){
    Sleep 89000
    Sleep 5000
    ControlSend  "{n}", , "tkToolUtility.exe"
    SetTimer CheckProgram, 0
    Sleep 1000
    ControlSend  "{Enter}", , "tkToolUtility.exe"
    Sleep 1000
    
    Run "tkToolUtility.exe"
    Sleep 500
    SetTimer CheckProgram, 500
    Sleep 500
    WinMove(0,0,,, "ahk_exe tkToolUtility.exe")
    Sleep 500 
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

TCMenu(*){
    Keystroke3()
    Sleep 200
    SelectedTCOption := TCComChoice.Text
    switch SelectedTCOption {
        case "PCAN":
            Keystroke1()
            Sleep 200
            Keystroke1()
        case "QPSK/MasterBox":
            Keystroke2()
            Sleep 200
            Keystroke1()
            ;ControlSend  "{C}", , "tkToolUtility.exe"
           ; ControlSend  "{O}", , "tkToolUtility.exe"
           ; ControlSend  "{M}", , "tkToolUtility.exe"
            ControlSend  TCCOMPort.Text ,, "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "OFDM":
            Keystroke3()
            Sleep 200
            Keystroke3()
    }
}


UseTCID(*){
    Keystroke4()
    Sleep 200
    SelectTC := TCAccess.Text
    Switch SelectTC{
        Case "Upper PR STR - 0x30" :
        Hex0x3()
        Sleep 100
        Keystroke0()

        Case "Lower PR STR - 0x31" :
        Hex0x3()
        Sleep 100
        Keystroke1()

        Case "Upper TC - 0x32" :
        Hex0x3()
        Sleep 100
        Keystroke2()

        Case "Lower TC - 0x33" :
        Hex0x3()
        Sleep 100
        Keystroke3()

        Case "DDR TC SJR - 0x34" :
        Hex0x3()
        Sleep 100
        Keystroke4()

    }
}

ChangeTCID(*){
    Hex0xF7()
    Sleep 200
    TCChange := TCUsage.Text
    Switch TCChange{
        Case "Upper PR STR - 0x30" :
        Keystroke1()
        Sleep 200
        ControlSend "{y}",, "tkToolUtility.exe"
        Hex0xCB()
        
        Case "Lower PR STR - 0x31" :
        Keystroke2()
        Sleep 200
        ControlSend "{y}",, "tkToolUtility.exe"
        Hex0xCB()

        Case "Upper TC - 0x32" :
        Keystroke3()
        Sleep 200
        ControlSend "{y}",, "tkToolUtility.exe"
        Hex0xCB()

        Case "Lower TC - 0x33" :
        Keystroke4()
        Sleep 200
        ControlSend "{y}",, "tkToolUtility.exe"
        Hex0xCB()

        Case "DDR TC SJR - 0x34" :
        Keystroke5()
        Sleep 200
        ControlSend "{y}",, "tkToolUtility.exe"
        Hex0xCB()
    }
}

TCBtnFocus(*){
    TCTCIdBtn.Opt("+Default")
}

TCBtnUnFocus(*){
    TCTCIdBtn.Opt("-Default")
}

UpdateTCIDs(*){

    if (TCAltusID.Value != "" && TCToolID.Value == ""){
        Hex0x8A()
        Sleep 400
        ControlSend  TCAltusID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        TCAltusID.Value := ""
        Sleep 300
        Hex0xCB()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if TCToolID.Value != "" && TCAltusID.Value == ""{
        Hex0x8C()
        Sleep 400
        ControlSend  TCToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        TCToolID.Value := ""
        Sleep 300
        Hex0xCB()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if TCAltusID.Value != "" && TCToolID.Value != ""{
        Hex0x8A()
        Sleep 200
        ControlSend  TCAltusID.Value,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}",, "tkToolUtility.exe"
        Sleep 600
        TCAltusID.Value := ""
        Sleep 400
        Hex0x8C()
        Sleep 200
        ControlSend  TCToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        TCToolID.Value := ""
        Sleep 300
        Hex0xCB()
        ControlSend  "{y}", , "tkToolUtility.exe"
    }
    else{
        return
    }
}

ButtonClick(*) {
    ; Send a keystroke to the console window
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

enter(*) {
    ; Send a keystroke to the console window
    ControlSend  "{2}", , "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
    
    }
    

Test(*) {
    MsgBox "testing"
}

Keystroke0(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke1(*){
    ControlSend "{1}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke2(*){
    ControlSend "{2}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke3(*){
    ControlSend "{3}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke4(*){
    ControlSend "{4}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke5(*){
    ControlSend "{5}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke6(*){
    ControlSend "{6}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke7(*){
    ControlSend "{7}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke8(*){
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Keystroke9(*){
    ControlSend "{9}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xF4(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{4}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xFA(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{A}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xF7(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{7}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xF1(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{1}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xF2(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{2}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}


Hex0x1(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{1}",, "tkToolUtility.exe"
}
 
Hex0x8F(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xCD(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{C}",, "tkToolUtility.exe"
    ControlSend "{D}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xCB(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{C}",, "tkToolUtility.exe"
    ControlSend "{B}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xA2(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{A}",, "tkToolUtility.exe"
    ControlSend "{2}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xDA(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{D}",, "tkToolUtility.exe"
    ControlSend "{A}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x8A(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend "{A}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x8C(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend "{C}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x3(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{3}",, "tkToolUtility.exe"
}

MCSave(*){
ControlSend  "{1}", , "tkToolUtility.exe"
ControlSend  "{6}", , "tkToolUtility.exe"
ControlSend  "{1}", , "tkToolUtility.exe"
ControlSend "{Enter}", , "tkToolUtility.exe"
Sleep 300

}

DCDCSave(*){
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend  "{6}", , "tkToolUtility.exe"
    ControlSend  "{0}", , "tkToolUtility.exe"

    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  "{y}", , "tkToolUtility.exe"

}

QTCheck(*){
    ControlSend "{2}" ,, "tkToolUtility.exe"
    ControlSend "{4}" ,, "tkToolUtility.exe"
    ControlSend "{1}" ,, "tkToolUtility.exe"
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
}

