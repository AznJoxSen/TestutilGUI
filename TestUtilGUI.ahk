#Requires AutoHotkey v2.0

Run "tkToolUtility.exe"
Sleep 1000
ControlSend  "{Enter}", , "tkToolUtility.exe"
SetWorkingDir(A_ScriptDir)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon (iconPath)

WindowTitle := "V4 TestUtilityGUI For Use With TestUtilityV40"

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
TUtilGui.Add("Button","x1100 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

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

;For Master Controller

MCGroupBox := TUtilGui.Add("GroupBox","Hidden1 x238 y35 W210 H250")

MCText1 := TUtilGui.Add("Text","Hidden1 x250 y39", "For Master Controller")
MCText2 := TUtilGui.Add("Text","Hidden1","Update AltusID/Board ID")
MCID := TUtilGui.Add("Edit", "Hidden1")
MCID.SetFont("cBlack")

MCText3 := TUtilGui.Add("Text","Hidden1","Update Q-Telemetry Module ID")
QTID := TUtilGui.Add("Edit","Hidden1",)
QTID.SetFont("cBlack")


MCID.OnEvent("Focus", McQtBtnFocus)
MCID.OnEvent("LoseFocus", McQtBtnUnFocus)

QTID.OnEvent("Focus", McQtBtnFocus)
QTID.OnEvent("LoseFocus", McQtBtnUnFocus)

MCBtn := TUtilGui.Add("Button","Hidden1", "Update")
MCBtn.OnEvent("Click", EnterToSaveQT)

MCText4 := TUtilGui.Add("Text","Hidden1", "Check Current Settings")
MCButton1 := TUtilGui.Add("Button","Hidden1", "Check")
MCButton1.OnEvent("Click", QTCheck)


;For DCDC
DCDCGroupBox := TUtilGui.Add("GroupBox","Hidden1 x486 y35 W190 H370")


DCDCText1 := TUtilGui.Add("Text","Hidden1 x500 y39", "For DCDC Converter")
DCDCText2 := TUtilGui.Add("Text","Hidden1", "Change to Raised Startup")
DCDCButton1 := TUtilGui.Add("Button","Hidden1", "Raised Startup")
DCDCButton1.OnEvent("Click", RaisedStartup)

DCDCText3 := TUtilGui.Add("Text","Hidden1", "Change to Default Startup")
DCDCButton2 := TUtilGui.Add("Button","Hidden1", "Default Startup")
DCDCButton2.OnEvent("Click", DefaultStartup)

DCDCText4 := TUtilGui.Add("Text","Hidden1", "Update AltusID/Board ID")
DCDCID := TUtilGui.Add("Edit","Hidden1")
DCDCID.SetFont("cBlack")
DCDCBtn := TUtilGui.Add("Button","Hidden1", "Update")
DCDCBtn.OnEvent("Click", EnterToSaveQT)

DCDCID.OnEvent("Focus", DCDCBtnFocus)
DCDCID.OnEvent("LoseFocus", DCDCBtnUnFocus)

DCDCText5 := TUtilGui.Add("Text","Hidden1", "Check Current Settings")
DCDCButton3 := TUtilGui.Add("Button","Hidden1", "Check")
DCDCButton3.OnEvent("Click", QTCheck)

DCDCText6 := TUtilGui.Add("Text","Hidden1", "Save Changes")
DCDCSaveButton := TUtilGui.Add("Button","Hidden1", "Save")
DCDCSaveButton.OnEvent("Click", DCDCSave)


;For Relay Board

RBGroupBox := TUtilGui.Add("GroupBox","Hidden1 x736 y35 W190 H195")

RBText1 := TUtilGui.Add("Text", "Hidden1 x750 y39", "For Relay Board")
RBText2 := TUtilGui.Add("Text","Hidden1","Update AltusID/Board ID")
RBID := TUtilGui.Add("Edit","Hidden1")
RBID.SetFont("cBlack")
RBBtn := TUtilGui.Add("Button","Hidden1", "Update")
RBBtn.OnEvent("Click", EnterToSaveQT)

RBID.OnEvent("Focus", RBBtnFocus)
RBID.OnEvent("LoseFocus", RBBtnUnFocus)

RBText3 := TUtilGui.Add("Text","Hidden1", "Check Current Settings")
RBButton1 := TUtilGui.Add("Button","Hidden1", "Check")
RBButton1.OnEvent("Click", QTCheck)


;----------------------------------------------------------------

;For Solenoid Tab
Tab.UseTab("Solenoid")

TUtilGui.Add("Button","x1100 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for solenoid
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
ComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
;ComChoice.OnEvent("Change", SendKeystrokeFromListbox)
ComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
ComChoice.OnEvent("Change", ChangeComDDL)

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
COMPort := TUtilGui.AddDropDownList("W75 Disabled1", Words)


Refresh := TUtilGui.Add("Button","x121 y145 Disabled1", "Refresh")
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

;SolBtn9 := TUtilGui.Add("Button", "x26 y250" ,"FW Menu")
;SolBtn9.OnEvent("Click", SolVisibleStateShow)

SolCheckMark4 := TUtilGui.Add("Checkbox", "x26 y200", "Update Firmware?")
SolCheckMark4.OnEvent("Click", SolCheckBoxEvent4)

SolCheckMark5 := TUtilGui.Add("Checkbox", "x26 y250", "Access Solenoid?")
SolCheckMark5.OnEvent("Click", SolCheckBoxEvent5)

TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
SolInput := TUtilGui.Add("Edit", "")
SolInput.SetFont("cBlack")

SolInput.OnEvent("Focus", SolManBTNFocus)
SolInput.OnEvent("LoseFocus", SolManBTNUnFocus)

SolManInput := TUtilGui.Add("Button","x180 y620","Submit")
SolManInput.OnEvent("Click", SolInputValueEnter)


SolGroupBox1 := TUtilGui.Add("GroupBox", "Hidden1 x280 y35 H235 W300")

SolText1 := TUtilGui.Add("Text","Hidden1 x290 y39", "FW Selected for Installing")
SolFW := TUtilGui.Add("Edit", "Hidden1 ReadOnly")
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
SolText2 := TUtilGui.Add("Text", "Hidden1 ", "Select Firmware Version")
SolBtn1 := TUtilGui.Add("Button", "Hidden1 ", "Browse")
SolBtn1.OnEvent("Click", OpenFiledialogSolenoid)
SolText3 := TUtilGui.Add("Text", "Hidden1 ", "Choose a Solenoid if more than one connected")
ChooseSolFWIns := TUtilGui.AddDropDownList("Hidden1 W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])


;Install FW to Solenoid
SolText4 := TUtilGui.Add("Text", "Hidden1 ", "Install Firmware to Solenoid")

SolBtn2 := TUtilGui.Add("Button", "Hidden1 ", "Install")
SolBtn2.OnEvent("Click", InstallSolenoidEz)

SolGroupBox2 := TUtilGui.Add("GroupBox","Hidden1 x280 y300 H180 W230")

;Access solenoid board
SolText5 := TUtilGui.Add("Text","Hidden1 x290 y300", "Go to Access Solenoid Menu")
SolBtn3 := TUtilGui.Add("Button", "Hidden1 " ,"Go To Menu")
SolBtn3.OnEvent("Click", AccessSolenoidEz)

;Rescan of Solenoid CANIDs
SolText6 := TUtilGui.Add("Text","Hidden1 ", "Rescan Nodes If Necessecary")
SolBtn4 := TUtilGui.Add("Button", "Hidden1 Disabled1", "Rescan")
SolBtn4.OnEvent("Click", PingNodes)

SolBtn5 := TUtilGui.Add("Button","Hidden1 x370 y381 Disabled1", "Re-Initialize PCAN")
SolBtn5.OnEvent("Click", SolPCANReinitialize)

;Choose what solenoid to access
SolText7 := TUtilGui.Add("Text","Hidden1 x290 y420", "Choose Solenoid Board")
SolenoidAccess := TUtilGui.AddDropDownList("Hidden1 W170 Disabled1", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidAccess.OnEvent("Change", SolenoidIDs)
;CBS_DISABLENOSCROLL

SolGroupBox3 := TUtilGui.Add("GroupBox","Hidden1 x590 y35 W198 H208")


SolText10 := TUtilGui.Add("Text","Hidden1 x600 y39 " , "Check Current Settings")
SolBtn6 := TUtilGui.Add("Button", "Hidden1 ","Check")
SolBtn6.OnEvent("Click", CheckSet)

SolText11 := TUtilGui.Add("Text", "Hidden1 " , "Check Calibration Table")
SolBtn7 := TUtilGui.Add("Button", "Hidden1 ","Check")
SolBtn7.OnEvent("Click", CheckCal)

;Checkmark to confirm if change is needed
SolCheckMark1 := TUtilGui.Add("Checkbox", "Hidden1", "Change Solenoid Settings?")
SolCheckMark1.OnEvent("Click", SolCheckBoxEvent1)

;Checkmark for updating sensor values
SolCheckMark2 := TUtilGui.Add("Checkbox", "Hidden1", "Update Sensor Values?")
SolCheckMark2.OnEvent("Click", SolCheckBoxEvent2)

;Checkmark for updating altus IDs
SolCheckMark3 := TUtilGui.Add("Checkbox", "Hidden1", "Update IDs?")
SolCheckMark3.OnEvent("Click", SolCheckBoxEvent3)

SolGroupBox6 := TUtilGui.Add("GroupBox", "Hidden1 x590 y250 W198 H124")

;Changing Solenoid Usage
SolText8 := TUtilGui.Add("Text","Hidden1 x600 y254 ", "Change Solenoid Usage")
SolenoidUse := TUtilGui.AddDropDownList("Hidden1 W170", ["FlexDrive - 0x12", "MotorPump - 0x13", "CompactTracMP - 0x13", "SJR - 0x14", "PrimeStroker - 0x15", "ShortStroker - 0x15", "ShortStrokerV2 - 0x15", "Puncher - 0x16"])
SolenoidUse.OnEvent("Change", SolenoidUsage)

;Changing sensor types
SolText9 := TUtilGui.Add("Text","Hidden1 " , "Change Sensor Type")
SensorType := TUtilGui.AddDropDownList("Hidden1 W170",["HallEffect", "QuadEncoder", "Mech", "Unknown"])
SensorType.OnEvent("Change", SensorTypeChange)

SolGroupBox4 := TUtilGui.Add("GroupBox","Hidden1 x598 y555 W170 H102")

;Test Solenoid
SolText12 := TUtilGui.Add("Text","Hidden1 x608 y560" , "For EL.LAB Use Only!")
SolText13 := TUtilGui.Add("Text","Hidden1 " ,"Test Solenoid Switching")
SolBtn8 := TUtilGui.Add("Button", "Hidden1 ", "Test Switching")
SolBtn8.OnEvent("Click", SolenoidSwitching)

SolGroupBox5 := TUtilGui.Add("GroupBox","Hidden1 x798 y35 W325 H425")

;Text for sensor values
SolText14 := TUtilGui.Add("Text","Hidden1 x808 y182", "SensorLinear m")
SolText15 := TUtilGui.Add("Text", "Hidden1 ", "SensorLinear b")
SolText16 := TUtilGui.Add("Text", "Hidden1 ", "SensorQuadtratic Cb")
SolText17 := TUtilGui.Add("Text", "Hidden1 ", "SensorQuadtratic Cm")
SolText18 := TUtilGui.Add("Text", "Hidden1 ", "SensorQuadtratic Bb")
SolText19 := TUtilGui.Add("Text", "Hidden1 ", "SensorQuadtratic Bm")
SolText20 := TUtilGui.Add("Text", "Hidden1 ", "SensorQuadtratic Ab")
SolText21 := TUtilGui.Add("Text", "Hidden1 ", "SensorQuadtratic Am")
SolText22 := TUtilGui.Add("Text", "Hidden1 ", "Update Sensor Values")

;Text for IDs
SolText23 := TUtilGui.Add("Text", "Hidden1 x808 y513", "Update Altus/Board ID")
SolText24 := TUtilGui.Add("Text", "Hidden1 ", "Update Tool ID")


SolText25 := TUtilGui.Add("Text","Hidden1 x808 y39" , "Select Appropiate Application")
SolRadioBtn1 := TUtilGui.Add("Radio", "Hidden1 x808 y60 Checked", "For Everything Else Sensors")
SolRadioBtn2 := TUtilGui.Add("Radio", "Hidden1 x808 y80", "For CompactStroker Sensors")
SolRadioBtn3 := TUtilGui.Add("Radio", "Hidden1 x808 y100", "For Prime Stroker Sensors")

TheRestDropDownListArray := ["DDP3 '9a' Linear", "DDP3 '9b' Linear", "Comp '10' Linear"]

PrimeStrokerDropDownListArray := ["DDP3 '9a' Linear", "DDP3 '9b' Linear", "Comp '10' Linear", "AncUpper '13a' Quad", "AncLower '13b' Quad"]

CompactStrokerDropDownListArray := ["DDP3 'P-Sa' Linear", "DDP3 'P-Sb' Linear", "DDP3 'P-LF' Linear", "DDP500 'P-Comp' Linear", "DDP3 'P-TW' Linear", "AncUpper 'P-Ga' Quad", "AncLower 'P-Gb' Quad"]


;Changing sensor values
SolText26 := TUtilGui.Add("Text","Hidden1 x808 y120" , "Choose Sensor To Update Values")
SolenoidSensorsDropDownList := TUtilGui.AddDropDownList("Hidden1 W230", TheRestDropDownListArray)
SolenoidSensorsDropDownList.OnEvent("Change", SensorIDs)
;Input edit box for sensor values

SolRadioBtn1.OnEvent("Click", SolenoidSensorTypes)
SolRadioBtn2.OnEvent("Click", SolenoidSensorTypesCompactStroker)
SolRadioBtn3.OnEvent("Click", SolenoidSensorTypesPrimeStroker)

Sensorm := TUtilGui.Add("Edit","Hidden1 x958 y177")
Sensorb := TUtilGui.Add("Edit", "Hidden1 ")
SensorCb := TUtilGui.Add("Edit", "Hidden1 ")
SensorCm := TUtilGui.Add("Edit", "Hidden1 ")
SensorBb := TUtilGui.Add("Edit", "Hidden1 ")
SensorBm := TUtilGui.Add("Edit", "Hidden1 ")
SensorAb := TUtilGui.Add("Edit", "Hidden1 ")
SensorAm := TUtilGui.Add("Edit", "Hidden1 ")
SensorValuesBTN := TUtilGui.Add("Button", "Hidden1 ", "Update Values")
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

SolGroupBox7 := TUtilGui.Add("GroupBox", "Hidden1 x798 y488 W325 H130")

;Input edit box for IDs
SolText27 := TUtilGui.Add("Text","x958 y488 Hidden1","Input IDs")
AltusID := TUtilGui.Add("Edit", "Hidden1 x958 y513")
ToolID := TUtilGui.Add("Edit", "Hidden1 ")
SolUpdateIDBtn := TUtilGui.Add("Button", "Hidden1 ", "Update IDs")
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

TUtilGui.Add("Button","x1100 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for TC Node
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
TCComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])
TCComChoice.Choose("PCAN")
TCComChoice.OnEvent("Change", ChangeComDDL)

TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
TCCOMPort := TUtilGui.AddDropDownList("W75 Disabled1", Words)

RefreshTC := TUtilGui.Add("Button","x121 y145 Disabled1", "Refresh")
RefreshTC.OnEvent("Click", RefreshBtn)

TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
TCInput := TUtilGui.Add("Edit", "")
TCInput.SetFont("cBlack")

TCInput.OnEvent("Focus", TCManBTNFocus)
TCInput.OnEvent("LoseFocus", TCManBTNUnFocus)

TCManInput := TUtilGui.Add("Button","x180 y620","Submit")
TCManInput.OnEvent("Click", TCInputValueEnter)

TCCheckBox1 := TUtilGui.Add("Checkbox", "x26 y200", "Update Firmware?")
TCCheckBox1.OnEvent("Click", TCCheckBoxEvent1)

TCCheckBox2 := TUtilGui.Add("Checkbox", "x26 y250", "Access TC Node?")
TCCheckBox2.OnEvent("Click", TCCheckBoxEvent2)

TCGroupBox1 := TUtilGui.Add("GroupBox", "Hidden1 x280 y35 H235 W300")

TCText12 := TUtilGui.Add("Text","Hidden1 x290 y39", "FW Selected for Installing")
TCFW := TUtilGui.Add("Edit", "Hidden1 ReadOnly")
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
TCText1 := TUtilGui.Add("Text","Hidden1 ", "Select Firmware Version")
TCBtn1 := TUtilGui.Add("Button","Hidden1 ", "Browse")
TCBtn1.OnEvent("Click", OpenFiledialogTC)

TCText2 := TUtilGui.Add("Text","Hidden1 ", "Choose a TC Node if more than one connected")
ChooseTCFWIns := TUtilGui.AddDropDownList("Hidden1 W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])

;Install FW to TC Node
TCText3 := TUtilGui.Add("Text","Hidden1 ", "Install Firmware to TC Node")

TCBtn2 := TUtilGui.Add("Button","Hidden1 ", "Install")
TCBtn2.OnEvent("Click", InstallFWTC)

TCGroupBox2 := TUtilGui.Add("GroupBox","Hidden1 x280 y300 H180 W230")

;Access TC NOde
TCText4 := TUtilGui.Add("Text","Hidden1 x290 y300", "Go to Access TC Node Menu")
TCBtn3 := TUtilGui.Add("Button", "Hidden1 " ,"Go To Menu")
TCBtn3.OnEvent("Click", TCMenu)

;Rescan of TC Nodes CAN IDs
TCText5 := TUtilGui.Add("Text","Hidden1 ", "Rescan Nodes If Necessecary")
TCBtn4 := TUtilGui.Add("Button","Hidden1 Disabled1", "Rescan")
TCBtn4.OnEvent("Click", PingNodes)

TCBtn5 := TUtilGui.Add("Button","Hidden1 x370 y381 Disabled1", "Re-Initialize PCAN")
TCBtn5.OnEvent("Click", PCANReinitialize)

TCText6 := TUtilGui.Add("Text","Hidden1 x290 y420", "Choose TC Node")
TCAccess := TUtilGui.AddDropDownList("Hidden1 W160 Disabled1", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCAccess.OnEvent("Change", UseTCID)

TCGroupBox3 := TUtilGui.Add("GroupBox","x590 y35 W190 H208 Hidden1")

TCText8 := TUtilGui.Add("Text","Hidden1 x600 y39" , "Check Current Settings")
TCBtn6 := TUtilGui.Add("Button","Hidden1 ","Check")
TCBtn6.OnEvent("Click", CheckCal)

TCText13 := TUtilGui.Add("Text","Hidden1 " , "Check Calibration Table")
TCBtn7 := TUtilGui.Add("Button","Hidden1 ","Check")
TCBtn7.OnEvent("Click", CheckSet)

TCCheckBox3 := TUtilGui.Add("Checkbox","Hidden1 ", "Change TC Setting?")
TCCheckBox3.OnEvent("Click", TCCheckBoxEvent3)

TCCheckBox5 := TUtilGui.Add("Checkbox","Hidden1", "Update Sensor Values?")
TCCheckBox5.OnEvent("Click", TCCheckBoxEvent5)

TCCheckBox4 := TUtilGui.Add("Checkbox","Hidden1 ", "Update IDs?")
TCCheckBox4.OnEvent("Click", TCCheckBoxEvent4)

TCGroupBox5 := TUtilGui.Add("GroupBox", "Hidden1 x590 y250 W190 H65")

TCText7 := TUtilGui.Add("Text","Hidden1 x600 y254", "Change TC Node Usage")
TCUsage := TUtilGui.AddDropDownList("Hidden1 W160", ["Upper PR STR - 0x30", "Lower PR STR - 0x31", "Upper TC - 0x32", "Lower TC - 0x33", "DDR TC SJR - 0x34"])
TCUsage.OnEvent("Change", ChangeTCID)

TCGroupBox4 := TUtilGui.Add("GroupBox","Hidden1 x798 y488 W325 H130")

;Text for IDs
TCText9 := TUtilGui.Add("Text","Hidden1 x808 y513", "Update Altus/Board ID")
TCText10 := TUtilGui.Add("Text","Hidden1 ", "Update Tool ID")

;Input edit box for IDs
TCText11 := TUtilGui.Add("Text","Hidden1 x958 y488","Input IDs")
TCAltusID := TUtilGui.Add("Edit","Hidden1 x958 y513")
TCToolID := TUtilGui.Add("Edit", "Hidden1")

TCAltusID.SetFont("cBlack")
TCToolID.SetFont("cBlack")

TCTCIdBtn := TUtilGui.Add("Button","Hidden1 ", "Update IDs")
TCTCIdBtn.OnEvent("Click", UpdateTCIDs)

TCAltusID.OnEvent("Focus", TCBtnFocus)
TCAltusID.OnEvent("LoseFocus", TCBtnUnFocus)

TCToolID.OnEvent("Focus", TCBtnFocus)
TCToolID.OnEvent("LoseFocus", TCBtnUnFocus)

TCCheckBoxEvent1(*){
    if TCCheckBox1.Value == "1" {
        TCFWVisibleStateShow
    }
    else if TCCheckBox1.Value == "0" {
        TCFWVisibleStateHide
    }
}

TCCheckBoxEvent2(*){
    if TCCheckBox2.Value == "1" {
        TCMenuVisibleStateShow
    }
    else if TCCheckBox2.Value == "0" {
        TCMenuVisibleStateHide
    }
}

TCCheckBoxEvent3(*){
    if TCCheckBox3.Value == "1" {
        TCChangeVisibleStateShow
    }
    else if TCCheckBox3.Value == "0" {
        TCChangeVisibleStateHide
    }
}

TCCheckBoxEvent4(*){
    if TCCheckBox4.Value == "1" {
        TCIDVisibleStateShow
    }
    else if TCCheckBox4.Value == "0" {
        TCIDVisibleStateHide
    }
}

TCCheckBoxEvent5(*){
    if TCCheckBox5.Value == "1" {
        TCSensorVisibleStateShow
    }
    else if TCCheckBox5.Value == "0" {
        TCSensorVisibleStateHide
    }
}

TCFWVisibleStateShow(*){
    TCGroupBox1.Visible := true
    TCText12.Visible := true
    TCFW.Visible := true
    TCText1.Visible := true
    TCBtn1.Visible := true
    TCText2.Visible := true
    TCText3.Visible := true
    TCBtn2.Visible := true
    ChooseTCFWIns.Visible := true
}

TCMenuVisibleStateShow(*){
    TCGroupBox2.Visible := true
    TCText4.Visible := true
    TCBtn3.Visible := true
    TCText5.Visible := true
    TCBtn4.Visible := true
    TCBtn5.Visible := true
    TCText6.Visible := true
    TCAccess.Visible := true
}

TCCheckVisibleStateShow(*){
    TCGroupBox3.Visible := true
    TCText8.Visible := true
    TCBtn6.Visible := true
    TCText13.Visible := true
    TCBtn7.Visible := true
    TCCheckBox3.Visible := true
    TCCheckBox4.Visible := true
    ;Remove when sensors are known TCCheckBox5.Visible := true
}

TCChangeVisibleStateShow(*){
    TCGroupBox5.Visible := true
    TCText7.Visible := true
    TCUsage.Visible := true
}

TCIDVisibleStateShow(*){
    TCGroupBox4.Visible := true
    TCText9.Visible := true
    TCText10.Visible := true
    TCText11.Visible := true
    TCAltusID.Visible := true
    TCToolID.Visible := true
    TCTCIdBtn.Visible := true
}

TCSensorVisibleStateShow(*){

}

TCAllVisibleStateShow(*){
    TCFWVisibleStateShow
    TCMenuVisibleStateShow
    TCCheckVisibleStateShow
    TCChangeVisibleStateShow
    TCIDVisibleStateShow
    TCSensorVisibleStateShow
}

TCAllVisibleStateHide(*){
    TCFWVisibleStateHide
    TCMenuVisibleStateHide
    TCCheckVisibleStateHide
    TCChangeVisibleStateHide
    TCIDVisibleStateHide
    TCSensorVisibleStateHide
}

TCFWVisibleStateHide(*){
    TCGroupBox1.Visible := false
    TCText12.Visible := false
    TCFW.Visible := false
    TCText1.Visible := false
    TCBtn1.Visible := false
    TCText2.Visible := false
    TCText3.Visible := false
    TCBtn2.Visible := false
    ChooseTCFWIns.Visible := false
}

TCMenuVisibleStateHide(*){
    TCGroupBox2.Visible := false
    TCText4.Visible := false
    TCBtn3.Visible := false
    TCText5.Visible := false
    TCBtn4.Visible := false
    TCBtn5.Visible := false
    TCText6.Visible := false
    TCAccess.Visible := false
}

TCCheckVisibleStateHide(*){
    TCGroupBox3.Visible := false
    TCText8.Visible := false
    TCBtn6.Visible := false
    TCText13.Visible := false
    TCBtn7.Visible := false
    TCCheckBox3.Visible := false
    TCCheckBox4.Visible := false
    ;Remove when sensors are known TCCheckBox5.Visible := false
}

TCChangeVisibleStateHide(*){
    TCGroupBox5.Visible := false
    TCText7.Visible := false
    TCUsage.Visible := false
}

TCIDVisibleStateHide(*){
    TCGroupBox4.Visible := false
    TCText9.Visible := false
    TCText10.Visible := false
    TCText11.Visible := false
    TCAltusID.Visible := false
    TCToolID.Visible := false
    TCTCIdBtn.Visible := false
}

TCSensorVisibleStateHide(*){

}

;----------------------------------------------------------------

;For 1 Wire Master/Slave
Tab.UseTab("1-Wire")
TUtilGui.Add("Button","x1100 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for 1-wire
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
OneWireMasterComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])
OneWireMasterComChoice.Choose("PCAN")
OneWireMasterComChoice.OnEvent("Change", ChangeComDDL)

TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
OneWireMasterCOMPort := TUtilGui.AddDropDownList("W75 Disabled1", Words)

RefreshOneWire := TUtilGui.Add("Button","x121 y145 Disabled1", "Refresh")
RefreshOneWire.OnEvent("Click", RefreshBtn)


TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
OneWireMasterInput := TUtilGui.Add("Edit", "")
OneWireMasterInput.SetFont("cBlack")

OneWireMasterInput.OnEvent("Focus", OneWireMasterManBTNFocus)
OneWireMasterInput.OnEvent("LoseFocus", OneWireMasterManBTNUnFocus)

OneWireMasterManInput := TUtilGui.Add("Button","x180 y620","Submit")
OneWireMasterManInput.OnEvent("Click", OneWireMasterInputValueEnter)

OneWireCheckBox1 := TUtilGui.Add("Checkbox", "x26 y200", "Update Firmware?")
OneWireCheckBox1.OnEvent("Click", OneWireCheckBoxEvent1)

OneWireCheckBox2 := TUtilGui.Add("Checkbox", "x26 y250", "Access OneWire?")
OneWireCheckBox2.OnEvent("Click", OneWireCheckBoxEvent2)

OneWireGroupBox1 := TUtilGui.Add("GroupBox", "x280 y35 H180 W260 Hidden1")
OneWireText1 := TUtilGui.Add("Text","x290 y39 Hidden1", "FW Selected for Installing 1-Wire Master")
OneWireMasterFW := TUtilGui.Add("Edit", "ReadOnly Hidden1")
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
OneWireText2 := TUtilGui.Add("Text","Hidden1", "Select Firmware Version")
OneWireBtn1 := TUtilGui.Add("Button","Hidden1", "Browse")
OneWireBtn1.OnEvent("Click", OpenFiledialogOneWireMaster)

;Install FW to One Wire Master
OneWireText3 := TUtilGui.Add("Text","Hidden1", "Install Firmware to One Wire Master")
OneWireBtn2 := TUtilGui.Add("Button","Hidden1", "Install")
OneWireBtn2.OnEvent("Click", InstallFWOneWireMaster)


OneWireGroupBox2 := TUtilGui.Add("GroupBox","x280 y300 H180 W240 Hidden1")
;Access One Wire Master NOde

OneWireText4 := TUtilGui.Add("Text","x290 y300 Hidden1", "Go to Access One Wire Master Menu")
OneWireBtn3 := TUtilGui.Add("Button", "Hidden1" ,"Go To Menu")
OneWireBtn3.OnEvent("Click", OneWireMasterMenu)

;Rescan of One Wire Master Nodes CAN IDs
OneWireText5 := TUtilGui.Add("Text","Hidden1", "Rescan Nodes If Necessecary")
OneWireBtn4 := TUtilGui.Add("Button","Hidden1 Disabled1", "Rescan")
OneWireBtn4.OnEvent("Click", PingNodes)

OneWireBtn5 := TUtilGui.Add("Button","x370 y381 Hidden1 Disabled1", "Re-Initialize PCAN")
OneWireBtn5.OnEvent("Click", PCANReinitialize)

OneWireText6 := TUtilGui.Add("Text","x290 y420 Hidden1", "Choose One Wire Master")
OneWireMasterAccess := TUtilGui.AddDropDownList("W170 Hidden1 Disabled1", ["One Wire Master - 0x3A"])
OneWireMasterAccess.OnEvent("Change", UseOneWireMasterID)

OneWireGroupBox4 := TUtilGui.Add("GroupBox","Hidden1 x590 y35 W198 H208")

OneWireText11 := TUtilGui.Add("Text","Hidden1 x600 y39", "Check Current Settings")
OneWireBtn7 := TUtilGui.Add("Button","Hidden1 ", "Check")
OneWireBtn7.OnEvent("Click", OneWireCurSetting)

OneWireText10 := TUtilGui.Add("Text","Hidden1 ", "Check Calibration Table")
OneWireBtn6 := TUtilGui.Add("Button","Hidden1 ", "Check")
OneWireBtn6.OnEvent("Click", OneWireCalSetting)

OneWireCheckBox3 := TUtilGui.Add("Checkbox","Hidden1 ", "Update Sensor Values?")
OneWireCheckBox3.OnEvent("Click", OneWireCheckBoxEvent3)

OneWireCheckBox4 := TUtilGui.Add("Checkbox","Hidden1 ", "Update IDs?")
OneWireCheckBox4.OnEvent("Click", OneWireCheckBoxEvent4)

OneWireGroupBox3 := TUtilGui.Add("GroupBox","x798 y488 W325 H130 Hidden1")

;Text for IDs
OneWireText7 := TUtilGui.Add("Text","x808 y513 Hidden1", "Update Altus/Board ID")
OneWireText8 := TUtilGui.Add("Text"," Hidden1", "Update Tool ID")

;Input edit box for IDs
OneWireText9 := TUtilGui.Add("Text","x958 y488 Hidden1","Input One Wire Master IDs")
OneWireMasterAltusID := TUtilGui.Add("Edit","x958 y513 Hidden1")
OneWireMasterToolID := TUtilGui.Add("Edit","Hidden1")

OneWireMasterAltusID.SetFont("cBlack")
OneWireMasterToolID.SetFont("cBlack")

OneWireMasterIdBtn := TUtilGui.Add("Button"," Hidden1", "Update IDs")
OneWireMasterIdBtn.OnEvent("Click", UpdateOneWireMasterIDs)

OneWireMasterAltusID.OnEvent("Focus", OneWireMasterBtnFocus)
OneWireMasterAltusID.OnEvent("LoseFocus", OneWireMasterBtnUnFocus)

OneWireMasterToolID.OnEvent("Focus", OneWireMasterBtnFocus)
OneWireMasterToolID.OnEvent("LoseFocus", OneWireMasterBtnUnFocus)

OneWireGroupBox5 := TUtilGui.Add("GroupBox","Hidden1 x798 y35 W325 H265")

;Text for sensor values
OneWireText12 := TUtilGui.Add("Text","x808 y182 Hidden1", "SensorLinear m")
OneWireText13 := TUtilGui.Add("Text", "Hidden1 ", "SensorLinear b")
OneWireText14 := TUtilGui.Add("Text", "Hidden1 ", "Update Sensor Values")

OneWireText15 := TUtilGui.Add("Text","Hidden1 x808 y182", "DHP Vfs")
OneWireText16 := TUtilGui.Add("Text", "Hidden1 ", "DHP V0")

OneWireText17 := TUtilGui.Add("Text","Hidden1 x808 y39" , "Select Appropiate Application")
OneWireRadioBtn1 := TUtilGui.Add("Radio", "Hidden1 x808 y60 Checked", "For 1-Wire Slave")

OneWireDDLArray1 := ["'1' XR-HST DDP-3", "'2' Upper CS-DHPP", "'3' Lower CS-DHPP"]

;Changing sensor values
OneWireText18 := TUtilGui.Add("Text","Hidden1 x808 y120" , "Choose Sensor To Update Values")
OneWireDDL1 := TUtilGui.AddDropDownList("Hidden1 W230", OneWireDDLArray1)
OneWireDDL1.OnEvent("Change", OneWireSensorIDs)
;Input edit box for sensor values
;OneWireRadioBtn1.OnEvent("Click", )

OneWireSensor1 := TUtilGui.Add("Edit","Hidden1 x958 y177")
OneWireSensor2 := TUtilGui.Add("Edit", "Hidden1 ")
OneWireBtn8 := TUtilGui.Add("Button", "Hidden1 ", "Update Values")
OneWireBtn8.OnEvent("Click", UpdateSensorValues)

;Set font for sensor value edit box
OneWireSensor1.SetFont("cBlack")
OneWireSensor2.SetFont("cBlack")


OneWireSensor1.OnEvent("Focus", OneWireSensorUpdateBTNFocus)
OneWireSensor1.OnEvent("LoseFocus", OneWireSensorUpdateBTNUnFocus)

OneWireSensor2.OnEvent("Focus", OneWireSensorUpdateBTNFocus)
OneWireSensor2.OnEvent("LoseFocus", OneWireSensorUpdateBTNUnFocus)


OneWireCalSetting(*){
    Hex0xF1
}

OneWireCurSetting(*){
    Hex0xF2
}

OneWireSensorUpdateBTNFocus(*){
    OneWireBtn8.Opt("+Default")
}

OneWireSensorUpdateBTNUnFocus(*){
    OneWireBtn8.Opt("-Default")
}

OneWireSensorIDs(*){
    OneWireSensorID := OneWireDDL1.Text
    Switch OneWireSensorID{
        Case "'1' XR-HST DDP-3":
            OneWireText15.Visible := false
            OneWireText16.Visible := false
            OneWireText12.Visible := true
            OneWireText13.Visible := true
            OneWireText14.Visible := true
            OneWireSensor1.Visible := true
            OneWireSensor2.Visible := true
            OneWireBtn8.Visible := true


        Case "'2' Upper CS-DHPP":
            OneWireText15.Visible := true
            OneWireText16.Visible := true
            OneWireText12.Visible := false
            OneWireText13.Visible := false
            OneWireText14.Visible := true
            OneWireSensor1.Visible := true
            OneWireSensor2.Visible := true
            OneWireBtn8.Visible := true


        Case "'3' Lower CS-DHPP":
            OneWireText15.Visible := true
            OneWireText16.Visible := true
            OneWireText12.Visible := false
            OneWireText13.Visible := false
            OneWireText14.Visible := true
            OneWireSensor1.Visible := true
            OneWireSensor2.Visible := true
            OneWireBtn8.Visible := true


    }
         
}

OneWireCheckBoxEvent1(*){
    if OneWireCheckBox1.Value == "1" {
        OneWireFWVisibleStateShow
    }
    else if OneWireCheckBox1.Value == "0" {
        OneWireFWVisibleStateHide
    }
}

OneWireCheckBoxEvent2(*){
    if OneWireCheckBox2.Value == "1" {
        OneWireMenuVisibleStateShow
    }
    else if OneWireCheckBox2.Value == "0" {
        OneWireMenuVisibleStateHide
    }
}

OneWireCheckBoxEvent3(*){
    if OneWireCheckBox3.Value == "1" {
        OneWireSensorChangeShow
    }
    else if OneWireCheckBox3.Value == "0" {
        OneWireSensorChangeHide
    }
}

OneWireCheckBoxEvent4(*){
    if OneWireCheckBox4.Value == "1" {
        OneWireIDVisibleStateShow
    }
    else if OneWireCheckBox4.Value == "0" {
        OneWireIDVisibleStateHide
    }
}

OneWireFWVisibleStateShow(*){
    OneWireGroupBox1.Visible := true
    OneWireText1.Visible := true
    OneWireMasterFW.Visible := true
    OneWireText2.Visible := true
    OneWireBtn1.Visible := true
    OneWireText3.Visible := true
    OneWireBtn2.Visible := true
}

OneWireMenuVisibleStateShow(*){
    OneWireGroupBox2.Visible := true
    OneWireText4.Visible := true
    OneWireText5.Visible := true
    OneWireBtn3.Visible := true
    OneWireText6.Visible := true
    OneWireBtn4.Visible := true
    OneWireBtn5.Visible := true
    OneWireMasterAccess.Visible := true
}

OneWireIDVisibleStateShow(*){
    OneWireGroupBox3.Visible := true
    OneWireText7.Visible := true
    OneWireText8.Visible := true
    OneWireText9.Visible := true
    OneWireMasterAltusID.Visible := true
    OneWireMasterToolID.Visible := true
    OneWireMasterIdBtn.Visible := true
    
}

OneWireSensorChangeShow(*){
    OneWireGroupBox5.Visible := true
    OneWireText17.Visible := true
    OneWireText18.Visible := true
    OneWireRadioBtn1.Visible := true
    OneWireDDL1.Visible := true
}

OneWireSensorDHPShow(*){
    OneWireText15.Visible := true
    OneWireText16.Visible := true
    OneWireText14.Visible := true
    OneWireSensor1.Visible := true
    OneWireSensor2.Visible := true
    OneWireBtn8.Visible := true
}

OneWireSensorDDPShow(*){
    OneWireText12.Visible := true
    OneWireText13.Visible := true
    OneWireText14.Visible := true
    OneWireSensor1.Visible := true
    OneWireSensor2.Visible := true
    OneWireBtn8.Visible := true
}

OneWireCheckShow(*){
    OneWireGroupBox4.Visible := true
    OneWireText10.Visible := true
    OneWireBtn6.Visible := true
    OneWireText11.Visible := true
    OneWireBtn7.Visible := true
    OneWireCheckBox3.Visible := true
    OneWireCheckBox4.Visible := true
}

OneWireAllVisibleStateShow(*){
    OneWireFWVisibleStateShow
    OneWireMenuVisibleStateShow
    OneWireIDVisibleStateShow
    OneWireSensorChangeShow
    OneWireCheckShow
}

OneWireAllVisibleStateHide(*){
    OneWireFWVisibleStateHide
    OneWireMenuVisibleStateHide
    OneWireIDVisibleStateHide
    OneWireSensorChangeHide
    OneWireCheckHide
}

OneWireFWVisibleStateHide(*){
    OneWireGroupBox1.Visible := false
    OneWireText1.Visible := false
    OneWireMasterFW.Visible := false
    OneWireText2.Visible := false
    OneWireBtn1.Visible := false
    OneWireText3.Visible := false
    OneWireBtn2.Visible := false
}

OneWireMenuVisibleStateHide(*){
    OneWireGroupBox2.Visible := false
    OneWireText4.Visible := false
    OneWireText5.Visible := false
    OneWireBtn3.Visible := false
    OneWireText6.Visible := false
    OneWireBtn4.Visible := false
    OneWireBtn5.Visible := false
    OneWireMasterAccess.Visible := false
}

OneWireIDVisibleStateHide(*){
    OneWireGroupBox3.Visible := false
    OneWireText7.Visible := false
    OneWireText8.Visible := false
    OneWireText9.Visible := false
    OneWireMasterAltusID.Visible := false
    OneWireMasterToolID.Visible := false
    OneWireMasterIdBtn.Visible := false
}

OneWireSensorChangeHide(*){
    OneWireGroupBox5.Visible := false
    OneWireText12.Visible := false
    OneWireText13.Visible := false
    OneWireText14.Visible := false
    OneWireText15.Visible := false
    OneWireText16.Visible := false
    OneWireText17.Visible := false
    OneWireRadioBtn1.Visible := false
    OneWireText18.Visible := false
    OneWireDDL1.Visible := false
    OneWireSensor1.Visible := false
    OneWireSensor2.Visible := false
    OneWireBtn8.Visible := false
}

OneWireCheckHide(*){
    OneWireGroupBox4.Visible := false
    OneWireText10.Visible := false
    OneWireBtn6.Visible := false
    OneWireText11.Visible := false
    OneWireBtn7.Visible := false
    OneWireCheckBox3.Visible := false
    OneWireCheckBox4.Visible := false
}


;----------------------------------------------------------------

;For RSS
Tab.UseTab("RSS")
TUtilGui.Add("Button","x1100 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for RSS
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
RSSComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
RSSComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
RSSComChoice.OnEvent("Change", ChangeComDDL)

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
RSSCOMPort := TUtilGui.AddDropDownList("W75 Disabled1", Words)


RefreshRSS := TUtilGui.Add("Button","x121 y145 Disabled1", "Refresh")
RefreshRSS.OnEvent("Click", RefreshBtn)

TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
RSSInput := TUtilGui.Add("Edit", "")
RSSInput.SetFont("cBlack")

RSSInput.OnEvent("Focus", RSSManBTNFocus)
RSSInput.OnEvent("LoseFocus", RSSManBTNUnFocus)

RSSManInput := TUtilGui.Add("Button","x180 y620","Submit")
RSSManInput.OnEvent("Click", RSSInputValueEnter)

RSSCheckBox1 := TUtilGui.Add("Checkbox", "x26 y200", "Update Firmware?")
RSSCheckBox1.OnEvent("Click", RSSCheckBoxEvent1)

RSSCheckBox2 := TUtilGui.Add("Checkbox", "x26 y250", "Access RSS?")
RSSCheckBox2.OnEvent("Click", RSSCheckBoxEvent2)


RSSGroupBox1 := TUtilGui.Add("GroupBox", "Hidden1 x280 y35 H235 W310")

RSSText1 := TUtilGui.Add("Text","Hidden1 x290 y39", "FW Selected for Installing")
RSSFW := TUtilGui.Add("Edit", "Hidden1 ReadOnly")
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
RSSText2 := TUtilGui.Add("Text","Hidden1 ", "Select Firmware Version")
RSSBtn1 := TUtilGui.Add("Button","Hidden1 ", "Browse")
RSSBtn1.OnEvent("Click", OpenFiledialogRSS)

RSSText3 := TUtilGui.Add("Text","Hidden1 ", "Choose an RSS Node if more than one connected")
ChooseRSSFWIns := TUtilGui.AddDropDownList("Hidden1 W160", ["Upper RSS - 0x1A","Lower RSS - 0x1B"])

;Install FW to RSS Node
RSSText4 := TUtilGui.Add("Text","Hidden1 ", "Install Firmware to RSS Node")

RSSBtn2 := TUtilGui.Add("Button","Hidden1 ", "Install")
RSSBtn2.OnEvent("Click", InstallFWRSS)

RSSGroupBox2 := TUtilGui.Add("GroupBox","Hidden1 x280 y300 H180 W230")

;Access RSS NOde
RSSText5 := TUtilGui.Add("Text","Hidden1 x290 y300", "Go to Access RSS Node Menu")
RSSBtn3 := TUtilGui.Add("Button", "Hidden1 " ,"Go To Menu")
RSSBtn3.OnEvent("Click", RSSMenu)

;Rescan of RSS Nodes CAN IDs
RSSText6 := TUtilGui.Add("Text","Hidden1 ", "Rescan Nodes If Necessecary")
RSSBtn4 := TUtilGui.Add("Button","Hidden1  Disabled1", "Rescan")
RSSBtn4.OnEvent("Click", PingNodes)

RSSBtn5 := TUtilGui.Add("Button","Hidden1 x370 y381 Disabled1", "Re-Initialize PCAN")
RSSBtn5.OnEvent("Click", PCANReinitialize)

RSSText7 := TUtilGui.Add("Text","Hidden1 x290 y420", "Choose RSS")
RSSAccess := TUtilGui.AddDropDownList("Hidden1 W160 Disabled1", ["Upper RSS - 0x1A","Lower RSS - 0x1B"])
RSSAccess.OnEvent("Change", UseRSSID)

RSSGroupBox3 := TUtilGui.Add("GroupBox","Hidden1 x600 y35 W190 H230")

RSSText9 := TUtilGui.Add("Text","Hidden1 x610 y39" , "Check Current Settings")
RSSBtn6 := TUtilGui.Add("Button","Hidden1 ","Check")
RSSBtn6.OnEvent("Click", CheckCal)

RSSText13 := TUtilGui.Add("Text", "Hidden1 ", "Show EventLog")
RSSBtn7 := TUtilGui.Add("Button", "Hidden1 ", "EventLog")
RSSBtn7.OnEvent("Click", RSSShowEventLog)

RSSText14 := TUtilGui.Add("Text", "Hidden1 ", "Show RSS Data Only")
RSSBtn8 := TUtilGui.Add("Button","Hidden1 ", "RSS Data")
RSSBtn8.OnEvent("Click", RSSShowRSSData)

RSSCheckBox3 := TUtilGui.Add("Checkbox","Hidden1 ", "Change RSS Settings?")
RSSCheckBox3.OnEvent("Click", RSSCheckBoxEvent3)

RSSCheckBox4 := TUtilGui.Add("Checkbox","Hidden1 ","Update IDs?")
RSSCheckBox4.OnEvent("Click", RSSCheckBoxEvent4)

RSSGroupBox5 := TUtilGui.Add("GroupBox","Hidden1 X600 y286 W190 H130")

RSSText8 := TUtilGui.Add("Text","Hidden1 x610 y290", "Change RSS Node Usage")
RSSUsage := TUtilGui.AddDropDownList("Hidden1 W160",["Upper RSS - 0x1A","Lower RSS - 0x1B"])
RSSUsage.OnEvent("Change", ChangeRSSID)

RSSText15 := TUtilGui.Add("Text", "Hidden1 ", "Delete EventLog from RSS")
RSSBtn9 := TUtilGui.Add("Button", "Hidden1 ", "Delete")
RSSBtn9.OnEvent("Click", RSSDeleteEventLog)

RSSGroupBox4 := TUtilGui.Add("GroupBox","Hidden1 x800 y35 W325 H130")

;Text for IDs
RSSText10 := TUtilGui.Add("Text","Hidden1 x810 y60", "Update Altus/Board ID")
RSSText11 := TUtilGui.Add("Text","Hidden1 ", "Update Tool ID")

;Input edit box for IDs
RSSText12 := TUtilGui.Add("Text","Hidden1 x960 y39","Input IDs")
RSSAltusID := TUtilGui.Add("Edit","Hidden1 x960 y60")
RSSToolID := TUtilGui.Add("Edit","Hidden1")

RSSAltusID.SetFont("cBlack")
RSSToolID.SetFont("cBlack")

RSSIdBtn := TUtilGui.Add("Button","Hidden1 ", "Update IDs")
RSSIdBtn.OnEvent("Click", UpdateRSSIDs)

RSSAltusID.OnEvent("Focus", RSSBtnFocus)
RSSAltusID.OnEvent("LoseFocus", RSSBtnUnFocus)

RSSToolID.OnEvent("Focus", RSSBtnFocus)
RSSToolID.OnEvent("LoseFocus", RSSBtnUnFocus)


RSSCheckBoxEvent1(*){
    if RSSCheckBox1.Value == "1" {
        RSSFWVisibleStateShow
    }
    else if RSSCheckBox1.Value == "0" {
        RSSFWVisibleStateHide
    }
}

RSSCheckBoxEvent2(*){
    if RSSCheckBox2.Value == "1" {
        RSSMenuVisibleStateShow
    }
    else if RSSCheckBox2.Value == "0" {
        RSSMenuVisibleStateHide
    }
}

RSSCheckBoxEvent3(*){
    if RSSCheckBox3.Value == "1" {
        RSSChangeVisibleStateShow
    }
    else if RSSCheckBox3.Value == "0" {
        RSSChangeVisibleStateHide
    }
}

RSSCheckBoxEvent4(*){
    if RSSCheckBox4.Value == "1" {
        RSSIDVisibleStateShow
    }
    else if RSSCheckBox4.Value == "0" {
        RSSIDVisibleStateHide
    }
}

RSSDeleteEventLog(*){
    Hex0xBE
    RSSEraseKey
}

RSSShowEventLog(*){
    Hex0xF3
    ControlSend "{0}{Space}{2}{0}{Enter}" ,, "tkToolUtility.exe"
}

RSSShowRSSData(*){
    Hex0xF2
}

RSSFWVisibleStateShow(*){
    RSSGroupBox1.Visible := true
    RSSText1.Visible := true
    RSSFW.Visible := true
    RSSText2.Visible := true
    RSSBtn1.Visible := true
    RSSText3.Visible := true
    ChooseRSSFWIns.Visible := true
    RSSText4.Visible := true
    RSSBtn2.Visible := true
}

RSSMenuVisibleStateShow(*){
    RSSGroupBox2.Visible := true
    RSSText5.Visible := true
    RSSBtn3.Visible := true
    RSSText6.Visible := true
    RSSBtn4.Visible := true
    RSSBtn5.Visible := true
    RSSText7.Visible := true
    RSSAccess.Visible := true
}

RSSCheckVisibleStateShow(*){
    RSSGroupBox3.Visible := true
    RSSText9.Visible := true
    RSSBtn6.Visible := true
    RSSText13.Visible := true
    RSSBtn7.Visible := true
    RSSText14.Visible := true
    RSSBtn8.Visible := true
    RSSCheckBox3.Visible := true
    RSSCheckBox4.Visible := true
}

RSSChangeVisibleStateShow(*){
    RSSGroupBox5.Visible := true
    RSSText8.Visible := true
    RSSUsage.Visible := true
    RSSText15.Visible := true
    RSSBtn9.Visible := true
}

RSSIDVisibleStateShow(*){
    RSSGroupBox4.Visible := true
    RSSText10.Visible := true
    RSSText11.Visible := true
    RSSText12.Visible := true
    RSSAltusID.Visible := true
    RSSToolID.Visible := true
    RSSIdBtn.Visible := true
}

RSSAllVisibleStateShow(*){
    RSSIDVisibleStateShow
    RSSFWVisibleStateShow
    RSSAllVisibleStateShow
    RSSMenuVisibleStateShow
    RSSCheckVisibleStateShow
    RSSChangeVisibleStateShow
}

RSSAllVisibleStateHide(*){
    RSSIDVisibleStateHide
    RSSFWVisibleStateHide
    RSSAllVisibleStateHide
    RSSMenuVisibleStateHide
    RSSCheckVisibleStateHide
    RSSChangeVisibleStateHide
}

RSSFWVisibleStateHide(*){
    RSSGroupBox1.Visible := false
    RSSText1.Visible := false
    RSSFW.Visible := false
    RSSText2.Visible := false
    RSSBtn1.Visible := false
    RSSText3.Visible := false
    ChooseRSSFWIns.Visible := false
    RSSText4.Visible := false
    RSSBtn2.Visible := false
}

RSSMenuVisibleStateHide(*){
    RSSGroupBox2.Visible := false
    RSSText5.Visible := false
    RSSBtn3.Visible := false
    RSSText6.Visible := false
    RSSBtn4.Visible := false
    RSSBtn5.Visible := false
    RSSText7.Visible := false
    RSSAccess.Visible := false
}

RSSCheckVisibleStateHide(*){
    RSSGroupBox3.Visible := false
    RSSText9.Visible := false
    RSSBtn6.Visible := false
    RSSText13.Visible := false
    RSSBtn7.Visible := false
    RSSText14.Visible := false
    RSSBtn8.Visible := false
    RSSCheckBox3.Visible := false
    RSSCheckBox4.Visible := false
}

RSSChangeVisibleStateHide(*){
    RSSGroupBox5.Visible := false
    RSSText8.Visible := false
    RSSUsage.Visible := false
    RSSText15.Visible := false
    RSSBtn9.Visible := false
}

RSSIDVisibleStateHide(*){
    RSSGroupBox4.Visible := false
    RSSText10.Visible := false
    RSSText11.Visible := false
    RSSText12.Visible := false
    RSSAltusID.Visible := false
    RSSToolID.Visible := false
    RSSIdBtn.Visible := false
}

;----------------------------------------------------------------

;For Anchor Board
Tab.UseTab("Anchor Board")
TUtilGui.Add("Button","x1100 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for Anchor Board
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
AnchorBoardComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
AnchorBoardComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
AnchorBoardComChoice.OnEvent("Change", ChangeComDDL)

;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
AnchorBoardCOMPort := TUtilGui.AddDropDownList("W75 Disabled1", Words)

RefreshAnchorBoard := TUtilGui.Add("Button","x121 y145 Disabled1", "Refresh")
RefreshAnchorBoard.OnEvent("Click", RefreshBtn)

TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
AnchorBoardInput := TUtilGui.Add("Edit", "")
AnchorBoardInput.SetFont("cBlack")

AnchorBoardInput.OnEvent("Focus", AnchorBoardManBTNFocus)
AnchorBoardInput.OnEvent("LoseFocus", AnchorBoardManBTNUnFocus)

AnchorBoardManInput := TUtilGui.Add("Button","x180 y620","Submit")
AnchorBoardManInput.OnEvent("Click", AnchorBoardInputValueEnter)

AnchorCheckBox1 := TUtilGui.Add("Checkbox", "x26 y200", "Update Firmware?")
AnchorCheckBox1.OnEvent("Click", AnchorCheckBoxEvent1)

AnchorCheckBox2 := TUtilGui.Add("Checkbox", "x26 y250", "Access Anchor Node?")
AnchorCheckBox2.OnEvent("Click", AnchorCheckBoxEvent2)


AnchorGroupBox1 := TUtilGui.Add("GroupBox", "Hidden1 x280 y35 H235 W370")

AnchorText1 := TUtilGui.Add("Text","Hidden1 x290 y39", "FW Selected for Installing")
AnchorBoardFW := TUtilGui.Add("Edit", "Hidden1 ReadOnly")
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
AnchorText2 := TUtilGui.Add("Text","Hidden1 ", "Select Firmware Version")
AnchorBtn1 := TUtilGui.Add("Button","Hidden1 ", "Browse")
AnchorBtn1.OnEvent("Click", OpenFiledialogAnchorBoard)

AnchorText3 := TUtilGui.Add("Text","Hidden1 ", "Choose an Anchor Board Node if more than one connected")
ChooseAnchorBoardFWIns := TUtilGui.AddDropDownList("Hidden1 W160", AnchorBoardArrayID)

;Install FW to Anchor Board Node
AnchorText4 := TUtilGui.Add("Text","Hidden1 ", "Install Firmware to Anchor Board Node")

AnchorBtn2 := TUtilGui.Add("Button","Hidden1 ", "Install")
AnchorBtn2.OnEvent("Click", InstallFWAnchorBoard)

AnchorGroupBox2 := TUtilGui.Add("GroupBox","Hidden1 x280 y300 H180 W260")

;Access Anchor Board NOde
AnchorText5 := TUtilGui.Add("Text","Hidden1 x290 y300", "Go to Access Anchor Board Node Menu")
AnchorBtn3 := TUtilGui.Add("Button", "Hidden1 " ,"Go To Menu")
AnchorBtn3.OnEvent("Click", AnchorBoardMenu)

;Rescan of Anchor Board Nodes CAN IDs
AnchorText6 := TUtilGui.Add("Text","Hidden1 ", "Rescan Nodes If Necessecary")
AnchorBtn4 := TUtilGui.Add("Button","Hidden1 Disabled1 ", "Rescan")
AnchorBtn4.OnEvent("Click", PingNodes)

AnchorBtn5 := TUtilGui.Add("Button","Hidden1 Disabled1 x370 y381", "Re-Initialize PCAN")
AnchorBtn5.OnEvent("Click", PCANReinitialize)

AnchorText7 := TUtilGui.Add("Text","Hidden1 x290 y420", "Choose Anchor Board")
AnchorBoardAccess := TUtilGui.AddDropDownList("Hidden1 Disabled1 W160", AnchorBoardArrayID)
AnchorBoardAccess.OnEvent("Change", UseAnchorBoardID)

AnchorGroupBox3 := TUtilGui.Add("GroupBox","Hidden1 x660 y35 W200 H125")

AnchorText9 := TUtilGui.Add("Text","Hidden1 x670 y39" , "Check Current Settings")
AnchorBtn6 := TUtilGui.Add("Button","Hidden1 ","Check")
AnchorBtn6.OnEvent("Click", CheckCal)

AnchorCheckBox3 := TUtilGui.Add("Checkbox","Hidden1 ", "Change Anchor Settings?")
AnchorCheckBox3.OnEvent("Click", AnchorCheckBoxEvent3)

AnchorCheckBox4 := TUtilGui.Add("Checkbox","Hidden1 ", "Update IDs?")
AnchorCheckBox4.OnEvent("Click", AnchorCheckBoxEvent4)

AnchorGroupBox5 := TUtilGui.Add("GroupBox","Hidden1 x660 y246 W200 H70")

AnchorText8 := TUtilGui.Add("Text","Hidden1 x670 y250", "Change Anchor Board Usage")
AnchorBoardUsage := TUtilGui.AddDropDownList("Hidden1 W160", AnchorBoardArrayID)
AnchorBoardUsage.OnEvent("Change", ChangeAnchorBoardID)

AnchorGroupBox4 := TUtilGui.Add("GroupBox","Hidden1 x870 y35 W325 H130")

;Text for IDs
AnchorText10 := TUtilGui.Add("Text","Hidden1 x880 y60", "Update Altus/Board ID")
AnchorText11 := TUtilGui.Add("Text","Hidden1 ", "Update Tool ID")

;Input edit box for IDs
AnchorText12 := TUtilGui.Add("Text","Hidden1 x1030 y39","Input IDs")
AnchorBoardAltusID := TUtilGui.Add("Edit","Hidden1 x1030 y60")
AnchorBoardToolID := TUtilGui.Add("Edit","Hidden1 ")

AnchorBoardAltusID.SetFont("cBlack")
AnchorBoardToolID.SetFont("cBlack")

AnchorBoardIdBtn := TUtilGui.Add("Button","Hidden1 ", "Update IDs")
AnchorBoardIdBtn.OnEvent("Click", UpdateAnchorBoardIDs)

AnchorBoardAltusID.OnEvent("Focus", AnchorBoardBtnFocus)
AnchorBoardAltusID.OnEvent("LoseFocus", AnchorBoardBtnUnFocus)

AnchorBoardToolID.OnEvent("Focus", AnchorBoardBtnFocus)
AnchorBoardToolID.OnEvent("LoseFocus", AnchorBoardBtnUnFocus)

AnchorCheckBoxEvent1(*){
    if AnchorCheckBox1.Value == "1" {
        AnchorFWVisibleStateShow
    }
    else if AnchorCheckBox1.Value == "0" {
        AnchorFWVisibleStateHide
    }
}

AnchorCheckBoxEvent2(*){
    if AnchorCheckBox2.Value == "1" {
        AnchorMenuVisibleStateShow
    }
    else if AnchorCheckBox2.Value == "0" {
        AnchorMenuVisibleStateHide
    }
}

AnchorCheckBoxEvent3(*){
    if AnchorCheckBox3.Value == "1" {
        AnchorChangeVisibleStateShow
    }
    else if AnchorCheckBox3.Value == "0" {
        AnchorChangeVisibleStateHide
    }
}

AnchorCheckBoxEvent4(*){
    if AnchorCheckBox4.Value == "1" {
        AnchorIDVisibleStateShow
    }
    else if AnchorCheckBox4.Value == "0" {
        AnchorIDVisibleStateHide
    }
}

AnchorFWVisibleStateShow(*){
    AnchorGroupBox1.Visible := true
    AnchorText1.Visible := true
    AnchorBoardFW.Visible := true
    AnchorText2.Visible := true
    AnchorBtn1.Visible := true
    AnchorText3.Visible := true
    ChooseAnchorBoardFWIns.Visible := true
    AnchorText4.Visible := true
    AnchorBtn2.Visible := true
}

AnchorMenuVisibleStateShow(*){
    AnchorGroupBox2.Visible := true
    AnchorText5.Visible := true
    AnchorBtn3.Visible := true
    AnchorText6.Visible := true
    AnchorBtn4.Visible := true
    AnchorBtn5.Visible := true
    AnchorText7.Visible := true
    AnchorBoardAccess.Visible := true
}

AnchorCheckVisibleStateShow(*){
    AnchorGroupBox3.Visible := true
    AnchorText9.Visible := true
    AnchorBtn6.Visible := true
    AnchorCheckBox3.Visible := true
    AnchorCheckBox4.Visible := true
}

AnchorChangeVisibleStateShow(*){
    AnchorGroupBox5.Visible := true
    AnchorText8.Visible := true
    AnchorBoardUsage.Visible := true
}

AnchorIDVisibleStateShow(*){
    AnchorGroupBox4.Visible := true
    AnchorText10.Visible := true
    AnchorText11.Visible := true
    AnchorText12.Visible := true
    AnchorBoardAltusID.Visible := true
    AnchorBoardToolID.Visible := true
    AnchorBoardIdBtn.Visible := true
}

AnchorAllVisibleStateShow(*){
    AnchorFWVisibleStateShow
    AnchorMenuVisibleStateShow
    AnchorCheckVisibleStateShow
    AnchorChangeVisibleStateShow
    AnchorIDVisibleStateShow
}

AnchorAllVisibleStateHide(*){
    AnchorFWVisibleStateHide
    AnchorMenuVisibleStateHide
    AnchorCheckVisibleStateHide
    AnchorChangeVisibleStateHide
    AnchorIDVisibleStateHide
}

AnchorFWVisibleStateHide(*){
    AnchorGroupBox1.Visible := false
    AnchorText1.Visible := false
    AnchorBoardFW.Visible := false
    AnchorText2.Visible := false
    AnchorBtn1.Visible := false
    AnchorText3.Visible := false
    ChooseAnchorBoardFWIns.Visible := false
    AnchorText4.Visible := false
    AnchorBtn2.Visible := false
}

AnchorMenuVisibleStateHide(*){
    AnchorGroupBox2.Visible := false
    AnchorText5.Visible := false
    AnchorBtn3.Visible := false
    AnchorText6.Visible := false
    AnchorBtn4.Visible := false
    AnchorBtn5.Visible := false
    AnchorText7.Visible := false
    AnchorBoardAccess.Visible := false
}

AnchorCheckVisibleStateHide(*){
    AnchorGroupBox3.Visible := false
    AnchorText9.Visible := false
    AnchorBtn6.Visible := false
}

AnchorChangeVisibleStateHide(*){
    AnchorGroupBox5.Visible := false
    AnchorText8.Visible := false
    AnchorBoardUsage.Visible := false
}

AnchorIDVisibleStateHide(*){
    AnchorGroupBox4.Visible := false
    AnchorText10.Visible := false
    AnchorText11.Visible := false
    AnchorText12.Visible := false
    AnchorBoardAltusID.Visible := false
    AnchorBoardToolID.Visible := false
    AnchorBoardIdBtn.Visible := false
}

;----------------------------------------------------------------

;For Orientation
Tab.UseTab("Orientation")
TUtilGui.Add("Button","x1100 y630","Restart TestUtility").OnEvent("Click", RestartTestUtil)

TUtilGui.Add("GroupBox","x18 y35 W255 H150")

;Selecting communication option for Orientation
TUtilGui.Add("Text","x26 y39","Select Communication Choice")
OrientationComChoice := TUtilGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
OrientationComChoice.Choose("PCAN")
TUtilGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
OrientationComChoice.OnEvent("Change", ChangeComDDL)


;Manually choose com port number
TUtilGui.Add("Text",, "Select COM Port Number")
OrientationCOMPort := TUtilGui.AddDropDownList("W75 Disabled1", Words)


RefreshOrientation := TUtilGui.Add("Button","x121 y145 Disabled1", "Refresh")
RefreshOrientation.OnEvent("Click", RefreshBtn)



TUtilGui.Add("Text", " x26 y600", "Manual input for TestUtil")
OrientationInput := TUtilGui.Add("Edit", "")
OrientationInput.SetFont("cBlack")

OrientationInput.OnEvent("Focus", OrientationManBTNFocus)
OrientationInput.OnEvent("LoseFocus", OrientationManBTNUnFocus)

OrientationManInput := TUtilGui.Add("Button","x180 y620","Submit")
OrientationManInput.OnEvent("Click", OrientationInputValueEnter)

OrientationCheckBox1 := TUtilGui.Add("Checkbox", "x26 y200", "Update Firmware?")
OrientationCheckBox1.OnEvent("Click", OrientationCheckBoxEvent1)

OrientationCheckBox2 := TUtilGui.Add("Checkbox", "x26 y250", "Access Orientation Node?")
OrientationCheckBox2.OnEvent("Click", OrientationCheckBoxEvent2)

OrientationGroupBox1 := TUtilGui.Add("GroupBox", "Hidden1 x280 y35 H235 W350")

OrientationText1 := TUtilGui.Add("Text","Hidden1 x290 y39", "FW Selected for Installing")
OrientationFW := TUtilGui.Add("Edit", "Hidden1 ReadOnly")
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
OrientationText2 := TUtilGui.Add("Text","Hidden1 ", "Select Firmware Version")
OrientationBtn1 := TUtilGui.Add("Button","Hidden1 ", "Browse")
OrientationBtn1.OnEvent("Click", OpenFiledialogOrientation)

OrientationText3 := TUtilGui.Add("Text","Hidden1 ", "Choose an Orientation Node if more than one connected")
ChooseOrientationFWIns := TUtilGui.AddDropDownList("Hidden1 W160", OrientationArrayID)

;Install FW to Orientation Node
OrientationText4 := TUtilGui.Add("Text","Hidden1 ", "Install Firmware to Orientation Node")

OrientationBtn2 := TUtilGui.Add("Button","Hidden1 ", "Install")
OrientationBtn2.OnEvent("Click", InstallFWOrientation)

OrientationGroupBox2 := TUtilGui.Add("GroupBox","Hidden1 x280 y300 H180 W240")

;Access Orientation NOde
OrientationText5 := TUtilGui.Add("Text","Hidden1 x290 y300", "Go to Access Orientation Node Menu")
OrientationBtn3 := TUtilGui.Add("Button", "Hidden1 " ,"Go To Menu")
OrientationBtn3.OnEvent("Click", OrientationMenu)

;Rescan of Orientation Nodes CAN IDs
OrientationText6 := TUtilGui.Add("Text","Hidden1 ", "Rescan Nodes If Necessecary")
OrientationBtn4 := TUtilGui.Add("Button","Hidden1 Disabled1 ", "Rescan")
OrientationBtn4.OnEvent("Click", PingNodes)

OrientationBtn5 := TUtilGui.Add("Button","Hidden1 Disabled1 x370 y381", "Re-Initialize PCAN")
OrientationBtn5.OnEvent("Click", PCANReinitialize)

OrientationText7 := TUtilGui.Add("Text","Hidden1 x290 y420", "Choose Orientation")
OrientationAccess := TUtilGui.AddDropDownList("Hidden1 Disabled1 W160", OrientationArrayID)
OrientationAccess.OnEvent("Change", UseOrientationID)

OrientationGroupBox3 := TUtilGui.Add("GroupBox","Hidden1 x640 y35 W210 H170")

OrientationText8 := TUtilGui.Add("Text","Hidden1 x650 y39" , "Check Current Settings")
OrientationBtn6 := TUtilGui.Add("Button","Hidden1 ","Check")
OrientationBtn6.OnEvent("Click", CheckCal)

OrientationText12 := TUtilGui.Add("Text","Hidden1 " , "Check Calibration Table")
OrientationBtn7 := TUtilGui.Add("Button","Hidden1 ","Check")
OrientationBtn7.OnEvent("Click", CheckSet)

OrientationCheckBox3 := TUtilGui.Add("Checkbox","Hidden1", "Change Orientation Settings?")
OrientationCheckBox3.OnEvent("Click", OrientationCheckBoxEvent3)

OrientationCheckBox4 := TUtilGui.Add("Checkbox","Hidden1 ", "Update IDs?")
OrientationCheckBox4.OnEvent("Click", OrientationCheckBoxEvent4)

OrientationGroupBox4 :=TUtilGui.Add("GroupBox","Hidden1 x640 y246 W200 H70")

OrientationGroupBox5 := TUtilGui.Add("GroupBox","Hidden1 x870 y35 W325 H130")

;Text for IDs
OrientationText9 := TUtilGui.Add("Text","Hidden1 x880 y60", "Update Altus/Board ID")
OrientationText10 := TUtilGui.Add("Text","Hidden1", "Update Tool ID")

;Input edit box for IDs
OrientationText11 := TUtilGui.Add("Text","Hidden1 x1030 y39","Input Orientation IDs")
OrientationAltusID := TUtilGui.Add("Edit","Hidden1 x1030 y60")
OrientationToolID := TUtilGui.Add("Edit","Hidden1")

OrientationAltusID.SetFont("cBlack")
OrientationToolID.SetFont("cBlack")

OrientationIdBtn := TUtilGui.Add("Button","Hidden1", "Update IDs")
OrientationIdBtn.OnEvent("Click", UpdateOrientationIDs)

OrientationAltusID.OnEvent("Focus", OrientationBtnFocus)
OrientationAltusID.OnEvent("LoseFocus", OrientationBtnUnFocus)

OrientationToolID.OnEvent("Focus", OrientationBtnFocus)
OrientationToolID.OnEvent("LoseFocus", OrientationBtnUnFocus)


OrientationCheckBoxEvent1(*){
    if OrientationCheckBox1.Value == "1" {
        OrientationFWVisibleStateShow
    }
    else if OrientationCheckBox1.Value == "0" {
        OrientationFWVisibleStateHide
    }
}

OrientationCheckBoxEvent2(*){
    if OrientationCheckBox2.Value == "1" {
        OrientationMenuVisibleStateShow
    }
    else if OrientationCheckBox2.Value == "0" {
        OrientationMenuVisibleStateHide
    }
}

OrientationCheckBoxEvent3(*){
    if OrientationCheckBox3.Value == "1" {
        OrientationChangeVisibleStateShow
    }
    else if OrientationCheckBox3.Value == "0" {
        OrientationChangeVisibleStateHide
    }
}

OrientationCheckBoxEvent4(*){
    if OrientationCheckBox4.Value == "1" {
        OrientationIDVisibleStateShow
    }
    else if OrientationCheckBox4.Value == "0" {
        OrientationIDVisibleStateHide
    }
}


OrientationFWVisibleStateShow(*){
OrientationGroupBox1.Visible := true
OrientationText1.Visible := true
OrientationFW.Visible := true
OrientationText2.Visible := true
OrientationBtn1.Visible := true
OrientationText3.Visible := true
OrientationText4.Visible := true
OrientationBtn2.Visible := true
ChooseOrientationFWIns.Visible := true
}

OrientationMenuVisibleStateShow(*){
OrientationGroupBox2.Visible := true
OrientationText5.Visible := true
OrientationBtn3.Visible := true
OrientationText6.Visible := true
OrientationBtn4.Visible := true
OrientationBtn5.Visible := true
OrientationText7.Visible := true
OrientationAccess.Visible := true
}

OrientationCheckVisibleStateShow(*){
OrientationGroupBox3.Visible := true
OrientationText8.Visible := true
OrientationBtn6.Visible := true
OrientationText12.Visible := true
OrientationBtn7.Visible := true
;OrientationCheckBox3.Visible := true
OrientationCheckBox4.Visible := true
}

OrientationChangeVisibleStateShow(*){

}

OrientationIDVisibleStateShow(*){
OrientationGroupBox5.Visible := true
OrientationText9.Visible := true
OrientationText10.Visible := true
OrientationText11.Visible := true
OrientationAltusID.Visible := true
OrientationToolID.Visible := true
OrientationIdBtn.Visible := true
}

OrientationAllVisibleStateShow(*){
    OrientationFWVisibleStateShow
    OrientationCheckVisibleStateShow
    OrientationChangeVisibleStateShow
    OrientationIDVisibleStateShow
    OrientationMenuVisibleStateShow
}

OrientationAllVisibleStateHide(*){
    OrientationFWVisibleStateHide
    OrientationCheckVisibleStateHide
    OrientationChangeVisibleStateHide
    OrientationIDVisibleStateHide
    OrientationMenuVisibleStateHide
}

OrientationFWVisibleStateHide(*){
OrientationGroupBox1.Visible := false
OrientationText1.Visible := false
OrientationFW.Visible := false
OrientationText2.Visible := false
OrientationBtn1.Visible := false
OrientationText3.Visible := false
OrientationText4.Visible := false
OrientationBtn2.Visible := false
ChooseOrientationFWIns.Visible := false
}

OrientationMenuVisibleStateHide(*){
OrientationGroupBox2.Visible := false
OrientationText5.Visible := false
OrientationBtn3.Visible := false
OrientationText6.Visible := false
OrientationBtn4.Visible := false
OrientationBtn5.Visible := false
OrientationText7.Visible := false
OrientationAccess.Visible := false
}

OrientationCheckVisibleStateHide(*){
OrientationGroupBox3.Visible := false
OrientationText8.Visible := false
OrientationBtn6.Visible := false
OrientationText12.Visible := false
OrientationBtn7.Visible := false
OrientationCheckBox3.Visible := false
OrientationCheckBox4.Visible := false
}

OrientationChangeVisibleStateHide(*){

}


OrientationIDVisibleStateHide(*){
OrientationGroupBox5.Visible := false
OrientationText9.Visible := false
OrientationText10.Visible := false
OrientationText11.Visible := false
OrientationAltusID.Visible := false
OrientationToolID.Visible := false
OrientationIdBtn.Visible := false
}



;----------------------------------------------------------------

;Disable Wheel scrolling

#HotIf WinActive(TUtilGui)
WheelUp::return

WheelDown::return

;Close Both windows
SetTimer CheckProgram, 500

TUtilGui.OnEvent("Close", CloseGui)

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
    OneWireSensor1.Value := ""
    OneWireSensor2.Value := ""
    RSSAltusID.Value := ""
    RSSToolID.Value := ""
    AnchorBoardAltusID.Value := ""
    AnchorBoardToolID.Value := ""
    OrientationAltusID.Value := ""
    OrientationToolID.Value := ""

    MCVisibleStateHide()
    DCDCVisibleStateHide()
    RBVisibleStateHide()
    SolAllVisibleStateHide
    TCAllVisibleStateHide
    OneWireAllVisibleStateHide
    AnchorAllVisibleStateHide
    OrientationAllVisibleStateHide


    SolCheckMark1.Value := "0"
    SolCheckMark2.Value := "0"
    SolCheckMark3.Value := "0"
    SolCheckMark4.Value := "0"
    SolCheckMark5.Value := "0"
    SolRadioBtn1.Value := "1"

    TCCheckBox1.Value := "0"
    TCCheckBox2.Value := "0"
    TCCheckBox3.Value := "0"
    TCCheckBox4.Value := "0"
    TCCheckBox5.Value := "0"

    OneWireCheckBox1.Value := "0"
    OneWireCheckBox2.Value := "0"
    OneWireCheckBox3.Value := "0"
    OneWireCheckBox4.Value := "0"

    RSSCheckBox1.Value := "0"
    RSSCheckBox2.Value := "0"
    RSSCheckBox3.Value := "0"
    RSSCheckBox4.Value := "0"

    AnchorCheckBox1.Value := "0"
    AnchorCheckBox2.Value := "0"
    AnchorCheckBox3.Value := "0"
    AnchorCheckBox4.Value := "0"

    OrientationCheckBox1.Value := "0"
    OrientationCheckBox2.Value := "0"
    OrientationCheckBox3.Value := "0"
    OrientationCheckBox4.Value := "0"

    SolBtn4.Enabled := false
    SolBtn5.Enabled := false
    SolenoidAccess.Enabled := false
    TCBtn4.Enabled := false
    TCBtn5.Enabled := false
    TCAccess.Enabled := false
    OneWireBtn4.Enabled := false
    OneWireBtn5.Enabled := false
    OneWireMasterAccess.Enabled := false
    RSSBtn4.Enabled := false
    RSSBtn5.Enabled := false
    RSSAccess.Enabled := false
    AnchorBtn4.Enabled := false
    AnchorBtn5.Enabled := false
    AnchorBoardAccess.Enabled := false
    OrientationBtn4.Enabled := false
    OrientationBtn5.Enabled := false
    OrientationAccess.Enabled := false

    COMPort.Enabled := false
    Refresh.Enabled := false
    TCCOMPort.Enabled := false
    RefreshTC.Enabled := false
    OneWireMasterCOMPort.Enabled := false
    RefreshOneWire.Enabled := false
    RSSCOMPort.Enabled := false
    RefreshRSS.Enabled := false
    AnchorBoardCOMPort.Enabled := false
    RefreshAnchorBoard.Enabled := false
    OrientationCOMPort.Enabled := false
    RefreshOrientation.Enabled := false

    QTComChoice.Choose 1
    QTCOMPort.Choose 0
    BoardChoice.Choose 0
    ComChoice.Choose 1
    COMPort.Choose 0
    ChooseSolFWIns.Choose 0
    SolenoidAccess.Choose 0
    SolenoidUse.Choose 0
    SensorType.Choose 0
    SolenoidSensorsDropDownList.Choose 0
    TCComChoice.Choose 1
    TCCOMPort.Choose 0
    ChooseTCFWIns.Choose 0
    TCAccess.Choose 0
    TCUsage.Choose 0
    OneWireMasterCOMPort.Choose 0
    OneWireMasterComChoice.Choose 1
    OneWireMasterAccess.Choose 0
    RSSCOMPort.Choose 0
    RSSComChoice.Choose 1
    RSSAccess.Choose 0
    ChooseRSSFWIns.Choose 0
    AnchorBoardCOMPort.Choose 0
    AnchorBoardComChoice.Choose 1
    AnchorBoardAccess.Choose 0
    ChooseAnchorBoardFWIns.Choose 0
    AnchorBoardUsage.Choose 0
    OrientationCOMPort.Choose 0
    OrientationComChoice.Choose 1
    OrientationAccess.Choose 0

    WinMove(0,0,,, "ahk_exe tkToolUtility.exe")
    Sleep 200
    WinActivate (WindowTitle)
    ControlSend  "{Enter}", , "tkToolUtility.exe"
    SetTimer CheckProgram, 500
}

InstallSolenoidEz(*){
    Solenoidenter()
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
    Solenoidenter()
    SendKeystrokeFromListbox()
    Keystroke1()
    SolBtn4.Enabled := true
    SolBtn5.Enabled := true
    SolenoidAccess.Enabled := true
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

DCDCVisibleStateShow(*){
    DCDCGroupBox.Visible := true
    DCDCText1.Visible := true
    DCDCText2.Visible := true
    DCDCButton1.Visible := true
    DCDCText3.Visible := true
    DCDCButton2.Visible := true
    DCDCText4.Visible := true
    DCDCID.Visible := true
    DCDCBtn.Visible := true
    DCDCText5.Visible := true
    DCDCButton3.Visible := true
    DCDCText6.Visible := true
    DCDCSaveButton.Visible := true
    }
    
DCDCVisibleStateHide(*){
    DCDCGroupBox.Visible := false
    DCDCText1.Visible := false
    DCDCText2.Visible := false
    DCDCButton1.Visible := false
    DCDCText3.Visible := false
    DCDCButton2.Visible := false
    DCDCText4.Visible := false
    DCDCID.Visible := false
    DCDCBtn.Visible := false
    DCDCText5.Visible := false
    DCDCButton3.Visible := false
    DCDCText6.Visible := false
    DCDCSaveButton.Visible := false
    }
    
MCVisibleStateShow(*){
    MCGroupBox.Visible := true
    MCText1.Visible := true
    MCText2.Visible := true
    MCID.Visible := true
    MCText3.Visible := true
    QTID.Visible := true
    MCBtn.Visible := true
    MCText4.Visible := true
    MCButton1.Visible := true
    }
        
MCVisibleStateHide(*){
    MCGroupBox.Visible := false
    MCText1.Visible := false
    MCText2.Visible := false
    MCID.Visible := false
    MCText3.Visible := false
    QTID.Visible := false
    MCBtn.Visible := false
    MCText4.Visible := false
    MCButton1.Visible := false
    }
        
RBVisibleStateShow(*){
    RBGroupBox.Visible := true
    RBText1.Visible := true
    RBText2.Visible := true
    RBID.Visible := true
    RBBtn.Visible := true
    RBText3.Visible := true
    RBButton1.Visible := true
    }
        
RBVisibleStateHide(*){
    RBGroupBox.Visible := false
    RBText1.Visible := false
    RBText2.Visible := false
    RBID.Visible := false
    RBBtn.Visible := false
    RBText3.Visible := false
    RBButton1.Visible := false
    }

SolCheckBoxEvent1(*){
    if(SolCheckMark1.Value == "1"){
        SolChangesVisibleStateShow
    }
        else if (SolCheckMark1.Value == "0"){
            SolChangesVisibleStateHide
            SolenoidUse.Choose 0
            SensorType.Choose 0
        }

}

SolCheckBoxEvent2(*){
    if(SolCheckMark2.Value == "1"){
        SolSensorVisibleStateShow
    }
        else if (SolCheckMark2.Value == "0"){
            SolSensorVisibleStateHide
            SolSensorLinearVisibleStateHide
            SolSensorQuadVisibleStateHide
            SolSensorBtnVisibleStateHide
            SolenoidSensorsDropDownList.Choose 0
        }

}

SolCheckBoxEvent3(*){
    if(SolCheckMark3.Value == "1"){
        SolIDVisibleStateShow
    }
        else if (SolCheckMark3.Value == "0"){
            SolIDVisibleStateHide
        }

}

SolCheckBoxEvent4(*){
    if(SolCheckMark4.Value == "1"){
        SolFWVisibleStateShow
    }
        else if (SolCheckMark4.Value == "0"){
            SolFWVisibleStateHide
            ChooseSolFWIns.Choose 0
        }

}

SolCheckBoxEvent5(*){
    if(SolCheckMark5.Value == "1"){
        SolMenuVisibleStateShow
    }
        else if (SolCheckMark5.Value == "0"){
            SolMenuVisibleStateHide
            SolenoidAccess.Choose 0
        }

}

SolFWVisibleStateShow(*){
    SolGroupBox1.Visible := true
    SolText1.Visible := true
    SolFW.Visible := true
    SolText2.Visible := true
    SolBtn1.Visible := true
    SolText3.Visible := true
    ChooseSolFWIns.Visible := true
    SolText4.Visible := true
    SolBtn2.Visible := true
}

SolMenuVisibleStateShow(*){
    SolGroupBox2.Visible := true
    SolText5.Visible := true
    SolBtn3.Visible := true
    SolText6.Visible := true
    SolBtn4.Visible := true
    SolBtn5.Visible := true
    SolText7.Visible := true
    SolenoidAccess.Visible := true
}

SolChangesVisibleStateShow(*){
    SolGroupBox6.Visible := true
    SolText8.Visible := true
    SolenoidUse.Visible := true
    SolText9.Visible := true
    SensorType.Visible := true
}

SolSensorVisibleStateShow(*){
    SolGroupBox5.Visible := true
    SolText25.Visible := true
    SolRadioBtn1.Visible := true
    SolRadioBtn2.Visible := true
    SolRadioBtn3.Visible := true
    SolText26.Visible := true
    SolenoidSensorsDropDownList.Visible := true
}

SolSensorLinearVisibleStateShow(*){
    SolText14.Visible := true
    SolText15.Visible := true

    Sensorm.Visible := true
    Sensorb.Visible := true

    SolText22.Visible := true
    SensorValuesBTN.Visible := true

}

SolSensorQuadVisibleStateShow(*){
    SolText16.Visible := true
    SolText17.Visible := true
    SolText18.Visible := true
    SolText19.Visible := true
    SolText20.Visible := true
    SolText21.Visible := true

    SensorCb.Visible := true
    SensorCm.Visible := true
    SensorBb.Visible := true
    SensorBm.Visible := true
    SensorAb.Visible := true
    SensorAm.Visible := true

    SolText22.Visible := true
    SensorValuesBTN.Visible := true
}

SolIDVisibleStateShow(*){
    SolGroupBox7.Visible := true
    SolText23.Visible := true
    SolText24.Visible := true
    SolText27.Visible := true
    AltusID.Visible := true
    ToolID.Visible := true
    SolUpdateIDBtn.Visible := true
}

SolVisibleStateShow(*){
    SolGroupBox3.Visible := true
    SolText10.Visible := true
    SolBtn6.Visible := true
    SolText11.Visible := true
    SolBtn7.Visible := true
    SolCheckMark1.Visible := true
    SolCheckMark2.Visible := true
    SolCheckMark3.Visible := true

    SolGroupBox4.Visible := true
    SolText12.Visible := true
    SolText13.Visible := true
    SolBtn8.Visible := true

}

SolFWVisibleStateHide(*){
    SolGroupBox1.Visible := false
    SolText1.Visible := false
    SolFW.Visible := false
    SolText2.Visible := false
    SolBtn1.Visible := false
    SolText3.Visible := false
    ChooseSolFWIns.Visible := false
    SolText4.Visible := false
    SolBtn2.Visible := false
}

SolChangesVisibleStateHide(*){
    SolGroupBox6.Visible := false
    SolText8.Visible := false
    SolenoidUse.Visible := false
    SolText9.Visible := false
    SensorType.Visible := false
}

SolMenuVisibleStateHide(*){
    SolGroupBox2.Visible := false
    SolText5.Visible := false
    SolBtn3.Visible := false
    SolText6.Visible := false
    SolBtn4.Visible := false
    SolBtn5.Visible := false
    SolText7.Visible := false
    SolenoidAccess.Visible := false
}

SolSensorVisibleStateHide(*){
    SolGroupBox5.Visible := false
    SolText25.Visible := false
    SolRadioBtn1.Visible := false
    SolRadioBtn2.Visible := false
    SolRadioBtn3.Visible := false
    SolText26.Visible := false
    SolenoidSensorsDropDownList.Visible := false
}

SolSensorLinearVisibleStateHide(*){
    SolText14.Visible := false
    SolText15.Visible := false

    Sensorm.Visible := false
    Sensorb.Visible := false
}

SolSensorQuadVisibleStateHide(*){
    SolText16.Visible := false
    SolText17.Visible := false
    SolText18.Visible := false
    SolText19.Visible := false
    SolText20.Visible := false
    SolText21.Visible := false

    SensorCb.Visible := false
    SensorCm.Visible := false
    SensorBb.Visible := false
    SensorBm.Visible := false
    SensorAb.Visible := false
    SensorAm.Visible := false

}

SolSensorBtnVisibleStateHide(*){
    SolText22.Visible := false
    SensorValuesBTN.Visible := false
}

SolIDVisibleStateHide(*){
    SolGroupBox7.Visible := false
    SolText23.Visible := false
    SolText24.Visible := false
    SolText27.Visible := false
    AltusID.Visible := false
    ToolID.Visible := false
    SolUpdateIDBtn.Visible := false
}

SolAllVisibleStateHide(*){
    SolFWVisibleStateHide
    SolSensorBtnVisibleStateHide
    SolMenuVisibleStateHide
    SolSensorQuadVisibleStateHide
    SolSensorLinearVisibleStateHide

    SolGroupBox3.Visible := false
    SolChangesVisibleStateHide
    SolText10.Visible := false
    SolBtn6.Visible := false
    SolText11.Visible := false
    SolBtn7.Visible := false

    SolGroupBox4.Visible := false
    SolText12.Visible := false
    SolText13.Visible := false
    SolBtn8.Visible := false

    SolCheckMark1.Visible := false
    SolCheckMark3.Visible := false
    SolCheckMark2.Visible := false

    SolSensorVisibleStateHide
    SolIDVisibleStateHide

}

SolAllVisibleStateShow(*){
    SolFWVisibleStateShow
    SolMenuVisibleStateShow
    SolSensorQuadVisibleStateShow
    SolSensorLinearVisibleStateShow

    SolGroupBox3.Visible := true
    SolChangesVisibleStateShow
    SolText10.Visible := true
    SolBtn6.Visible := true
    SolText11.Visible := true
    SolBtn7.Visible := true

    SolGroupBox4.Visible := true
    SolText12.Visible := true
    SolText13.Visible := true
    SolBtn8.Visible := true

    SolCheckMark1.Visible := true
    SolCheckMark3.Visible := true
    SolCheckMark2.Visible := true

    SolSensorVisibleStateShow
    SolIDVisibleStateShow

}
    


QTCOMPortSelect(*){
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
            MCVisibleStateShow()
        Case "DCDC Converter" :
            DCDC()
            QTCOMPortSelect()
            DCDCVisibleStateShow()
        Case "Relay Board" :
            RelayBoard()
            QTCOMPortSelect()
            RBVisibleStateShow()
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
    ControlSend  "{1}{3}{3}{Enter}", , "tkToolUtility.exe"
}

WriteUpperWindow(*){
    ControlSend  "{1}{3}{4}{Enter}", , "tkToolUtility.exe"
}

RaisedStartup(*){
    WriteLowerWindow()
    Sleep 300
    ControlSend  "{8}{0}{0}{Enter}", , "tkToolUtility.exe"
    Sleep 1000
    WriteUpperWindow()
    Sleep 300
    ControlSend  "{9}{5}{0}{Enter}", , "tkToolUtility.exe"
    Sleep 300
    
}


DefaultStartup(*){
    WriteLowerWindow()
    Sleep 300
    ControlSend  "{3}{0}{0}{Enter}", , "tkToolUtility.exe"
    Sleep 1000
    WriteUpperWindow()
    Sleep 300
    ControlSend  "{4}{5}{0}{Enter}", , "tkToolUtility.exe"
    Sleep 300
}

UpdateMCID(*){
    ControlSend  "{1}{3}{5}{Enter}", , "tkToolUtility.exe"
}

UpdateQTID(*){
    ControlSend  "{1}{3}{6}{Enter}", , "tkToolUtility.exe"
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
    ControlSend  "{2}{4}{3}{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  DCDCID.Value, , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    DCDCID.Value := ""
}


UpdateRBID(*){
    ControlSend  "{2}{4}{3}{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  RBID.Value, , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  "{1}{6}{0}{Enter}", , "tkToolUtility.exe"
    RBID.Value := ""
    Sleep 300
    ControlSend  "{y}", , "tkToolUtility.exe"
}

ChangeComDDL(*){
    SelectedOption := ComChoice.Text
    SelectedOptionTCC := TCComChoice.Text
    SelectedOptionOneWire := OneWireMasterComChoice.Text
    SelectedOptionRSS := RSSComChoice.Text
    SelectedOptionAnchor := AnchorBoardComChoice.Text
    SelectedOptionOrientation := OrientationComChoice.Text

    switch SelectedOption {
        case "PCAN":
            COMPort.Enabled := false
            Refresh.Enabled := false
        case "QPSK/MasterBox":
            COMPort.Enabled := true
            Refresh.Enabled := true
        case "OFDM":
            COMPort.Enabled := true
            Refresh.Enabled := true
    }

    Switch SelectedOptionOneWire {
        case "PCAN":
            OneWireMasterCOMPort.Enabled := false
            RefreshOneWire.Enabled := false
        case "QPSK/MasterBox":
            OneWireMasterCOMPort.Enabled := true
            RefreshOneWire.Enabled := true
        case "OFDM":
            OneWireMasterCOMPort.Enabled := true
            RefreshOneWire.Enabled := true
        }

    Switch SelectedOptionTCC {
        case "PCAN":
            RefreshTC.Enabled := false
            TCCOMPort.Enabled := false
        case "QPSK/MasterBox":
            RefreshTC.Enabled := true
            TCCOMPort.Enabled := true
        case "OFDM":
            RefreshTC.Enabled := true
            TCCOMPort.Enabled := true
        }

    Switch SelectedOptionRSS {
        case "PCAN":
            RefreshRSS.Enabled := false
            RSSCOMPort.Enabled := false
        case "QPSK/MasterBox":
            RefreshRSS.Enabled := true
            RSSCOMPort.Enabled := true
        case "OFDM":
            RefreshRSS.Enabled := true
            RSSCOMPort.Enabled := true
        }

    Switch SelectedOptionAnchor {
        case "PCAN":
            RefreshAnchorBoard.Enabled := false
            AnchorBoardCOMPort.Enabled := false
        case "QPSK/MasterBox":
            RefreshAnchorBoard.Enabled := true
            AnchorBoardCOMPort.Enabled := true
        case "OFDM":
            RefreshAnchorBoard.Enabled := true
            AnchorBoardCOMPort.Enabled := true
        }

    Switch SelectedOptionOrientation {
        case "PCAN":
            RefreshOrientation.Enabled := false
            OrientationCOMPort.Enabled := false
        case "QPSK/MasterBox":
            RefreshOrientation.Enabled := true
            OrientationCOMPort.Enabled := true
        case "OFDM":
            RefreshOrientation.Enabled := true
            OrientationCOMPort.Enabled := true
        }
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

    ControlSend  COMPort.Text ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 500
    ControlSend "{Enter}", , "tkToolUtility.exe"
}

TCCOMPortSelect(*){

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
        SolVisibleStateShow
        Keystroke2()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "MotorPump - 0x13":
        SolVisibleStateShow
        Keystroke3()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "CompactTracMP - 0x13":
        SolVisibleStateShow
        Keystroke3()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "SJR - 0x14":
        SolVisibleStateShow
        Keystroke4()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "PrimeStroker - 0x15":
        SolVisibleStateShow
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "ShortStroker - 0x15":
        SolVisibleStateShow  
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "ShortStrokerV2 - 0x15":
        SolVisibleStateShow
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "Puncher - 0x16":
        SolVisibleStateShow 
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
        FileSetAttrib "-R", "hexFiles_SOL\SOL_leinApp_bl.hex"

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
        ControlSend "{3}{Enter}",, "tkToolUtility.exe"
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

SolenoidSensorTypesCompactStroker(*){
    SolenoidSensorsDropDownList.Delete()
    SolenoidSensorsDropDownList.Add(CompactStrokerDropDownListArray)
    SolSensorLinearVisibleStateHide
    SolSensorQuadVisibleStateHide
    SolSensorBtnVisibleStateHide

}

SolenoidSensorTypes(*){
    SolenoidSensorsDropDownList.Delete()
    SolenoidSensorsDropDownList.Add(TheRestDropDownListArray)
    SolSensorLinearVisibleStateHide
    SolSensorQuadVisibleStateHide
    SolSensorBtnVisibleStateHide
}

SolenoidSensorTypesPrimeStroker(*){
    SolenoidSensorsDropDownList.Delete()
    SolenoidSensorsDropDownList.Add(PrimeStrokerDropDownListArray)
    SolSensorLinearVisibleStateHide
    SolSensorQuadVisibleStateHide
    SolSensorBtnVisibleStateHide
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
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke1()
            Sleep 100
            Keystroke1()
        case "DDP3 '9b' Linear":
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke2()
            Sleep 100
            Keystroke1()
        case "Comp '10' Linear":
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke3()
            Sleep 100
            Keystroke1()
        Case "AncUpper '13a' Quad":
            SolSensorLinearVisibleStateHide
            SolSensorQuadVisibleStateShow
            Keystroke4()
            Sleep 100
            Keystroke2()
        Case "AncLower '13b' Quad":
            SolSensorLinearVisibleStateHide
            SolSensorQuadVisibleStateShow
            Keystroke5()
            Sleep 100
            Keystroke2()

        Case "DDP3 'P-Sa' Linear":
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke1()
            Sleep 100
            Keystroke1()
        Case "DDP3 'P-Sb' Linear":
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke2()
            Sleep 100
            Keystroke1()
        Case "DDP3 'P-LF' Linear":
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke3()
            Sleep 100
            Keystroke1()
        Case "DDP500 'P-Comp' Linear":
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke4()
            Sleep 100
            Keystroke1()
        Case "DDP3 'P-TW' Linear":
            SolSensorLinearVisibleStateShow
            SolSensorQuadVisibleStateHide
            Keystroke5()
            Sleep 100
            Keystroke1()
        Case "AncUpper 'P-Ga' Quad":
            SolSensorLinearVisibleStateHide
            SolSensorQuadVisibleStateShow
            Keystroke6()
            Sleep 100
            Keystroke2()
        Case "AncLower 'P-Gb' Quad":
            SolSensorLinearVisibleStateHide
            SolSensorQuadVisibleStateShow
            Keystroke7()
            Sleep 100
            Keystroke2()
        Case "":
            SolSensorLinearVisibleStateHide
            SolSensorQuadVisibleStateHide
            SolSensorBtnVisibleStateHide

}
}

UpdateSensorValues(*){
    OneWireSelectedSensors := OneWireDDL1.Text
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

Switch OneWireSelectedSensors{
    Case "'1' XR-HST DDP-3":
        if (OneWireSensor1.Value != "" && OneWireSensor2.Value != "")
        {
            Hex0xF9
            Keystroke1
            ControlSend OneWireSensor1.Value "{Space}" OneWireSensor2.Value "{Enter}",, "tkToolUtility.exe"
            Hex0xDA
            ControlSend "{y}" ,, "tkToolUtility.exe"
        }

    Case "'2' Upper CS-DHPP":
        if (OneWireSensor1.Value != "" && OneWireSensor2.Value != "")
            {
                Hex0xF9
                Keystroke2
                ControlSend OneWireSensor1.Value "{Space}" OneWireSensor2.Value "{Enter}",, "tkToolUtility.exe"
                Hex0xDA
                ControlSend "{y}" ,, "tkToolUtility.exe"
            }

    Case "'3' Lower CS-DHPP":
        if (OneWireSensor1.Value != "" && OneWireSensor2.Value != "")
            {
                Hex0xF9
                Keystroke3
                ControlSend OneWireSensor1.Value "{Space}" OneWireSensor2.Value "{Enter}",, "tkToolUtility.exe"
                Hex0xDA
                ControlSend "{y}" ,, "tkToolUtility.exe"
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
OneWireSensor1.Value := ""
OneWireSensor2.Value := ""

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
        FileSetAttrib "-R", "hexFiles_TC\TC_leinApp_bl.hex"

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
            TCBtn4.Enabled := true
            TCBtn5.Enabled := true
            TCAccess.Enabled := true
        case "QPSK/MasterBox":
            Keystroke2()
            Sleep 200
            Keystroke1()
            ControlSend  TCCOMPort.Text ,, "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 200
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            TCBtn4.Enabled := true
            TCBtn5.Enabled := true
            TCAccess.Enabled := true
        case "OFDM":
            Keystroke3()
            Sleep 200
            Keystroke3()
            TCBtn4.Enabled := true
            TCBtn5.Enabled := true
            TCAccess.Enabled := true
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
        TCCheckVisibleStateShow

        Case "Lower PR STR - 0x31" :
        Hex0x3()
        Sleep 100
        Keystroke1()
        TCCheckVisibleStateShow

        Case "Upper TC - 0x32" :
        Hex0x3()
        Sleep 100
        Keystroke2()
        TCCheckVisibleStateShow
        Case "Lower TC - 0x33" :
        Hex0x3()
        Sleep 100
        Keystroke3()
        TCCheckVisibleStateShow
        Case "DDR TC SJR - 0x34" :
        Hex0x3()
        Sleep 100
        Keystroke4()
        TCCheckVisibleStateShow
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
    FileSetAttrib "-R", "hexFiles_SWC\SWC_leinApp_bl.hex"

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
    OneWireBtn4.Enabled := true
    OneWireBtn5.Enabled := true
    OneWireMasterAccess.Enabled := true
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
        OneWireCheckShow
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
        FileSetAttrib "-R", "hexFiles_RSS\RSS_leinApp_bl.hex"

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
    RSSBtn4.Enabled := true
    RSSBtn5.Enabled := true
    RSSAccess.Enabled := true
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
    RSSCheckVisibleStateShow
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
        FileSetAttrib "-R", "hexFiles_ANC\ANC_leinApp_bl.hex"
    
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
    AnchorBtn4.Enabled := true
    AnchorBtn5.Enabled := true
    AnchorBoardAccess.Enabled := true
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
    AnchorCheckVisibleStateShow
}


ChangeAnchorBoardID(*){
    Hex0xFD()
    Sleep 200
    AnchorBoardChange := AnchorBoardUsage.Text
    Switch AnchorBoardChange{
        Case "sStrV2 - 0x3C" :
        ControlSend "{1}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}{y}", , "tkToolUtility.exe"

        Case "Puncher - 0x3D" :
        ControlSend "{2}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}{y}", , "tkToolUtility.exe"

        Case "HVCO - 0x3E" :
        ControlSend "{4}", , "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}{y}", , "tkToolUtility.exe"

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
        FileSetAttrib "-R", "hexFiles_ORI\ORI_leinApp_bl.hex"
    
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
    OrientationBtn4.Enabled := true
    OrientationBtn5.Enabled := true
    OrientationAccess.Enabled := true
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
    OrientationCheckVisibleStateShow
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




SingleEnter(*) {
    ; Send a keystroke to the console window
    ControlSend  "{Enter}", , "tkToolUtility.exe"
}

Solenoidenter(*) {
    ; Send a keystroke to the console window
    ControlSend  "{2}", , "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"
    
    }
    

Test(*) {
    MsgBox "testing"
}

Keystroke0(*){
    ControlSend "{0}{Enter}",, "tkToolUtility.exe"
}

Keystroke1(*){
    ControlSend "{1}{Enter}",, "tkToolUtility.exe"
}

Keystroke2(*){
    ControlSend "{2}{Enter}",, "tkToolUtility.exe"
}

Keystroke3(*){
    ControlSend "{3}{Enter}",, "tkToolUtility.exe"
}

Keystroke4(*){
    ControlSend "{4}{Enter}",, "tkToolUtility.exe"
}

Keystroke5(*){
    ControlSend "{5}{Enter}",, "tkToolUtility.exe"
}

Keystroke6(*){
    ControlSend "{6}{Enter}",, "tkToolUtility.exe"
}

Keystroke7(*){
    ControlSend "{7}{Enter}",, "tkToolUtility.exe"
}

Keystroke8(*){
    ControlSend "{8}{Enter}",, "tkToolUtility.exe"
}

Keystroke9(*){
    ControlSend "{9}{Enter}",, "tkToolUtility.exe"
}


Hex0xF1(*){
    ControlSend "{0}{x}{F}{1}{Enter}",, "tkToolUtility.exe"
}

Hex0xF2(*){
    ControlSend "{0}{x}{F}{2}{Enter}",, "tkToolUtility.exe"
}

Hex0xF3(*){
    ControlSend "{0}{x}{F}{3}{Enter}",, "tkToolUtility.exe"
}

Hex0xF4(*){
    ControlSend "{0}{x}{F}{4}{Enter}",, "tkToolUtility.exe"
}

Hex0xF6(*){
    ControlSend "{0}{x}{F}{6}{Enter}",, "tkToolUtility.exe"
}

Hex0xF7(*){
    ControlSend "{0}{x}{F}{7}{Enter}",, "tkToolUtility.exe"
}

Hex0xF8(*){
    ControlSend "{0}{x}{F}{8}{Enter}",, "tkToolUtility.exe"
}

Hex0xF9(*){
    ControlSend "{0}{x}{F}{9}{Enter}",, "tkToolUtility.exe"
}


Hex0xFA(*){
    ControlSend "{0}{x}{F}{A}{Enter}",, "tkToolUtility.exe"
}

Hex0xFD(*){
    ControlSend "{0}{x}{F}{D}{Enter}",, "tkToolUtility.exe"
}


Hex0x1(*){
    ControlSend "{0}{x}{1}",, "tkToolUtility.exe"
}
 
Hex0x8F(*){
    ControlSend "{0}{x}{8}{F}{Enter}",, "tkToolUtility.exe"
}

Hex0xBE(*){
    ControlSend "{0}{x}{B}{E}{Enter}",, "tkToolUtility.exe"
}

Hex0xCD(*){
    ControlSend "{0}{x}{C}{D}{Enter}",, "tkToolUtility.exe"
}

Hex0xCB(*){
    ControlSend "{0}{x}{C}{B}{Enter}",, "tkToolUtility.exe"
}

Hex0xA2(*){
    ControlSend "{0}{x}{A}{2}{Enter}",, "tkToolUtility.exe"
}

Hex0xDA(*){
    ControlSend "{0}{x}{D}{A}{Enter}",, "tkToolUtility.exe"
}

Hex0xEB(*){
    ControlSend "{0}{x}{E}{B}{Enter}",, "tkToolUtility.exe"
}

Hex0x8A(*){
    ControlSend "{0}{x}{8}{A}{Enter}",, "tkToolUtility.exe"
}

Hex0x8C(*){
    ControlSend "{0}{x}{8}{C}{Enter}",, "tkToolUtility.exe"
}

Hex0x81(*){
    ControlSend "{0}{x}{8}{1}{Enter}",, "tkToolUtility.exe"
}

Hex0x87(*){
    ControlSend "{0}{x}{8}{7}{Enter}",, "tkToolUtility.exe"
}

Hex0x88(*){
    ControlSend "{0}{x}{8}{8}{Enter}",, "tkToolUtility.exe"
}

Hex0x9B(*){
    ControlSend "{0}{x}{9}{B}{Enter}",, "tkToolUtility.exe"
}

Hex0x3(*){
    ControlSend "{0}{x}{3}",, "tkToolUtility.exe"
}

Hex0x1A(*){
    ControlSend "{0}{x}{1}{A}{Enter}",, "tkToolUtility.exe"
}

Hex0x1B(*){
    ControlSend "{0}{x}{1}{B}{Enter}",, "tkToolUtility.exe"
}

Hex0x2B(*){
    ControlSend "{0}{x}{2}{B}{Enter}",, "tkToolUtility.exe"
}


Hex0x3A(*){
    ControlSend "{0}{x}{3}{A}{Enter}",, "tkToolUtility.exe"
}

Hex0x3C(*){
    ControlSend "{0}{x}{3}{C}{Enter}",, "tkToolUtility.exe"
}

Hex0x3D(*){
    ControlSend "{0}{x}{3}{D}{Enter}",, "tkToolUtility.exe"
}

Hex0x3E(*){
    ControlSend "{0}{x}{3}{E}{Enter}",, "tkToolUtility.exe"
}

RSSEraseKey(*){
    ControlSend "{5}{1}{5}{2}{Enter}",, "tkToolUtility.exe"
}

MCSave(*){
ControlSend  "{1}{6}{1}{Enter}", , "tkToolUtility.exe"
Sleep 300
}

DCDCSave(*){
    ControlSend  "{1}{6}{0}{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  "{y}", , "tkToolUtility.exe"

}

QTCheck(*){
    ControlSend "{2}{4}{1}{Enter}" ,, "tkToolUtility.exe"
}

