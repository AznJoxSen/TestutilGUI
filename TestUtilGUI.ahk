Run "tkToolUtility.exe"
Sleep 600
ControlSend  "{Enter}", , "tkToolUtility.exe"
SetWorkingDir(A_ScriptDir)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon (iconPath)

MyGui := Gui(, "V2.2 TestUtilityGUI For Use With TestUtilityV40")

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
        SendMessage(0x0115, 7, 0, "Edit5", "V2.2 TestUtilityGUI For Use With TestUtilityV40")
        
    }
    ;else{
    ;    MsgBox "fuck"
    ;}
}

*/

;Create tabs
Tab := MyGui.Add("Tab3","-Wrap", ["Q-Telemetry", "Solenoid", "TC Node" , "1-Wire", "RSS", "Anchor Board", "Orientation"])
Tab.Font := "Bold"

;For Q-Telemetry Tab
Tab.UseTab("Q-telemetry")



MyGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

MyGui.Add("GroupBox","x18 y35 W200 H180")

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
RefreshQT.OnEvent("Click", RefreshBtn)

MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
QTInput := MyGui.Add("Edit", "")
QTInput.SetFont("cBlack")

QTInput.OnEvent("Focus", QTManBTNFocus)
QTInput.OnEvent("LoseFocus", QTManBTNUnFocus)

QTManInput := MyGui.Add("Button","x180 y620","Submit")
QTManInput.OnEvent("Click", QTInputValueEnter)

;Choose Board
MyGui.Add("Text","x26 y147", "Choose Board Type")
BoardChoice := MyGui.AddDropDownList("W150", ["Master Controller", "DCDC Converter", "Relay Board"])
BoardChoice.OnEvent("Change", BoardSelect)

MyGui.Add("GroupBox","x238 y35 W210 H250")

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

MyGui.Add("GroupBox","x486 y35 W190 H370")

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

MyGui.Add("GroupBox","x736 y35 W190 H195")

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


;----------------------------------------------------------------

;For Solenoid Tab
Tab.UseTab("Solenoid")

MyGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

MyGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for solenoid
MyGui.Add("Text","x26 y39","Select Communication Choice")
ComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
;ComChoice.OnEvent("Change", SendKeystrokeFromListbox)
ComChoice.Choose("PCAN")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
COMPort := MyGui.AddDropDownList("W75", Words)


Refresh := MyGui.Add("Button","x121 y145", "Refresh")
Refresh.OnEvent("Click", RefreshBtn)

RefreshBtn(*)
{

FileAppend("test","ComPorts.txt",)

COMPort.Delete()
QTCOMPort.Delete()
TCCOMPort.Delete()
OneWireMasterCOMPort.Delete()

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
QTCOMPort.Add(Words)
TCCOMPort.Add(Words)
OneWireMasterCOMPort.Add(Words)

}

/*

SolDisplay := MyGui.Add("Edit", " ReadOnly x26 y600 W900 H200")
SolDisplay.SetFont("cBlack")

SolDisplay.Value := SolTestContents

*/
MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
SolInput := MyGui.Add("Edit", "")
SolInput.SetFont("cBlack")

SolInput.OnEvent("Focus", SolManBTNFocus)
SolInput.OnEvent("LoseFocus", SolManBTNUnFocus)

SolManInput := MyGui.Add("Button","x180 y620","Submit")
SolManInput.OnEvent("Click", SolInputValueEnter)


MyGui.Add("GroupBox", "x280 y35 H235 W300")

MyGui.Add("Text","x290 y39", "FW Selected for Installing")
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

MyGui.Add("Button",, "Install").OnEvent("Click", InstallSolenoidEz)

MyGui.Add("GroupBox","x280 y300 H180 W230")

;Access solenoid board
MyGui.Add("Text","x290 y300", "Go to Access Solenoid Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", AccessSolenoidEz)

;Rescan of Solenoid CANIDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", SolPCANReinitialize)

;Choose what solenoid to access
MyGui.Add("Text","x290 y420", "Choose Solenoid Board")
SolenoidAccess := MyGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidAccess.OnEvent("Change", SolenoidIDs)
;CBS_DISABLENOSCROLL

MyGui.Add("GroupBox","x590 y35 W190 H236")

;Changing Solenoid Usage
MyGui.Add("Text","x600 y39", "Change Solenoid Usage")
SolenoidUse := MyGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidUse.OnEvent("Change", SolenoidUsage)

;Changing sensor types
MyGui.Add("Text","" , "Change Sensor Type")
SensorType := MyGui.AddDropDownList("W170",["HallEffect", "QuadEncoder", "Mech", "Unknown"])
SensorType.OnEvent("Change", SensorTypeChange)



MyGui.Add("Text","" , "Check Current Settings")
MyGui.Add("Button",,"Check").OnEvent("Click", CheckSet)

MyGui.Add("Text","" , "Check Calibration Table")
MyGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

MyGui.Add("GroupBox","x590 y355 W170 H102")

;Test Solenoid
MyGui.Add("Text","x600 y360" , "For EL.LAB Use Only!")
MyGui.Add("Text","" ,"Test Solenoid Switching")
MyGui.Add("Button",, "Test Switching").OnEvent("Click", SolenoidSwitching)

MyGui.Add("GroupBox","x790 y35 W325 H525")

;Text for sensor values
MyGui.Add("Text","x800 y172", "SensorLinear m")
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


MyGui.Add("Text","x800 y39" , "Select Approiate Application")
SolRadioBtn1 := MyGui.Add("Radio", "x800 y60 Checked", "For Everything Else Sensors")
SolRadioBtn2 := MyGui.Add("Radio", "x800 y80", "For CompactStroker Sensors")

TheRestDropDownListArray := ["DDP3 '9a' Linear", "DDP3 '9b' Linear", "Comp '10' Linear", "AncUpper '13a' Quad", "AncLower '13b' Quad", "Sensor6 'Not in Use'", "Sensor7 'Not in Use'"]

CompactStrokerDropDownListArray := ["DDP3 'P-Sa' Linear", "DDP3 'P-Sb' Linear", "DDP3 'P-LF' Linear", "DDP500 'P-Comp' Linear", "DDP3 'P-TW' Linear", "AncUpper 'P-Ga' Quad", "AncLower 'P-Gb' Quad"]


;Changing sensor values
MyGui.Add("Text","x800 y110" , "Choose Sensor To Update Values")
SolenoidSensorsDropDownList := MyGui.AddDropDownList("W230", TheRestDropDownListArray)
SolenoidSensorsDropDownList.OnEvent("Change", SensorIDs)
;Input edit box for sensor values

SolRadioBtn1.OnEvent("Click", SolenoidSensorTypes)
SolRadioBtn2.OnEvent("Click", SolenoidSensorTypesStroker)



;MyGui.Add("Text","x950 y80","Add Sensor values")
Sensorm := MyGui.Add("Edit","x950 y167")
Sensorb := MyGui.Add("Edit")
SensorCb := MyGui.Add("Edit")
SensorCm := MyGui.Add("Edit")
SensorBb := MyGui.Add("Edit")
SensorBm := MyGui.Add("Edit")
SensorAb := MyGui.Add("Edit")
SensorAm := MyGui.Add("Edit")
SensorValuesBTN := MyGui.Add("Button",, "Update Values")
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


;----------------------------------------------------------------

; For TC Node tab
Tab.UseTab("TC Node")

MyGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

MyGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for TC Node
MyGui.Add("Text","x26 y39","Select Communication Choice")
TCComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])
TCComChoice.Choose("PCAN")

MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
TCCOMPort := MyGui.AddDropDownList("W75", Words)
;TCCOMPort.SetFont("cBlack")
;MyGui.Add("UpDown") 

RefreshTC := MyGui.Add("Button","x121 y145", "Refresh")
RefreshTC.OnEvent("Click", RefreshBtn)


MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
TCInput := MyGui.Add("Edit", "")
TCInput.SetFont("cBlack")



TCInput.OnEvent("Focus", TCManBTNFocus)
TCInput.OnEvent("LoseFocus", TCManBTNUnFocus)

TCManInput := MyGui.Add("Button","x180 y620","Submit")
TCManInput.OnEvent("Click", TCInputValueEnter)


MyGui.Add("GroupBox", "x280 y35 H235 W300")

MyGui.Add("Text","x290 y39", "FW Selected for Installing")
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

MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWTC)

MyGui.Add("GroupBox","x280 y300 H180 W230")

;Access TC NOde
MyGui.Add("Text","x290 y300", "Go to Access TC Node Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", TCMenu)

;Rescan of TC Nodes CAN IDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

MyGui.Add("Text","x290 y420", "Choose TC Node")
TCAccess := MyGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCAccess.OnEvent("Change", UseTCID)

MyGui.Add("GroupBox","x590 y35 W190 H125")

MyGui.Add("Text","x600 y39", "Change TC Node Usage")
TCUsage := MyGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCUsage.OnEvent("Change", ChangeTCID)

MyGui.Add("Text","" , "Check Current Settings")
MyGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

MyGui.Add("GroupBox","x790 y35 W325 H130")

;Text for IDs
MyGui.Add("Text","x800 y60", "Update Altus/Board ID")
MyGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
MyGui.Add("Text","x950 y39","Input IDs")
TCAltusID := MyGui.Add("Edit","x950 y60")
TCToolID := MyGui.Add("Edit")

TCAltusID.SetFont("cBlack")
TCToolID.SetFont("cBlack")

TCTCIdBtn := MyGui.Add("Button",, "Update IDs")
TCTCIdBtn.OnEvent("Click", UpdateTCIDs)

TCAltusID.OnEvent("Focus", TCBtnFocus)
TCAltusID.OnEvent("LoseFocus", TCBtnUnFocus)

TCToolID.OnEvent("Focus", TCBtnFocus)
TCToolID.OnEvent("LoseFocus", TCBtnUnFocus)


;----------------------------------------------------------------

;For 1 Wire Master/Slave
Tab.UseTab("1-Wire")
MyGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

MyGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for 1-wire
MyGui.Add("Text","x26 y39","Select Communication Choice")
OneWireMasterComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])
OneWireMasterComChoice.Choose("PCAN")

MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
OneWireMasterCOMPort := MyGui.AddDropDownList("W75", Words)
;TCCOMPort.SetFont("cBlack")
;MyGui.Add("UpDown") 

RefreshOneWire := MyGui.Add("Button","x121 y145", "Refresh")
RefreshOneWire.OnEvent("Click", RefreshBtn)


MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
OneWireMasterInput := MyGui.Add("Edit", "")
OneWireMasterInput.SetFont("cBlack")

OneWireMasterInput.OnEvent("Focus", OneWireMasterManBTNFocus)
OneWireMasterInput.OnEvent("LoseFocus", OneWireMasterManBTNUnFocus)

OneWireMasterManInput := MyGui.Add("Button","x180 y620","Submit")
OneWireMasterManInput.OnEvent("Click", OneWireMasterInputValueEnter)



MyGui.Add("GroupBox", "x280 y35 H180 W260")

MyGui.Add("Text","x290 y39", "FW Selected for Installing 1-Wire Master")
OneWireMasterFW := MyGui.Add("Edit", "ReadOnly")
OneWireMasterFW.SetFont("cBlack")

fileOneWireMasterContents := FileRead("hexFiles_SWC\SWC_leinApp_bl.hex")
OneWireMasterFolder := ("1-W-Master FW\Main FW\*.hex")

Loop Files OneWireMasterFolder, "F"
    {
        FilePathOneWireM := A_LoopFileFullPath
        CurrentFileOneWireM := FileRead(FilePathOneWireM)

if (fileOneWireMasterContents == CurrentFileOneWireM) 
    {      
    FWOneWireMasterFile := A_LoopFileName
        OneWireMasterFW.Text := FWOneWireMasterFile

    break
    }
    }

CheckFWLoopOneWireMaster(*){
Loop Files OneWireMasterFolder, "F"
    {
        fileOneWireMasterContents := FileRead("hexFiles_SWC\SWC_leinApp_bl.hex")
        FilePathOneWireM := A_LoopFileFullPath

        CurrentFileOneWireM := FileRead(FilePathOneWireM)
if (fileOneWireMasterContents == CurrentFileOneWireM) 
    {
    FWOneWireMasterFile := A_LoopFileName
        OneWireMasterFW.Text := FWOneWireMasterFile
        FWOneWireMasterFile := ""
        CurrentFileOneWireM := ""
    break
    }
    }
}

;Browse for FW for One Wire Master
MyGui.Add("Text","", "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogOneWireMaster)

;Install FW to One Wire Master
MyGui.Add("Text",, "Install Firmware to One Wire Master")

MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWOneWireMaster)

MyGui.Add("GroupBox","x280 y300 H180 W240")

;Access One Wire Master NOde
MyGui.Add("Text","x290 y300", "Go to Access One Wire Master Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", OneWireMasterMenu)

;Rescan of One Wire Master Nodes CAN IDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

MyGui.Add("Text","x290 y420", "Choose One Wire Master")
OneWireMasterAccess := MyGui.AddDropDownList("W170", ["One Wire Master - 0x3A"])
OneWireMasterAccess.OnEvent("Change", UseOneWireMasterID)


MyGui.Add("GroupBox","x560 y35 W325 H130")

;Text for IDs
MyGui.Add("Text","x570 y60", "Update Altus/Board ID")
MyGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
MyGui.Add("Text","x720 y39","Input One Wire Master IDs")
OneWireMasterAltusID := MyGui.Add("Edit","x720 y60")
OneWireMasterToolID := MyGui.Add("Edit")

OneWireMasterAltusID.SetFont("cBlack")
OneWireMasterToolID.SetFont("cBlack")

OneWireMasterIdBtn := MyGui.Add("Button",, "Update IDs")
OneWireMasterIdBtn.OnEvent("Click", UpdateOneWireMasterIDs)

OneWireMasterAltusID.OnEvent("Focus", OneWireMasterBtnFocus)
OneWireMasterAltusID.OnEvent("LoseFocus", OneWireMasterBtnUnFocus)

OneWireMasterToolID.OnEvent("Focus", OneWireMasterBtnFocus)
OneWireMasterToolID.OnEvent("LoseFocus", OneWireMasterBtnUnFocus)


;----------------------------------------------------------------

;For RSS
Tab.UseTab("RSS")
MyGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

MyGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for RSS
MyGui.Add("Text","x26 y39","Select Communication Choice")
RSSComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
;ComChoice.OnEvent("Change", SendKeystrokeFromListbox)
RSSComChoice.Choose("PCAN")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
RSSCOMPort := MyGui.AddDropDownList("W75", Words)


RefreshRSS := MyGui.Add("Button","x121 y145", "Refresh")
RefreshRSS.OnEvent("Click", RefreshBtn)

MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
RSSInput := MyGui.Add("Edit", "")
RSSInput.SetFont("cBlack")

RSSInput.OnEvent("Focus", RSSManBTNFocus)
RSSInput.OnEvent("LoseFocus", RSSManBTNUnFocus)

RSSManInput := MyGui.Add("Button","x180 y620","Submit")
RSSManInput.OnEvent("Click", RSSInputValueEnter)


MyGui.Add("GroupBox", "x280 y35 H235 W310")

MyGui.Add("Text","x290 y39", "FW Selected for Installing")
RSSFW := MyGui.Add("Edit", "ReadOnly")
RSSFW.SetFont("cBlack")

fileRSSContents := FileRead("hexFiles_RSS\RSS_leinApp_bl.hex")
RSSFolder := ("RSS FW\*.hex")

Loop Files RSSFolder, "F"
    {
        FilePathRSS := A_LoopFileFullPath
        CurrentFileRSS := FileRead(FilePathRSS)

if (fileRSSContents == CurrentFileRSS) 
    {      
    FWRSSFile := A_LoopFileName
        RSSFW.Text := FWRSSFile

    break
    }
    }

CheckFWLoopRSS(*){
Loop Files RSSFolder, "F"
    {
        fileRSSContents := FileRead("hexFiles_RSS\RSS_leinApp_bl.hex")
        FilePathRSS := A_LoopFileFullPath

        CurrentFileRSS := FileRead(FilePathRSS)
if (fileRSSContents == CurrentFileRSS) 
    {
    FWRSSFile := A_LoopFileName
        RSSFW.Text := FWRSSFile
        FWRSSFile := ""
        CurrentFileRSS := ""
    break
    }
    }
}




;Browse for FW for RSS Node
MyGui.Add("Text","", "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogRSS)

MyGui.Add("Text",, "Choose an RSS Node if more than one connected")
ChooseRSSFWIns := MyGui.AddDropDownList("W160", ["Upper RSS - 0x1A","Lower RSS - 0x1B"])

;Install FW to RSS Node
MyGui.Add("Text",, "Install Firmware to RSS Node")

MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWRSS)


MyGui.Add("GroupBox","x280 y300 H180 W230")

;Access RSS NOde
MyGui.Add("Text","x290 y300", "Go to Access RSS Node Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", RSSMenu)

;Rescan of RSS Nodes CAN IDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

MyGui.Add("Text","x290 y420", "Choose RSS")
RSSAccess := MyGui.AddDropDownList("W160", ["Upper RSS - 0x1A","Lower RSS - 0x1B"])
RSSAccess.OnEvent("Change", UseRSSID)

;----------------------------------------------------------------

;For Anchor Board
Tab.UseTab("Anchor Board")
MyGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

MyGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for Anchor Board
MyGui.Add("Text","x26 y39","Select Communication Choice")
AnchorBoardComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
AnchorBoardComChoice.Choose("PCAN")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
AnchorBoardCOMPort := MyGui.AddDropDownList("W75", Words)


RefreshAnchorBoard := MyGui.Add("Button","x121 y145", "Refresh")
RefreshAnchorBoard.OnEvent("Click", RefreshBtn)



MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
AnchorBoardInput := MyGui.Add("Edit", "")
AnchorBoardInput.SetFont("cBlack")

AnchorBoardInput.OnEvent("Focus", AnchorBoardManBTNFocus)
AnchorBoardInput.OnEvent("LoseFocus", AnchorBoardManBTNUnFocus)

AnchorBoardManInput := MyGui.Add("Button","x180 y620","Submit")
AnchorBoardManInput.OnEvent("Click", AnchorBoardInputValueEnter)


MyGui.Add("GroupBox", "x280 y35 H235 W370")

MyGui.Add("Text","x290 y39", "FW Selected for Installing")
AnchorBoardFW := MyGui.Add("Edit", "ReadOnly")
AnchorBoardFW.SetFont("cBlack")

fileAnchorBoardContents := FileRead("hexFiles_ANC\ANC_leinApp_bl.hex")
AnchorBoardFolder := ("Anchor Board FW\*.hex")

Loop Files AnchorBoardFolder, "F"
    {
        FilePathAnchorBoard := A_LoopFileFullPath
        CurrentFileAnchorBoard := FileRead(FilePathAnchorBoard)

if (fileAnchorBoardContents == CurrentFileAnchorBoard) 
    {      
    FWAnchorBoardFile := A_LoopFileName
        AnchorBoardFW.Text := FWAnchorBoardFile

    break
    }
    }

CheckFWLoopAnchorBoard(*){
Loop Files AnchorBoardFolder, "F"
    {
        fileAnchorBoardContents := FileRead("hexFiles_ANC\ANC_leinApp_bl.hex")
        FilePathAnchorBoard := A_LoopFileFullPath

        CurrentFileAnchorBoard := FileRead(FilePathAnchorBoard)
if (fileAnchorBoardContents == CurrentFileAnchorBoard) 
    {
    FWAnchorBoardFile := A_LoopFileName
        AnchorBoardFW.Text := FWAnchorBoardFile
        FWAnchorBoardFile := ""
        CurrentFileAnchorBoard := ""
    break
    }
    }
}

AnchorBoardArrayID := ["0x3C", "0x3D", "0x3E"]


;Browse for FW for Anchor Board Node
MyGui.Add("Text","", "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogAnchorBoard)

MyGui.Add("Text",, "Choose an Anchor Board Node if more than one connected")
ChooseAnchorBoardFWIns := MyGui.AddDropDownList("W160", AnchorBoardArrayID)

;Install FW to Anchor Board Node
MyGui.Add("Text",, "Install Firmware to Anchor Board Node")

MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWAnchorBoard)


MyGui.Add("GroupBox","x280 y300 H180 W260")

;Access Anchor Board NOde
MyGui.Add("Text","x290 y300", "Go to Access Anchor Board Node Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", AnchorBoardMenu)

;Rescan of Anchor Board Nodes CAN IDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

MyGui.Add("Text","x290 y420", "Choose Anchor Board")
AnchorBoardAccess := MyGui.AddDropDownList("W160", AnchorBoardArrayID)
AnchorBoardAccess.OnEvent("Change", UseAnchorBoardID)



;----------------------------------------------------------------

;For Orientation
Tab.UseTab("Orientation")
MyGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

MyGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for Orientation
MyGui.Add("Text","x26 y39","Select Communication Choice")
OrientationComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
OrientationComChoice.Choose("PCAN")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
OrientationCOMPort := MyGui.AddDropDownList("W75", Words)


RefreshOrientation := MyGui.Add("Button","x121 y145", "Refresh")
RefreshOrientation.OnEvent("Click", RefreshBtn)



MyGui.Add("Text", " x26 y600", "Manual input for TestUtil")
OrientationInput := MyGui.Add("Edit", "")
OrientationInput.SetFont("cBlack")

OrientationInput.OnEvent("Focus", OrientationManBTNFocus)
OrientationInput.OnEvent("LoseFocus", OrientationManBTNUnFocus)

OrientationManInput := MyGui.Add("Button","x180 y620","Submit")
OrientationManInput.OnEvent("Click", OrientationInputValueEnter)


MyGui.Add("GroupBox", "x280 y35 H235 W350")

MyGui.Add("Text","x290 y39", "FW Selected for Installing")
OrientationFW := MyGui.Add("Edit", "ReadOnly")
OrientationFW.SetFont("cBlack")

fileOrientationContents := FileRead("hexFiles_ORI\ORI_leinApp_bl.hex")
OrientationFolder := ("Orientation FW\*.hex")

Loop Files OrientationFolder, "F"
    {
        FilePathOrientation := A_LoopFileFullPath
        CurrentFileOrientation := FileRead(FilePathOrientation)

if (fileOrientationContents == CurrentFileOrientation) 
    {      
    FWOrientationFile := A_LoopFileName
        OrientationFW.Text := FWOrientationFile

    break
    }
    }

CheckFWLoopOrientation(*){
Loop Files OrientationFolder, "F"
    {
        fileOrientationContents := FileRead("hexFiles_ORI\ORI_leinApp_bl.hex")
        FilePathOrientation := A_LoopFileFullPath

        CurrentFileOrientation := FileRead(FilePathOrientation)
if (fileOrientationContents == CurrentFileOrientation) 
    {
    FWOrientationFile := A_LoopFileName
        OrientationFW.Text := FWOrientationFile
        FWOrientationFile := ""
        CurrentFileOrientation := ""
    break
    }
    }
}


OrientationArrayID := ["0x2B"]

;Browse for FW for Orientation Node
MyGui.Add("Text","", "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogOrientation)

MyGui.Add("Text",, "Choose an Orientation Node if more than one connected")
ChooseOrientationFWIns := MyGui.AddDropDownList("W160", OrientationArrayID)

;Install FW to Orientation Node
MyGui.Add("Text",, "Install Firmware to Orientation Node")

MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWOrientation)


MyGui.Add("GroupBox","x280 y300 H180 W240")

;Access Orientation NOde
MyGui.Add("Text","x290 y300", "Go to Access Orientation Node Menu")
MyGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", OrientationMenu)

;Rescan of Orientation Nodes CAN IDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

MyGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

MyGui.Add("Text","x290 y420", "Choose Orientation")
OrientationAccess := MyGui.AddDropDownList("W160", OrientationArrayID)
OrientationAccess.OnEvent("Change", UseOrientationID)

;----------------------------------------------------------------

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

SolManBTNFocus(*){
    SolManInput.Opt("+Default")
}

SolManBTNUnFocus(*){
    SolManInput.Opt("-Default")
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
    OneWireMasterAltusID.Value := ""
    OneWireMasterToolID := ""

    ;QTComChoice.Choose 0
    QTCOMPort.Choose 0
    BoardChoice.Choose 0
    ;ComChoice.Choose 0
    COMPort.Choose 0
    ChooseSolFWIns.Choose 0
    SolenoidAccess.Choose 0
    SolenoidUse.Choose 0
    SensorType.Choose 0
    SolenoidSensorsDropDownList.Choose 0
    ;TCComChoice.Choose 0
    TCCOMPort.Choose 0
    ChooseTCFWIns.Choose 0
    TCAccess.Choose 0
    TCUsage.Choose 0
    OneWireMasterCOMPort.Choose 0
    RSSCOMPort.Choose 0
    RSSAccess.Choose 0

    WinMove(0,0,,, "ahk_exe tkToolUtility.exe")
    Sleep 200
    WinActivate ("V2.2 TestUtilityGUI For Use With TestUtilityV40")
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
    WinActivate ("V2.2 TestUtilityGUI For Use With TestUtilityV40") 
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

QTManBTNFocus(*){
    QTManInput.Opt("+Default")
}

QTManBTNUnFocus(*){
    QTManInput.Opt("-Default")
}


QTInputValueEnter(*){
    ControlSend QTInput.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
    Sleep 100
    QTInput.Value := ""
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

SolPCANReinitialize(*){
    Keystroke9()
    Sleep 500
}

PCANReinitialize(*){
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

SolenoidSensorTypesStroker(*){
    SolenoidSensorsDropDownList.Delete()
    SolenoidSensorsDropDownList.Add(CompactStrokerDropDownListArray)
}

SolenoidSensorTypes(*){
    SolenoidSensorsDropDownList.Delete()
    SolenoidSensorsDropDownList.Add(TheRestDropDownListArray)
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

SolInputValueEnter(*){
    ControlSend SolInput.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
    Sleep 100
    SolInput.Value := ""
}

SensorIDs(*){
    Hex0xFA()
    Sleep 200
    SelectedSensorIDs := SolenoidSensorsDropDownList.Text
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

        Case "DDP3 'P-Sa' Linear":
            Keystroke1()
            Sleep 100
            Keystroke1()
        Case "DDP3 'P-Sb' Linear":
            Keystroke2()
            Sleep 100
            Keystroke1()
        Case "DDP3 'P-LF' Linear":
            Keystroke3()
            Sleep 100
            Keystroke1()
        Case "DDP500 'P-Comp' Linear":
            Keystroke4()
            Sleep 100
            Keystroke1()
        Case "DDP3 'P-TW' Linear":
            Keystroke5()
            Sleep 100
            Keystroke1()
        Case "AncUpper 'P-Ga' Quad":
            Keystroke6()
            Sleep 100
            Keystroke2()
        Case "AncLower 'P-Gb' Quad":
            Keystroke7()
            Sleep 100
            Keystroke2()

}
}

UpdateSensorValues(*){
    
    SelectedSensors := SolenoidSensorsDropDownList.Text
    switch SelectedSensors {
        case "DDP3 '9a' Linear":
            if (Sensorm.Value != "" && Sensorb.Value != "")
            {
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
            }
            
        case "DDP3 '9b' Linear":
        if (Sensorm.Value != "" && Sensorb.Value != "")
        {
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
        }
       
        case "Comp '10' Linear":
        if (Sensorm.Value != "" && Sensorb.Value != "")
            {
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
        }
        Case "AncUpper '13a' Quad":
        if (SensorCb.Value != "" && SensorCm.Value != "" && SensorBb.Value != "" && SensorBm.Value != "" && SensorAb.Value != "" && SensorAm.Value != "")
        {
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
        }

        Case "AncLower '13b' Quad":
        if (SensorCb.Value != "" && SensorCm.Value != "" && SensorBb.Value != "" && SensorBm.Value != "" && SensorAb.Value != "" && SensorAm.Value != "")
        {
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
        }

        Case "Sensor6 'Not in Use'":
            MsgBox "Not in use for the rest, Choose the other options above for compactstroker"
        Case "Sensor7 'Not in Use'":
            MsgBox "Not in use for the rest, Choose the other options above for compactstroker"

        Case "DDP3 'P-Sa' Linear":
        if (Sensorm.Value != "" && Sensorb.Value != "")
        {
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
        }

        Case "DDP3 'P-Sb' Linear":
        if (Sensorm.Value != "" && Sensorb.Value != "")
        {
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
        }

        Case "DDP3 'P-LF' Linear":
        if (Sensorm.Value != "" && Sensorb.Value != "")
        {
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
        }

        Case "DDP500 'P-Comp' Linear":
        if (Sensorm.Value != "" && Sensorb.Value != "")
        {
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
        }

        Case "DDP3 'P-TW' Linear":
        if (Sensorm.Value != "" && Sensorb.Value != "")
        {
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
        }

        Case "AncUpper 'P-Ga' Quad":
        if (SensorCb.Value != "" && SensorCm.Value != "" && SensorBb.Value != "" && SensorBm.Value != "" && SensorAb.Value != "" && SensorAm.Value != "")
        {
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
        }

        Case "AncLower 'P-Gb' Quad":
        if (SensorCb.Value != "" && SensorCm.Value != "" && SensorBb.Value != "" && SensorBm.Value != "" && SensorAb.Value != "" && SensorAm.Value != "")
        {
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
        }

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


TCManBTNFocus(*){
    TCManInput.Opt("+Default")
}

TCManBTNUnFocus(*){
    TCManInput.Opt("-Default")
}


TCInputValueEnter(*){
    ControlSend TCInput.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
    Sleep 100
    TCInput.Value := ""
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
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke1()
            InsSID()
            Case "Upper TC - 0x32" :
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke2()
            InsSID()
            Case "Lower TC - 0x33" :
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke3()
            InsSID()
            Case "DDR TC SJR - 0x34" :
            ControlSend "{y}",, "tkToolUtility.exe"
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
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke1()
            InsSID()
            Case "Upper TC - 0x32" :
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke2()
            InsSID()
            Case "Lower TC - 0x33" :
            ControlSend "{y}",, "tkToolUtility.exe"
            Hex0x3()
            Sleep 100
            Keystroke3()
            InsSID()
            Case "DDR TC SJR - 0x34" :
            ControlSend "{y}",, "tkToolUtility.exe"
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

OpenFiledialogOneWireMaster(*){
SelectedOneWireMasterFWFile := FileSelect(1,,"Select Firmware","Firmware (*.hex)")
if (SelectedOneWireMasterFWFile != "")
{
    destinationOneWireMasterDir := A_ScriptDir . "\\hexFiles_SWC\\"
    newName := "SWC_leinApp_bl.hex"

    destinationOneWireMasterFile := destinationOneWireMasterDir . newName

    FileCopy(SelectedOneWireMasterFWFile, destinationOneWireMasterFile, 1)

    if (FileExist(destinationOneWireMasterFile))
        {
        
            Sleep 1000
            CheckFWLoopOneWireMaster()

        }

}
}

InstallFWOneWireMaster(*){
    SelectedOneWireMasterCom := OneWireMasterComChoice.Text
    switch SelectedOneWireMasterCom {
        case "PCAN":
        Keystroke4()
        Sleep 100 
        Keystroke1()
        Sleep 100 
        Keystroke3()
        Sleep 100 
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 100
        Hex0x3A()
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"

        ReopenAfterIns()

        case "QPSK/MasterBox":
        Keystroke4()
        Sleep 100
        Keystroke2()
        Sleep 100 
        Keystroke3()
        Sleep 200
        ControlSend  OneWireMasterCOMPort.Text ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100 

        ReopenAfterIns()

        case "OFDM":
            Keystroke4()
    }
}

OneWireMasterBtnFocus(*){
    OneWireMasterIdBtn.Opt("+Default")
}

OneWireMasterBtnUnFocus(*){
    OneWireMasterIdBtn.Opt("-Default")
}

OneWireMasterManBTNFocus(*){
    OneWireMasterManInput.Opt("+Default")
}

OneWireMasterManBTNUnFocus(*){
    OneWireMasterManInput.Opt("-Default")
}


OneWireMasterInputValueEnter(*){
    ControlSend OneWireMasterInput.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
    Sleep 100
    OneWireMasterInput.Value := ""
}




UpdateOneWireMasterIDs(*){

    if (OneWireMasterAltusID.Value != "" && OneWireMasterToolID.Value == ""){
        Hex0x88()
        Sleep 400
        ControlSend  OneWireMasterAltusID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        OneWireMasterAltusID.Value := ""
        Sleep 300
        Hex0x9B()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if OneWireMasterToolID.Value != "" && OneWireMasterAltusID.Value == ""{
        Hex0x8C()
        Sleep 400
        ControlSend  OneWireMasterToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        OneWireMasterToolID.Value := ""
        Sleep 300
        Hex0x9B()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if OneWireMasterAltusID.Value != "" && OneWireMasterToolID.Value != ""{
        Hex0x88()
        Sleep 200
        ControlSend  OneWireMasterAltusID.Value,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}",, "tkToolUtility.exe"
        Sleep 600
        OneWireMasterAltusID.Value := ""
        Sleep 400
        Hex0x8C()
        Sleep 200
        ControlSend  OneWireMasterToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        OneWireMasterToolID.Value := ""
        Sleep 300
        Hex0x9B()
        ControlSend  "{y}", , "tkToolUtility.exe"
    }
    else{
        return
    }
}

OneWireMasterMenu(*){
    Keystroke4()
    Sleep 200
    SelectedOneWireMasterOption := OneWireMasterComChoice.Text
    switch SelectedOneWireMasterOption {
        case "PCAN":
            Keystroke1()
            Sleep 200
            Keystroke1()
        case "QPSK/MasterBox":
            Keystroke2()
            Sleep 200
            Keystroke1()
            ControlSend  OneWireMasterCOMPort.Text ,, "tkToolUtility.exe"
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

UseOneWireMasterID(*){
    Keystroke4()
    Sleep 200
    SelectOneWireMaster := OneWireMasterAccess.Text
    Switch SelectOneWireMaster{
        Case "One Wire Master - 0x3A" :
        Hex0x3A()
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
    }
}




RSSManBTNFocus(*){
    RSSManInput.Opt("+Default")
}

RSSManBTNUnFocus(*){
    RSSManInput.Opt("-Default")
}


RSSInputValueEnter(*){
    ControlSend RSSInput.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
    Sleep 100
    RSSInput.Value := ""
}




OpenFiledialogRSS(*){
    SelectedRSSFWFile := FileSelect(1,,"Select Firmware","Firmware (*.hex)")
    if (SelectedRSSFWFile != "")
    {
        destinationRSSDir := A_ScriptDir . "\\hexFiles_RSS\\"
        newName := "RSS_leinApp_bl.hex"
    
        destinationRSSFile := destinationRSSDir . newName
    
        FileCopy(SelectedRSSFWFile, destinationRSSFile, 1)
    
        if (FileExist(destinationRSSFile))
            {
            
                Sleep 1000
                CheckFWLoopRSS()
    
            }
    
    }
    }
    
    InstallFWRSS(*){
        SelectedRSSCom := RSSComChoice.Text
        switch SelectedRSSCom {
            case "PCAN":
            Keystroke5()
            Sleep 100 
            Keystroke1()
            Sleep 100 
            Keystroke3()
            Sleep 100 
            ChooseRSS := ChooseRSSFWIns.Text
            Switch ChooseRSS{
                Case "":
                ControlSend "{N}",, "tkToolUtility.exe"
                InsSID()
                Case "Upper RSS - 0x1A" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x1A()
                Sleep 100
                InsSID()
                Case "Lower RSS - 0x1B" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x1B()
                Sleep 100
                InsSID()
            }
    
            ReopenAfterIns()
    
            case "QPSK/MasterBox":
            Keystroke5()
            Sleep 100
            Keystroke2()
            Sleep 100 
            Keystroke3()
            Sleep 200
            ControlSend  RSSCOMPort.Text ,, "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
    
            ReopenAfterIns()
    
            case "OFDM":
                Keystroke4()
        }
    }


RSSMenu(*){
    Keystroke5()
    Sleep 200
    SelectedRSSOption := RSSComChoice.Text
    switch SelectedRSSOption {
        case "PCAN":
            Keystroke1()
            Sleep 200
            Keystroke1()
        case "QPSK/MasterBox":
            Keystroke2()
            Sleep 200
            Keystroke1()
            ControlSend  RSSCOMPort.Text ,, "tkToolUtility.exe"
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

UseRSSID(*){
    Keystroke4()
    Sleep 200
    SelectRSS := RSSAccess.Text
    Switch SelectRSS{
        Case "Upper RSS - 0x1A" :
        Hex0x1A()
        Sleep 100
        

        Case "Lower RSS - 0x1B" :
        Hex0x1B()
        Sleep 100
        

    }
}




AnchorBoardManBTNFocus(*){
    AnchorBoardManInput.Opt("+Default")
}

AnchorBoardManBTNUnFocus(*){
    AnchorBoardManInput.Opt("-Default")
}


AnchorBoardInputValueEnter(*){
    ControlSend AnchorBoardInput.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
    Sleep 100
    AnchorBoardInput.Value := ""
}


OpenFiledialogAnchorBoard(*){
    SelectedAnchorBoardFWFile := FileSelect(1,,"Select Firmware","Firmware (*.hex)")
    if (SelectedAnchorBoardFWFile != "")
    {
        destinationAnchorBoardDir := A_ScriptDir . "\\hexFiles_ANC\\"
        newName := "ANC_leinApp_bl.hex"
    
        destinationAnchorBoardFile := destinationAnchorBoardDir . newName
    
        FileCopy(SelectedAnchorBoardFWFile, destinationAnchorBoardFile, 1)
    
        if (FileExist(destinationAnchorBoardFile))
            {
            
                Sleep 1000
                CheckFWLoopAnchorBoard()
    
            }
    
    }
    }
    
    InstallFWAnchorBoard(*){
        SelectedAnchorBoardCom := AnchorBoardComChoice.Text
        switch SelectedAnchorBoardCom {
            case "PCAN":
            Keystroke6()
            Sleep 100 
            Keystroke1()
            Sleep 100 
            Keystroke3()
            Sleep 100 
            ChooseAnchorBoard := ChooseAnchorBoardFWIns.Text
            Switch ChooseAnchorBoard{
                Case "":
                ControlSend "{N}",, "tkToolUtility.exe"
                InsSID()
                Case "0x3C" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x3C()
                Sleep 100
                InsSID()
                Case "0x3D" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x3D()
                Sleep 100
                InsSID()
                Case "0x3E" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x3E()
                Sleep 100
                InsSID()
            }
    
            ReopenAfterIns()
    
            case "QPSK/MasterBox":
            Keystroke6()
            Sleep 100
            Keystroke2()
            Sleep 100 
            Keystroke3()
            Sleep 200
            ControlSend  AnchorBoardCOMPort.Text ,, "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
    
            ReopenAfterIns()
    
            case "OFDM":
                Keystroke4()
        }
    }


AnchorBoardMenu(*){
    Keystroke6()
    Sleep 200
    SelectedAnchorBoardOption := AnchorBoardComChoice.Text
    switch SelectedAnchorBoardOption {
        case "PCAN":
            Keystroke1()
            Sleep 200
            Keystroke1()
        case "QPSK/MasterBox":
            Keystroke2()
            Sleep 200
            Keystroke1()
            ControlSend  AnchorBoardCOMPort.Text ,, "tkToolUtility.exe"
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

UseAnchorBoardID(*){
    Keystroke4()
    Sleep 200
    SelectAnchorBoard := AnchorBoardAccess.Text
    Switch SelectAnchorBoard{
        Case "0x3C" :
        Hex0x3C()
        Sleep 100
        
        Case "0x3D" :
        Hex0x3D()
        Sleep 100

        Case "0x3E" :
        Hex0x3E()
        Sleep 100

    }
}




OrientationManBTNFocus(*){
    OrientationManInput.Opt("+Default")
}

OrientationManBTNUnFocus(*){
    OrientationManInput.Opt("-Default")
}


OrientationInputValueEnter(*){
    ControlSend OrientationInput.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}" ,, "tkToolUtility.exe"
    Sleep 100
    OrientationInput.Value := ""
}


OpenFiledialogOrientation(*){
    SelectedOrientationFWFile := FileSelect(1,,"Select Firmware","Firmware (*.hex)")
    if (SelectedOrientationFWFile != "")
    {
        destinationOrientationDir := A_ScriptDir . "\\hexFiles_ORI\\"
        newName := "ORI_leinApp_bl.hex"
    
        destinationOrientationFile := destinationOrientationDir . newName
    
        FileCopy(SelectedOrientationFWFile, destinationOrientationFile, 1)
    
        if (FileExist(destinationOrientationFile))
            {
            
                Sleep 1000
                CheckFWLoopOrientation()
    
            }
    
    }
    }
    
    InstallFWOrientation(*){
        SelectedOrientationCom := OrientationComChoice.Text
        switch SelectedOrientationCom {
            case "PCAN":
            Keystroke7()
            Sleep 100 
            Keystroke1()
            Sleep 100 
            Keystroke3()
            Sleep 100 
            ChooseOrientation := ChooseOrientationFWIns.Text
            Switch ChooseOrientation{
                Case "":
                ControlSend "{N}",, "tkToolUtility.exe"
                InsSID()
                Case "0x2B" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x2B()
                Sleep 100
                InsSID()
            }
    
            ReopenAfterIns()
    
            case "QPSK/MasterBox":
            Keystroke7()
            Sleep 100
            Keystroke2()
            Sleep 100 
            Keystroke3()
            Sleep 200
            ControlSend  OrientationCOMPort.Text ,, "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 100 
    
            ReopenAfterIns()
    
            case "OFDM":
                Keystroke4()
        }
    }


OrientationMenu(*){
    Keystroke7()
    Sleep 200
    SelectedOrientationOption := OrientationComChoice.Text
    switch SelectedOrientationOption {
        case "PCAN":
            Keystroke1()
            Sleep 200
            Keystroke1()
        case "QPSK/MasterBox":
            Keystroke2()
            Sleep 200
            Keystroke1()
            ControlSend  OrientationCOMPort.Text ,, "tkToolUtility.exe"
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


UseOrientationID(*){
    Keystroke4()
    Sleep 200
    SelectOrientation := OrientationAccess.Text
    Switch SelectOrientation{
        Case "0x2B" :
        Hex0x2B()
        Sleep 100  

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

Hex0x88(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x9B(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{9}",, "tkToolUtility.exe"
    ControlSend "{B}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x3(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{3}",, "tkToolUtility.exe"
}

Hex0x1A(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{1}",, "tkToolUtility.exe"
    ControlSend "{A}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x1B(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{1}",, "tkToolUtility.exe"
    ControlSend "{B}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x2B(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{2}",, "tkToolUtility.exe"
    ControlSend "{B}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}


Hex0x3A(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{3}",, "tkToolUtility.exe"
    ControlSend "{A}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x3C(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{3}",, "tkToolUtility.exe"
    ControlSend "{C}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x3D(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{3}",, "tkToolUtility.exe"
    ControlSend "{D}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x3E(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{3}",, "tkToolUtility.exe"
    ControlSend "{E}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
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

