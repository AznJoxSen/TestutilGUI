Run "tkToolUtility.exe"
Sleep 600
ControlSend  "{Enter}", , "tkToolUtility.exe"
SetWorkingDir(A_ScriptDir)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon (iconPath)

WindowTitle := "V3 TestUtilityGUI For Use With TestUtilityV40"

TUtilGui := Gui(, WindowTitle)

SetDarkWindowFrame(TUtilGui)
TUtilGui.Setfont("s10 cWhite")
TUtilGui.BackColor := "424242"
WinMove(0,0,,, "ahk_exe tkToolUtility.exe")

;
CmdExist(*){
    if WinExist("cmd.exe")
        WinHide "Ahk_exe cmd.exe"
    SetTimer CmdExist, 0

}

;Checking available COM Ports
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


;Create tabs
Tab := TUtilGui.Add("Tab3","-Wrap", ["Q-Telemetry", "Solenoid", "TC Node" , "1-Wire", "RSS", "Anchor Board", "Orientation"])
Tab.Font := "Bold"


;For Q-Telemetry Tab
Tab.UseTab("Q-telemetry")

;Restart Testutil button
TUtilGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W200 H180")

;Choose Modem Type
TUtilGui.Add("Text","x26 y39", "Choose Modem Type")
QTComChoice := TUtilGui.AddDropDownList("W80", ["QPSK", "OFDM"])
QTComChoice.Choose("QPSK")

;Drop Down for Com Ports
TUtilGui.Add("Text",, "Select COM Port Number")
QTCOMPort := TUtilGui.AddDropDownList("W75", Words)

;Refresh COM Ports
RefreshQT := TUtilGui.Add("Button","x121 y114", "Refresh")
RefreshQT.OnEvent("Click", RefreshBtn)

;Option to input manually to testutil
TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
QTInput := TUtilGui.Add("Edit", "")
QTInput.SetFont("cBlack")

QTInput.OnEvent("Focus", QTManBTNFocus)
QTInput.OnEvent("LoseFocus", QTManBTNUnFocus)

QTManInput := TUtilGui.Add("Button","x180 y620","Submit")
QTManInput.OnEvent("Click", QTInputValueEnter)

;Choose Board
TUtilGui.Add("Text","x26 y147", "Choose Board Type")
BoardChoice := TUtilGui.AddDropDownList("W150", ["Master Controller", "DCDC Converter", "Relay Board"])
BoardChoice.OnEvent("Change", BoardSelect)

TUtilGui.Add("GroupBox","x238 y35 W210 H250")

;For Master Controller
TUtilGui.Add("Text","x250 y39", "For Master Controller")
TUtilGui.Add("Text",,"Update AltusID/Board ID")
MCID := TUtilGui.Add("Edit")
MCID.SetFont("cBlack")

TUtilGui.Add("Text",,"Update Q-Telemetry Module ID")
QTID := TUtilGui.Add("Edit")
QTID.SetFont("cBlack")

MCID.OnEvent("Focus", McQtBtnFocus)
MCID.OnEvent("LoseFocus", McQtBtnUnFocus)

QTID.OnEvent("Focus", McQtBtnFocus)
QTID.OnEvent("LoseFocus", McQtBtnUnFocus)

MCBtn := TUtilGui.Add("Button","", "Update")
MCBtn.OnEvent("Click", EnterToSaveQT)

TUtilGui.Add("Text",, "Check Current Settings")
TUtilGui.Add("Button",, "Check").OnEvent("Click", QTCheck)

TUtilGui.Add("GroupBox","x486 y35 W190 H370")

;For DCDC
TUtilGui.Add("Text","x500 y39", "For DCDC Converter")
TUtilGui.Add("Text",, "Change to Raised Startup")
TUtilGui.Add("Button",, "Raised Startup").OnEvent("Click", RaisedStartup)

TUtilGui.Add("Text",, "Change to Default Startup")
TUtilGui.Add("Button",, "Default Startup").OnEvent("Click", DefaultStartup)

TUtilGui.Add("Text",, "Update AltusID/Board ID")
DCDCID := TUtilGui.Add("Edit")
DCDCID.SetFont("cBlack")
DCDCBtn := TUtilGui.Add("Button",, "Update")
DCDCBtn.OnEvent("Click", EnterToSaveQT)

DCDCID.OnEvent("Focus", DCDCBtnFocus)
DCDCID.OnEvent("LoseFocus", DCDCBtnUnFocus)

TUtilGui.Add("Text",, "Check Current Settings")
TUtilGui.Add("Button",, "Check").OnEvent("Click", QTCheck)

TUtilGui.Add("Text",, "Save Changes")
DCDCSaveButton := TUtilGui.Add("Button",, "Save")
DCDCSaveButton.OnEvent("Click", DCDCSave)

TUtilGui.Add("GroupBox","x736 y35 W190 H195")

;For Relay Board
TUtilGui.Add("Text", "x750 y39", "For Relay Board")
TUtilGui.Add("Text",,"Update AltusID/Board ID")
RBID := TUtilGui.Add("Edit")
RBID.SetFont("cBlack")
RBBtn := TUtilGui.Add("Button",, "Update")
RBBtn.OnEvent("Click", EnterToSaveQT)

RBID.OnEvent("Focus", RBBtnFocus)
RBID.OnEvent("LoseFocus", RBBtnUnFocus)

TUtilGui.Add("Text",, "Check Current Settings")
TUtilGui.Add("Button",, "Check").OnEvent("Click", QTCheck)


;----------------------------------------------------------------

;For Solenoid Tab
Tab.UseTab("Solenoid")

TUtilGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for solenoid
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
ComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
;ComChoice.OnEvent("Change", SendKeystrokeFromListbox)
ComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
COMPort := TUtilGui.AddDropDownList("W75", Words)


Refresh := TUtilGui.Add("Button","x121 y145", "Refresh")
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


TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
SolInput := TUtilGui.Add("Edit", "")
SolInput.SetFont("cBlack")

SolInput.OnEvent("Focus", SolManBTNFocus)
SolInput.OnEvent("LoseFocus", SolManBTNUnFocus)

SolManInput := TUtilGui.Add("Button","x180 y620","Submit")
SolManInput.OnEvent("Click", SolInputValueEnter)


TUtilGui.Add("GroupBox", "x280 y35 H235 W300")

TUtilGui.Add("Text","x290 y39", "FW Selected for Installing")
SolFW := TUtilGui.Add("Edit", "ReadOnly")
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
TUtilGui.Add("Text",, "Select Firmware Version")
TUtilGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogSolenoid)

TUtilGui.Add("Text",, "Choose a Solenoid if more than one connected")
ChooseSolFWIns := TUtilGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])


;Install FW to Solenoid
TUtilGui.Add("Text",, "Install Firmware to Solenoid")

TUtilGui.Add("Button",, "Install").OnEvent("Click", InstallSolenoidEz)

TUtilGui.Add("GroupBox","x280 y300 H180 W230")

;Access solenoid board
TUtilGui.Add("Text","x290 y300", "Go to Access Solenoid Menu")
TUtilGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", AccessSolenoidEz)

;Rescan of Solenoid CANIDs
TUtilGui.Add("Text","", "Rescan Nodes If Necessecary")
TUtilGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

TUtilGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", SolPCANReinitialize)

;Choose what solenoid to access
TUtilGui.Add("Text","x290 y420", "Choose Solenoid Board")
SolenoidAccess := TUtilGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidAccess.OnEvent("Change", SolenoidIDs)
;CBS_DISABLENOSCROLL

TUtilGui.Add("GroupBox","x590 y35 W190 H236")

;Changing Solenoid Usage
TUtilGui.Add("Text","x600 y39", "Change Solenoid Usage")
SolenoidUse := TUtilGui.AddDropDownList("W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidUse.OnEvent("Change", SolenoidUsage)

;Changing sensor types
TUtilGui.Add("Text","" , "Change Sensor Type")
SensorType := TUtilGui.AddDropDownList("W170",["HallEffect", "QuadEncoder", "Mech", "Unknown"])
SensorType.OnEvent("Change", SensorTypeChange)



TUtilGui.Add("Text","" , "Check Current Settings")
TUtilGui.Add("Button",,"Check").OnEvent("Click", CheckSet)

TUtilGui.Add("Text","" , "Check Calibration Table")
TUtilGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

TUtilGui.Add("GroupBox","x590 y355 W170 H102")

;Test Solenoid
TUtilGui.Add("Text","x600 y360" , "For EL.LAB Use Only!")
TUtilGui.Add("Text","" ,"Test Solenoid Switching")
TUtilGui.Add("Button",, "Test Switching").OnEvent("Click", SolenoidSwitching)

TUtilGui.Add("GroupBox","x790 y35 W325 H525")

;Text for sensor values
TUtilGui.Add("Text","x800 y172", "SensorLinear m")
TUtilGui.Add("Text",, "SensorLinear b")
TUtilGui.Add("Text",, "SensorQuadtratic Cb")
TUtilGui.Add("Text",, "SensorQuadtratic Cm")
TUtilGui.Add("Text",, "SensorQuadtratic Bb")
TUtilGui.Add("Text",, "SensorQuadtratic Bm")
TUtilGui.Add("Text",, "SensorQuadtratic Ab")
TUtilGui.Add("Text",, "SensorQuadtratic Am")
TUtilGui.Add("Text",, "Update Sensor Values")

;Text for IDs
TUtilGui.Add("Text",, "Update Altus/Board ID")
TUtilGui.Add("Text",, "Update Tool ID")


TUtilGui.Add("Text","x800 y39" , "Select Approiate Application")
SolRadioBtn1 := TUtilGui.Add("Radio", "x800 y60 Checked", "For Everything Else Sensors")
SolRadioBtn2 := TUtilGui.Add("Radio", "x800 y80", "For CompactStroker Sensors")

TheRestDropDownListArray := ["DDP3 '9a' Linear", "DDP3 '9b' Linear", "Comp '10' Linear", "AncUpper '13a' Quad", "AncLower '13b' Quad", "Sensor6 'Not in Use'", "Sensor7 'Not in Use'"]

CompactStrokerDropDownListArray := ["DDP3 'P-Sa' Linear", "DDP3 'P-Sb' Linear", "DDP3 'P-LF' Linear", "DDP500 'P-Comp' Linear", "DDP3 'P-TW' Linear", "AncUpper 'P-Ga' Quad", "AncLower 'P-Gb' Quad"]


;Changing sensor values
TUtilGui.Add("Text","x800 y110" , "Choose Sensor To Update Values")
SolenoidSensorsDropDownList := TUtilGui.AddDropDownList("W230", TheRestDropDownListArray)
SolenoidSensorsDropDownList.OnEvent("Change", SensorIDs)
;Input edit box for sensor values

SolRadioBtn1.OnEvent("Click", SolenoidSensorTypes)
SolRadioBtn2.OnEvent("Click", SolenoidSensorTypesStroker)


Sensorm := TUtilGui.Add("Edit","x950 y167")
Sensorb := TUtilGui.Add("Edit")
SensorCb := TUtilGui.Add("Edit")
SensorCm := TUtilGui.Add("Edit")
SensorBb := TUtilGui.Add("Edit")
SensorBm := TUtilGui.Add("Edit")
SensorAb := TUtilGui.Add("Edit")
SensorAm := TUtilGui.Add("Edit")
SensorValuesBTN := TUtilGui.Add("Button",, "Update Values")
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
AltusID := TUtilGui.Add("Edit")
ToolID := TUtilGui.Add("Edit")
SolUpdateIDBtn := TUtilGui.Add("Button",, "Update IDs")
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

TUtilGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for TC Node
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
TCComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])
TCComChoice.Choose("PCAN")

TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
TCCOMPort := TUtilGui.AddDropDownList("W75", Words)

RefreshTC := TUtilGui.Add("Button","x121 y145", "Refresh")
RefreshTC.OnEvent("Click", RefreshBtn)


TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
TCInput := TUtilGui.Add("Edit", "")
TCInput.SetFont("cBlack")



TCInput.OnEvent("Focus", TCManBTNFocus)
TCInput.OnEvent("LoseFocus", TCManBTNUnFocus)

TCManInput := TUtilGui.Add("Button","x180 y620","Submit")
TCManInput.OnEvent("Click", TCInputValueEnter)


TUtilGui.Add("GroupBox", "x280 y35 H235 W300")

TUtilGui.Add("Text","x290 y39", "FW Selected for Installing")
TCFW := TUtilGui.Add("Edit", "ReadOnly")
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
TUtilGui.Add("Text","", "Select Firmware Version")
TUtilGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogTC)

TUtilGui.Add("Text",, "Choose a TC Node if more than one connected")
ChooseTCFWIns := TUtilGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])

;Install FW to TC Node
TUtilGui.Add("Text",, "Install Firmware to TC Node")

TUtilGui.Add("Button",, "Install").OnEvent("Click", InstallFWTC)

TUtilGui.Add("GroupBox","x280 y300 H180 W230")

;Access TC NOde
TUtilGui.Add("Text","x290 y300", "Go to Access TC Node Menu")
TUtilGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", TCMenu)

;Rescan of TC Nodes CAN IDs
TUtilGui.Add("Text","", "Rescan Nodes If Necessecary")
TUtilGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

TUtilGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

TUtilGui.Add("Text","x290 y420", "Choose TC Node")
TCAccess := TUtilGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCAccess.OnEvent("Change", UseTCID)

TUtilGui.Add("GroupBox","x590 y35 W190 H125")

TUtilGui.Add("Text","x600 y39", "Change TC Node Usage")
TCUsage := TUtilGui.AddDropDownList("W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCUsage.OnEvent("Change", ChangeTCID)

TUtilGui.Add("Text","" , "Check Current Settings")
TUtilGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

TUtilGui.Add("GroupBox","x790 y35 W325 H130")

;Text for IDs
TUtilGui.Add("Text","x800 y60", "Update Altus/Board ID")
TUtilGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
TUtilGui.Add("Text","x950 y39","Input IDs")
TCAltusID := TUtilGui.Add("Edit","x950 y60")
TCToolID := TUtilGui.Add("Edit")

TCAltusID.SetFont("cBlack")
TCToolID.SetFont("cBlack")

TCTCIdBtn := TUtilGui.Add("Button",, "Update IDs")
TCTCIdBtn.OnEvent("Click", UpdateTCIDs)

TCAltusID.OnEvent("Focus", TCBtnFocus)
TCAltusID.OnEvent("LoseFocus", TCBtnUnFocus)

TCToolID.OnEvent("Focus", TCBtnFocus)
TCToolID.OnEvent("LoseFocus", TCBtnUnFocus)


;----------------------------------------------------------------

;For 1 Wire Master/Slave
Tab.UseTab("1-Wire")
TUtilGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for 1-wire
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
OneWireMasterComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])
OneWireMasterComChoice.Choose("PCAN")

TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
OneWireMasterCOMPort := TUtilGui.AddDropDownList("W75", Words)
;TCCOMPort.SetFont("cBlack")
;TUtilGui.Add("UpDown") 

RefreshOneWire := TUtilGui.Add("Button","x121 y145", "Refresh")
RefreshOneWire.OnEvent("Click", RefreshBtn)


TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
OneWireMasterInput := TUtilGui.Add("Edit", "")
OneWireMasterInput.SetFont("cBlack")

OneWireMasterInput.OnEvent("Focus", OneWireMasterManBTNFocus)
OneWireMasterInput.OnEvent("LoseFocus", OneWireMasterManBTNUnFocus)

OneWireMasterManInput := TUtilGui.Add("Button","x180 y620","Submit")
OneWireMasterManInput.OnEvent("Click", OneWireMasterInputValueEnter)



TUtilGui.Add("GroupBox", "x280 y35 H180 W260")

TUtilGui.Add("Text","x290 y39", "FW Selected for Installing 1-Wire Master")
OneWireMasterFW := TUtilGui.Add("Edit", "ReadOnly")
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
TUtilGui.Add("Text","", "Select Firmware Version")
TUtilGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogOneWireMaster)

;Install FW to One Wire Master
TUtilGui.Add("Text",, "Install Firmware to One Wire Master")

TUtilGui.Add("Button",, "Install").OnEvent("Click", InstallFWOneWireMaster)

TUtilGui.Add("GroupBox","x280 y300 H180 W240")

;Access One Wire Master NOde
TUtilGui.Add("Text","x290 y300", "Go to Access One Wire Master Menu")
TUtilGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", OneWireMasterMenu)

;Rescan of One Wire Master Nodes CAN IDs
TUtilGui.Add("Text","", "Rescan Nodes If Necessecary")
TUtilGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

TUtilGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

TUtilGui.Add("Text","x290 y420", "Choose One Wire Master")
OneWireMasterAccess := TUtilGui.AddDropDownList("W170", ["One Wire Master - 0x3A"])
OneWireMasterAccess.OnEvent("Change", UseOneWireMasterID)


TUtilGui.Add("GroupBox","x560 y35 W325 H130")

;Text for IDs
TUtilGui.Add("Text","x570 y60", "Update Altus/Board ID")
TUtilGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
TUtilGui.Add("Text","x720 y39","Input One Wire Master IDs")
OneWireMasterAltusID := TUtilGui.Add("Edit","x720 y60")
OneWireMasterToolID := TUtilGui.Add("Edit")

OneWireMasterAltusID.SetFont("cBlack")
OneWireMasterToolID.SetFont("cBlack")

OneWireMasterIdBtn := TUtilGui.Add("Button",, "Update IDs")
OneWireMasterIdBtn.OnEvent("Click", UpdateOneWireMasterIDs)

OneWireMasterAltusID.OnEvent("Focus", OneWireMasterBtnFocus)
OneWireMasterAltusID.OnEvent("LoseFocus", OneWireMasterBtnUnFocus)

OneWireMasterToolID.OnEvent("Focus", OneWireMasterBtnFocus)
OneWireMasterToolID.OnEvent("LoseFocus", OneWireMasterBtnUnFocus)


;----------------------------------------------------------------

;For RSS
Tab.UseTab("RSS")
TUtilGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for RSS
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
RSSComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
;ComChoice.OnEvent("Change", SendKeystrokeFromListbox)
RSSComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
RSSCOMPort := TUtilGui.AddDropDownList("W75", Words)


RefreshRSS := TUtilGui.Add("Button","x121 y145", "Refresh")
RefreshRSS.OnEvent("Click", RefreshBtn)

TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
RSSInput := TUtilGui.Add("Edit", "")
RSSInput.SetFont("cBlack")

RSSInput.OnEvent("Focus", RSSManBTNFocus)
RSSInput.OnEvent("LoseFocus", RSSManBTNUnFocus)

RSSManInput := TUtilGui.Add("Button","x180 y620","Submit")
RSSManInput.OnEvent("Click", RSSInputValueEnter)


TUtilGui.Add("GroupBox", "x280 y35 H235 W310")

TUtilGui.Add("Text","x290 y39", "FW Selected for Installing")
RSSFW := TUtilGui.Add("Edit", "ReadOnly")
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
TUtilGui.Add("Text","", "Select Firmware Version")
TUtilGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogRSS)

TUtilGui.Add("Text",, "Choose an RSS Node if more than one connected")
ChooseRSSFWIns := TUtilGui.AddDropDownList("W160", ["Upper RSS - 0x1A","Lower RSS - 0x1B"])

;Install FW to RSS Node
TUtilGui.Add("Text",, "Install Firmware to RSS Node")

TUtilGui.Add("Button",, "Install").OnEvent("Click", InstallFWRSS)


TUtilGui.Add("GroupBox","x280 y300 H180 W230")

;Access RSS NOde
TUtilGui.Add("Text","x290 y300", "Go to Access RSS Node Menu")
TUtilGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", RSSMenu)

;Rescan of RSS Nodes CAN IDs
TUtilGui.Add("Text","", "Rescan Nodes If Necessecary")
TUtilGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

TUtilGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

TUtilGui.Add("Text","x290 y420", "Choose RSS")
RSSAccess := TUtilGui.AddDropDownList("W160", ["Upper RSS - 0x1A","Lower RSS - 0x1B"])
RSSAccess.OnEvent("Change", UseRSSID)


TUtilGui.Add("GroupBox","x600 y35 W190 H125")

TUtilGui.Add("Text","x610 y39", "Change RSS Node Usage")
RSSUsage := TUtilGui.AddDropDownList("W160",["Upper RSS - 0x1A","Lower RSS - 0x1B"])
RSSUsage.OnEvent("Change", ChangeRSSID)

TUtilGui.Add("Text","" , "Check Current Settings")
TUtilGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

TUtilGui.Add("GroupBox","x800 y35 W325 H130")

;Text for IDs
TUtilGui.Add("Text","x810 y60", "Update Altus/Board ID")
TUtilGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
TUtilGui.Add("Text","x960 y39","Input IDs")
RSSAltusID := TUtilGui.Add("Edit","x960 y60")
RSSToolID := TUtilGui.Add("Edit")

RSSAltusID.SetFont("cBlack")
RSSToolID.SetFont("cBlack")

RSSIdBtn := TUtilGui.Add("Button",, "Update IDs")
RSSIdBtn.OnEvent("Click", UpdateRSSIDs)

RSSAltusID.OnEvent("Focus", RSSBtnFocus)
RSSAltusID.OnEvent("LoseFocus", RSSBtnUnFocus)

RSSToolID.OnEvent("Focus", RSSBtnFocus)
RSSToolID.OnEvent("LoseFocus", RSSBtnUnFocus)


;----------------------------------------------------------------

;For Anchor Board
Tab.UseTab("Anchor Board")
TUtilGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for Anchor Board
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
AnchorBoardComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
AnchorBoardComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
AnchorBoardCOMPort := TUtilGui.AddDropDownList("W75", Words)


RefreshAnchorBoard := TUtilGui.Add("Button","x121 y145", "Refresh")
RefreshAnchorBoard.OnEvent("Click", RefreshBtn)



TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
AnchorBoardInput := TUtilGui.Add("Edit", "")
AnchorBoardInput.SetFont("cBlack")

AnchorBoardInput.OnEvent("Focus", AnchorBoardManBTNFocus)
AnchorBoardInput.OnEvent("LoseFocus", AnchorBoardManBTNUnFocus)

AnchorBoardManInput := TUtilGui.Add("Button","x180 y620","Submit")
AnchorBoardManInput.OnEvent("Click", AnchorBoardInputValueEnter)


TUtilGui.Add("GroupBox", "x280 y35 H235 W370")

TUtilGui.Add("Text","x290 y39", "FW Selected for Installing")
AnchorBoardFW := TUtilGui.Add("Edit", "ReadOnly")
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

AnchorBoardArrayID := ["sStrV2 - 0x3C", "Puncher - 0x3D", "HVCO - 0x3E"]


;Browse for FW for Anchor Board Node
TUtilGui.Add("Text","", "Select Firmware Version")
TUtilGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogAnchorBoard)

TUtilGui.Add("Text",, "Choose an Anchor Board Node if more than one connected")
ChooseAnchorBoardFWIns := TUtilGui.AddDropDownList("W160", AnchorBoardArrayID)

;Install FW to Anchor Board Node
TUtilGui.Add("Text",, "Install Firmware to Anchor Board Node")

TUtilGui.Add("Button",, "Install").OnEvent("Click", InstallFWAnchorBoard)


TUtilGui.Add("GroupBox","x280 y300 H180 W260")

;Access Anchor Board NOde
TUtilGui.Add("Text","x290 y300", "Go to Access Anchor Board Node Menu")
TUtilGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", AnchorBoardMenu)

;Rescan of Anchor Board Nodes CAN IDs
TUtilGui.Add("Text","", "Rescan Nodes If Necessecary")
TUtilGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

TUtilGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

TUtilGui.Add("Text","x290 y420", "Choose Anchor Board")
AnchorBoardAccess := TUtilGui.AddDropDownList("W160", AnchorBoardArrayID)
AnchorBoardAccess.OnEvent("Change", UseAnchorBoardID)


TUtilGui.Add("GroupBox","x660 y35 W200 H125")

TUtilGui.Add("Text","x670 y39", "Change Anchor Board Usage")
AnchorBoardUsage := TUtilGui.AddDropDownList("W160", AnchorBoardArrayID)
AnchorBoardUsage.OnEvent("Change", ChangeAnchorBoardID)

TUtilGui.Add("Text","" , "Check Current Settings")
TUtilGui.Add("Button",,"Check").OnEvent("Click", CheckCal)

TUtilGui.Add("GroupBox","x870 y35 W325 H130")

;Text for IDs
TUtilGui.Add("Text","x880 y60", "Update Altus/Board ID")
TUtilGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
TUtilGui.Add("Text","x1030 y39","Input IDs")
AnchorBoardAltusID := TUtilGui.Add("Edit","x1030 y60")
AnchorBoardToolID := TUtilGui.Add("Edit")

AnchorBoardAltusID.SetFont("cBlack")
AnchorBoardToolID.SetFont("cBlack")

AnchorBoardIdBtn := TUtilGui.Add("Button",, "Update IDs")
AnchorBoardIdBtn.OnEvent("Click", UpdateAnchorBoardIDs)

AnchorBoardAltusID.OnEvent("Focus", AnchorBoardBtnFocus)
AnchorBoardAltusID.OnEvent("LoseFocus", AnchorBoardBtnUnFocus)

AnchorBoardToolID.OnEvent("Focus", AnchorBoardBtnFocus)
AnchorBoardToolID.OnEvent("LoseFocus", AnchorBoardBtnUnFocus)


;----------------------------------------------------------------

;For Orientation
Tab.UseTab("Orientation")
TUtilGui.Add("Button","x1000 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for Orientation
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
OrientationComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
OrientationComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
OrientationCOMPort := TUtilGui.AddDropDownList("W75", Words)


RefreshOrientation := TUtilGui.Add("Button","x121 y145", "Refresh")
RefreshOrientation.OnEvent("Click", RefreshBtn)



TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
OrientationInput := TUtilGui.Add("Edit", "")
OrientationInput.SetFont("cBlack")

OrientationInput.OnEvent("Focus", OrientationManBTNFocus)
OrientationInput.OnEvent("LoseFocus", OrientationManBTNUnFocus)

OrientationManInput := TUtilGui.Add("Button","x180 y620","Submit")
OrientationManInput.OnEvent("Click", OrientationInputValueEnter)


TUtilGui.Add("GroupBox", "x280 y35 H235 W350")

TUtilGui.Add("Text","x290 y39", "FW Selected for Installing")
OrientationFW := TUtilGui.Add("Edit", "ReadOnly")
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
TUtilGui.Add("Text","", "Select Firmware Version")
TUtilGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogOrientation)

TUtilGui.Add("Text",, "Choose an Orientation Node if more than one connected")
ChooseOrientationFWIns := TUtilGui.AddDropDownList("W160", OrientationArrayID)

;Install FW to Orientation Node
TUtilGui.Add("Text",, "Install Firmware to Orientation Node")

TUtilGui.Add("Button",, "Install").OnEvent("Click", InstallFWOrientation)


TUtilGui.Add("GroupBox","x280 y300 H180 W240")

;Access Orientation NOde
TUtilGui.Add("Text","x290 y300", "Go to Access Orientation Node Menu")
TUtilGui.Add("Button", "" ,"Go To Menu").OnEvent("Click", OrientationMenu)

;Rescan of Orientation Nodes CAN IDs
TUtilGui.Add("Text","", "Rescan Nodes If Necessecary")
TUtilGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

TUtilGui.Add("Button","x370 y381", "Re-Initialize PCAN").OnEvent("Click", PCANReinitialize)

TUtilGui.Add("Text","x290 y420", "Choose Orientation")
OrientationAccess := TUtilGui.AddDropDownList("W160", OrientationArrayID)
OrientationAccess.OnEvent("Change", UseOrientationID)


TUtilGui.Add("GroupBox","x640 y35 W325 H130")

;Text for IDs
TUtilGui.Add("Text","x650 y60", "Update Altus/Board ID")
TUtilGui.Add("Text",, "Update Tool ID")

;Input edit box for IDs
TUtilGui.Add("Text","x800 y39","Input Orientation IDs")
OrientationAltusID := TUtilGui.Add("Edit","x800 y60")
OrientationToolID := TUtilGui.Add("Edit")

OrientationAltusID.SetFont("cBlack")
OrientationToolID.SetFont("cBlack")

OrientationIdBtn := TUtilGui.Add("Button",, "Update IDs")
OrientationIdBtn.OnEvent("Click", UpdateOrientationIDs)

OrientationAltusID.OnEvent("Focus", OrientationBtnFocus)
OrientationAltusID.OnEvent("LoseFocus", OrientationBtnUnFocus)

OrientationToolID.OnEvent("Focus", OrientationBtnFocus)
OrientationToolID.OnEvent("LoseFocus", OrientationBtnUnFocus)


;----------------------------------------------------------------

;Disable Wheel scrolling

#HotIf WinActive(TUtilGui)
WheelUp::return

WheelDown::return

;Close Both windows
SetTimer CheckProgram, 500

GuiClosed := TUtilGui.OnEvent("Close", CloseGui)

TUtilGui.Show()

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
    WinActivate ("4")
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
    WinActivate ("4") 
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


ChangeRSSID(*){
    Hex0x81()
    Sleep 200
    RSSChange := RSSUsage.Text
    Switch RSSChange{
        Case "Upper RSS - 0x1A" :
        Hex0x1A()
        Sleep 100
        Hex0x87()
        ControlSend "{1}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"

        Case "Lower RSS - 0x1B" :
        Hex0x1B()
        Sleep 100
        Hex0x87()
        ControlSend "{2}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"

    }
    Sleep 100
    Hex0xEB()
}

RSSBtnFocus(*){
    RSSIdBtn.Opt("+Default")
}

RSSBtnUnFocus(*){
    RSSIdBtn.Opt("-Default")
}

UpdateRSSIDs(*){

    if (RSSAltusID.Value != "" && RSSToolID.Value == ""){
        Hex0x88()
        Sleep 400
        ControlSend  RSSAltusID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        RSSAltusID.Value := ""
        Sleep 300
        Hex0xEB()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if RSSToolID.Value != "" && RSSAltusID.Value == ""{
        Hex0x8A()
        Sleep 400
        ControlSend  RSSToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        RSSToolID.Value := ""
        Sleep 300
        Hex0xEB()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if RSSAltusID.Value != "" && RSSToolID.Value != ""{
        Hex0x88()
        Sleep 200
        ControlSend  RSSAltusID.Value,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}",, "tkToolUtility.exe"
        Sleep 600
        RSSAltusID.Value := ""
        Sleep 400
        Hex0x8A()
        Sleep 200
        ControlSend  RSSToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        RSSToolID.Value := ""
        Sleep 300
        Hex0xEB()
        ControlSend  "{y}", , "tkToolUtility.exe"
    }
    else{
        return
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
                Case "sStrV2 - 0x3C" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x3C()
                Sleep 100
                InsSID()
                Case "Puncher - 0x3D" :
                ControlSend "{y}",, "tkToolUtility.exe"
                Hex0x3D()
                Sleep 100
                InsSID()
                Case "HVCO - 0x3E" :
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
        Case "sStrV2 - 0x3C" :
        Hex0x3C()
        Sleep 100
        
        Case "Puncher - 0x3D" :
        Hex0x3D()
        Sleep 100

        Case "HVCO - 0x3E" :
        Hex0x3E()
        Sleep 100

    }
}


ChangeAnchorBoardID(*){
    Hex0xFD()
    Sleep 200
    AnchorBoardChange := AnchorBoardUsage.Text
    Switch AnchorBoardChange{
        Case "sStrV2 - 0x3C" :
        ControlSend "{1}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        ControlSend  "{y}", , "tkToolUtility.exe"

        Case "Puncher - 0x3D" :
        ControlSend "{2}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        ControlSend  "{y}", , "tkToolUtility.exe"

        Case "HVCO - 0x3E" :
        ControlSend "{4}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        ControlSend  "{y}", , "tkToolUtility.exe"
    }

    Hex0xF6()
    ControlSend  "{y}", , "tkToolUtility.exe"
}

AnchorBoardBtnFocus(*){
    AnchorBoardIdBtn.Opt("+Default")
}

AnchorBoardBtnUnFocus(*){
    AnchorBoardIdBtn.Opt("-Default")
}

UpdateAnchorBoardIDs(*){

    if (AnchorBoardAltusID.Value != "" && AnchorBoardToolID.Value == ""){
        Hex0x88()
        Sleep 400
        ControlSend  AnchorBoardAltusID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        AnchorBoardAltusID.Value := ""
        Sleep 300
        Hex0xF6()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if AnchorBoardToolID.Value != "" && AnchorBoardAltusID.Value == ""{
        Hex0x8A()
        Sleep 400
        ControlSend  AnchorBoardToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        AnchorBoardToolID.Value := ""
        Sleep 300
        Hex0xF6()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if AnchorBoardAltusID.Value != "" && AnchorBoardToolID.Value != ""{
        Hex0x88()
        Sleep 200
        ControlSend  AnchorBoardAltusID.Value,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}",, "tkToolUtility.exe"
        Sleep 600
        AnchorBoardAltusID.Value := ""
        Sleep 400
        Hex0x8A()
        Sleep 200
        ControlSend  AnchorBoardToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        AnchorBoardToolID.Value := ""
        Sleep 300
        Hex0xF6()
        ControlSend  "{y}", , "tkToolUtility.exe"
    }
    else{
        return
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


OrientationBtnFocus(*){
    OrientationIdBtn.Opt("+Default")
}

OrientationBtnUnFocus(*){
    OrientationIdBtn.Opt("-Default")
}

UpdateOrientationIDs(*){

    if (OrientationAltusID.Value != "" && OrientationToolID.Value == ""){
        Hex0x88()
        Sleep 400
        ControlSend  OrientationAltusID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        OrientationAltusID.Value := ""
        Sleep 300
        Hex0xF6()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if OrientationToolID.Value != "" && OrientationAltusID.Value == ""{
        Hex0x8A()
        Sleep 400
        ControlSend  OrientationToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        OrientationToolID.Value := ""
        Sleep 300
        Hex0xF6()
        ControlSend  "{y}", , "tkToolUtility.exe"
}
    else if OrientationAltusID.Value != "" && OrientationToolID.Value != ""{
        Hex0x88()
        Sleep 200
        ControlSend  OrientationAltusID.Value,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}",, "tkToolUtility.exe"
        Sleep 600
        OrientationAltusID.Value := ""
        Sleep 400
        Hex0x8A()
        Sleep 200
        ControlSend  OrientationToolID.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 400
        OrientationToolID.Value := ""
        Sleep 300
        Hex0xF6()
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

Hex0xF4(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{4}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xF6(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{6}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xF7(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{7}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}


Hex0xFA(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{A}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0xFD(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{F}",, "tkToolUtility.exe"
    ControlSend "{D}",, "tkToolUtility.exe"
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

Hex0xEB(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{E}",, "tkToolUtility.exe"
    ControlSend "{B}",, "tkToolUtility.exe"
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

Hex0x81(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend "{1}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Hex0x87(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{8}",, "tkToolUtility.exe"
    ControlSend "{7}",, "tkToolUtility.exe"
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

