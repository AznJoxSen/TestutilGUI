Run "tkToolUtility.exe"
Sleep 400
ControlSend  "{Enter}", , "tkToolUtility.exe"
SetWorkingDir(A_ScriptDir)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon (iconPath)

MyGui := Gui(, "V1.1 TestUtilityGUI For Use With TestUtilityV40")

SetDarkWindowFrame(MyGui)
MyGui.Setfont("s10 cWhite")
MyGui.BackColor := "424242"
WinMove(0,0,,, "ahk_exe tkToolUtility.exe")


SetDarkWindowFrame(hwnd, boolEnable:=1) {
    hwnd := WinExist(hwnd)
    if VerCompare(A_OSVersion, "10.0.17763") >= 0
        attr := 19
    if VerCompare(A_OSVersion, "10.0.18985") >= 0
        attr := 20
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", boolEnable, "int", 4)
}

;Create tabs
Tab := MyGui.Add("Tab3",, ["Q-Telemetry", "Solenoid", "TC Node"])
Tab.Font := "Bold"

;For Q-Telemetry Tab
Tab.UseTab("Q-telemetry")

;MyGui.Add("GroupBox", "W200 H100", "Communication optios")

;Choose Modem Type
MyGui.Add("Text","", "Choose Modem Type")
QTComChoice := MyGui.AddDropDownList("W80", ["QPSK", "OFDM"])
QTComChoice.Choose("QPSK")

;Choose Board
MyGui.Add("Text",, "Choose Board Type")
BoardChoice := MyGui.AddDropDownList("W150", ["Master Controller", "DCDC Converter", "Relay Board"])
BoardChoice.OnEvent("Change", BoardSelect)

;Select Master Controller
;MyGui.Add("Text",, "Press THIS button for Master Controller")
;MyGui.Add("Button",, "Master Controller").OnEvent("Click", MasterController)



;Select DCDC Converter
;MyGui.Add("Text","x360 y116", "Press THIS Button for DCDC Converter")
;MyGui.Add("Button",, "DCDC Converter").OnEvent("Click", DCDC)




;Select Relay Board
;MyGui.Add("Text","x360 y116", "Press THIS Button for Relay Board")
;MyGui.Add("Button",,"Relay Board").OnEvent("Click", RelayBoard)

MyGui.Add("Text",, "Select COM Port Number")
QTCOMPort := MyGui.Add("Edit", "W70")
QTCOMPort.SetFont("cBlack")
MyGui.Add("UpDown") 
MyGui.Add("Button",, "OK").OnEvent("Click", QTCOMPortSelect)

;For Master Controller
MyGui.Add("Text","x250 y39", "For Master Controller")
MyGui.Add("Text",,"Update AltusID/Board ID")
MCID := MyGui.Add("Edit")
MCID.SetFont("cBlack")

MyGui.Add("Text",,"Update Q-Telemetry Module ID")
QTID := MyGui.Add("Edit")
QTID.SetFont("cBlack")

MyGui.Add("Button",, "Update").OnEvent("Click", UpdateQIDs)

;For DCDC
MyGui.Add("Text","x500 y39", "For DCDC Converter")
MyGui.Add("Text",, "Change to Raised Startup")
MyGui.Add("Button",, "Raised Startup").OnEvent("Click", RaisedStartup)

MyGui.Add("Text",, "Change to Default Startup")
MyGui.Add("Button",, "Default Startup").OnEvent("Click", DefaultStartup)

MyGui.Add("Text",, "Update AltusID/Board ID")
DCDCID := MyGui.Add("Edit")
DCDCID.SetFont("cBlack")
MyGui.Add("Button",, "Update").OnEvent("Click", UpdateDCDCID)

;For Relay Board
MyGui.Add("Text", "x750 y39", "For Relay Board")
MyGui.Add("Text",,"Update AltusID/Board ID")
RBID := MyGui.Add("Edit")
RBID.SetFont("cBlack")
MyGui.Add("Button",, "Update").OnEvent("Click", UpdateRBID)

;For Solenoid Tab
Tab.UseTab("Solenoid")

;Select Solenoid
MyGui.Add("Text",,"Press button for selecting Solenoid")
SolenoidButton := MyGui.Add("Button", ,"Solenoid", ).OnEvent("Click", enter,)

;Selecting communication option for solenoid
MyGui.Add("Text",,"Select Communication Choice")
ComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM",])
ComChoice.OnEvent("Change", SendKeystrokeFromListbox)

;Browse for FW for Solenoid
MyGui.Add("Text",, "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogSolenoid)

;Install FW to Solenoid
MyGui.Add("Text",, "Install Firmware to Solenoid")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWSolenoid)

;Access solenoid board
MyGui.Add("Text",, "Access Solenoid Board")
MyGui.Add("Button", "" ,"Access").OnEvent("Click", AccessSolenoid)

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
COMPort := MyGui.Add("Edit", "W70")
COMPort.SetFont("cBlack")
MyGui.Add("UpDown") 
MyGui.Add("Button",, "OK").OnEvent("Click", COMPortSelect)


;Rescan of Solenoid CANIDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

;Choose what solenoid to access
MyGui.Add("Text",, "Choose Solenoid Board")
SolenoidAccess := MyGui.AddDropDownList("W150", ["FlexDrive", "MotorPump", "CompactTracMP", "SJR", "PrimeStroker", "ShortStroker", "ShortStrokerV2", "Puncher"])
SolenoidAccess.OnEvent("Change", SolenoidIDs)
;CBS_DISABLENOSCROLL

;Changing Solenoid Usage
MyGui.Add("Text","x360 y39", "Change Solenoid Usage")
SolenoidUse := MyGui.AddDropDownList("W150", ["FlexDrive", "MotorPump", "CompactTracMP", "SJR", "PrimeStroker", "ShortStroker", "ShortStrokerV2", "Puncher"])
SolenoidUse.OnEvent("Change", SolenoidUsage)

;Changing sensor types
MyGui.Add("Text","" , "Choose Sensor Type")
SensorType := MyGui.AddDropDownList("W150",["HallEffect", "QuadEncoder", "Mech", "Unknown"])
SensorType.OnEvent("Change", SensorTypeChange)

;Changing sensor values
MyGui.Add("Text","" , "Update Sensor Data For:")
SolenoidSensors := MyGui.AddDropDownList("W150", ["DDP3 '9a' Linear", "DDP3 '9b' Linear", "Comp '10' Linear", "AncUpper '13a' Quad", "AncLower '13b' Quad", "Sensor6 'Not in Use'", "Sensor7 'Not in Use'"])
SolenoidSensors.OnEvent("Change", SensorIDs)

;Test Solenoid
MyGui.Add("Text","x360 y260" , "For EL.LAB Use Only!")
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
Sensorm := MyGui.Add("Edit")
Sensorb := MyGui.Add("Edit")
SensorCb := MyGui.Add("Edit")
SensorCm := MyGui.Add("Edit")
SensorBb := MyGui.Add("Edit")
SensorBm := MyGui.Add("Edit")
SensorAb := MyGui.Add("Edit")
SensorAm := MyGui.Add("Edit")
MyGui.Add("Button",, "Update").OnEvent("Click", UpdateSensorValues)

;Set font for sensor value edit box
Sensorm.SetFont("cBlack")
Sensorb.SetFont("cBlack")
SensorCb.SetFont("cBlack")
SensorCm.SetFont("cBlack")
SensorBb.SetFont("cBlack")
SensorBm.SetFont("cBlack")
SensorAb.SetFont("cBlack")
SensorAm.SetFont("cBlack")

;Input edit box for IDs
AltusID := MyGui.Add("Edit")
ToolID := MyGui.Add("Edit")
MyGui.Add("Button",, "Update IDs").OnEvent("Click", UpdateIDs)

;Set font for ID value edit box
AltusID.SetFont("cBlack")
ToolID.SetFont("cBlack")

; For TC Node tab
Tab.UseTab("TC Node")

;Selecting communication option for TC Node
MyGui.Add("Text",,"Select Communication Choice")
TCComChoice := MyGui.AddDropDownList("w130", ["PCAN","QPSK/MasterBox","OFDM"])

;Manually choose com port number
MyGui.Add("Text",, "Select COM Port Number")
TCCOMPort := MyGui.Add("Edit", "W70")
TCCOMPort.SetFont("cBlack")
MyGui.Add("UpDown") 

;Browse for FW for TC Node
MyGui.Add("Text",, "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogTC)

;Install FW to TC Node
MyGui.Add("Text",, "Install Firmware to TC Node")
MyGui.Add("Text",, "OBS! Choose COM Port for QPSK/OFDM")
MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWTC)

;Access TC NOde
MyGui.Add("Text",, "Access TC Node")
MyGui.Add("Button", "" ,"Access").OnEvent("Click", AccessTC)

;Rescan of TC Nodes CAN IDs
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)

TCCANID := MyGui.AddDropDownList("W100", ["0x30", "0x31", "0x32", "0x33", "0x34"])

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



CheckProgram(*){
    if !WinExist("ahk_exe tkToolUtility.exe")
        {
            
            Sleep 500
            ExitApp
            Sleep 500
            SetTimer CheckProgram, 0
        }
        
}

BoardSelect(*){
    SelectedBoard := BoardChoice.Text
    Switch SelectedBoard{
        Case "Master Controller" :
            MasterController()
        Case "DCDC Converter" :
            DCDC()
        Case "Relay Board" :
            RelayBoard()
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

QTCOMPortSelect(*){

    ControlSend  "{C}", , "tkToolUtility.exe"
    ControlSend  "{O}", , "tkToolUtility.exe"
    ControlSend  "{M}", , "tkToolUtility.exe"
    ControlSend  QTCOMPort.Value ,, "tkToolUtility.exe"
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
    DCDCSave()
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
    DCDCSave()
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
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend  "{6}", , "tkToolUtility.exe"
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  "{y}", , "tkToolUtility.exe"
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

    ControlSend  "{C}", , "tkToolUtility.exe"
    ControlSend  "{O}", , "tkToolUtility.exe"
    ControlSend  "{M}", , "tkToolUtility.exe"
    ControlSend  COMPort.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 500
    ControlSend "{Enter}", , "tkToolUtility.exe"
}

TCCOMPortSelect(*){

    ControlSend  "{C}", , "tkToolUtility.exe"
    ControlSend  "{O}", , "tkToolUtility.exe"
    ControlSend  "{M}", , "tkToolUtility.exe"
    ControlSend  TCCOMPort.Value ,, "tkToolUtility.exe"
    Sleep 100
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 500
    ControlSend "{Enter}", , "tkToolUtility.exe"
}



PingNodes(*){
    Keystroke3()
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
        case "FlexDrive": 
        Keystroke2()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "MotorPump":
        Keystroke3()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "CompactTracMP":
        Keystroke3()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "SJR":
        Keystroke4()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "PrimeStroker":
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "ShortStroker":
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "ShortStrokerV2":
        Keystroke5()
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "Puncher":
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

    }
}

InstallFWSolenoid(*){
    SelectedCom := ComChoice.Text
    switch SelectedCom {
        case "PCAN":
        ControlSend "{3}",, "tkToolUtility.exe"
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "QPSK/MasterBox":
        Keystroke3()
        Sleep 100
        ControlSend  "{C}", , "tkToolUtility.exe"
        ControlSend  "{O}", , "tkToolUtility.exe"
        ControlSend  "{M}", , "tkToolUtility.exe"
        ControlSend  COMPort.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "OFDM":
            Keystroke3()
    }
}


SolenoidUsage(*){
    SolenoidSelected := SolenoidUse.Text
    Sleep 100
    Hex0xF4()
    Sleep 200
    switch SolenoidSelected {
        case "FlexDrive": 
        Keystroke3()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "MotorPump":
        Keystroke1()
        Sleep 200
        ControlSend  "{n}", , "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "CompactTracMP":
        Keystroke2()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "SJR":
        Keystroke4()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "PrimeStroker":
        Keystroke5()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStroker":
        Keystroke6()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStrokerV2":
        Keystroke7()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Sleep 200
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "Puncher":
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
            MsgBox "Don't Use this DumbDumb"
        Case "Sensor7 'Not in Use'":
            ;Keystroke7()
            MsgBox "Don't Use this DumbDumb"

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
            MsgBox "Don't Use this DumbDumb"
        Case "Sensor7 'Not in Use'":
            MsgBox "Don't Use this DumbDumb"

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
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "QPSK/MasterBox":
        Keystroke3()
        Sleep 100
        Keystroke3()
        ControlSend  "{C}", , "tkToolUtility.exe"
        ControlSend  "{O}", , "tkToolUtility.exe"
        ControlSend  "{M}", , "tkToolUtility.exe"
        ControlSend  TCCOMPort.Value ,, "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 200
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100 
        ControlSend "{N}",, "tkToolUtility.exe"
        Sleep 100
        ControlSend  "{Enter}", , "tkToolUtility.exe"
        case "OFDM":
            Keystroke3()
    }
}

AccessTC(*){
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
            ControlSend  "{C}", , "tkToolUtility.exe"
            ControlSend  "{O}", , "tkToolUtility.exe"
            ControlSend  "{M}", , "tkToolUtility.exe"
            ControlSend  TCCOMPort.Value ,, "tkToolUtility.exe"
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
    ControlSend  "{1}", , "tkToolUtility.exe"
    ControlSend "{Enter}", , "tkToolUtility.exe"
    Sleep 300
    ControlSend  "{y}", , "tkToolUtility.exe"
}