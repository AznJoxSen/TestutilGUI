Run "tkToolUtility.exe"
Sleep 200
ControlSend  "{Enter}", , "tkToolUtility.exe"
SetWorkingDir(A_ScriptDir)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon (iconPath)

MyGui := Gui(, "TestUtilityGUI")

MyGui.Setfont("s10")
;MyGui.BackColor := "184c9a"
WinMove(0,0,,, "ahk_exe tkToolUtility.exe")


Tab := MyGui.add("Tab3",, ["Master Controller", "Solenoid", "TC"])
MyGui.add("Button", "default" ,"Master Controller").OnEvent("Click", ButtonClick)
Tab.UseTab("Solenoid")
MyGui.Add("Text",,"Press button for selecting Solenoid")
SolenoidButton := MyGui.Add("Button", ,"Solenoid", ).OnEvent("Click", enter,)
MyGui.Add("Text",,"Select Communication Choice")
ComChoice := MyGui.AddDropDownList("w80", ["PCAN","QPSK","OFDM", "ABORT"])
ComChoice.OnEvent("Change", SendKeystrokeFromListbox)

MyGui.Add("Text",, "Access Solenoid Board")
MyGui.Add("Button", "" ,"Access").OnEvent("Click", AccessSolenoid)
MyGui.Add("Text",, "Select COM Port Number")
COMPort := MyGui.Add("Edit", "W70")
MyGui.Add("UpDown") 
MyGui.Add("Button",, "OK").OnEvent("Click", COMPortSelect)


MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Rescan").OnEvent("Click", PingNodes)
MyGui.Add("Text",, "Choose Solenoid Board")
SolenoidAccess := MyGui.AddDropDownList("W150", ["FlexDrive", "MotorPump", "CompactTracMP", "SJR", "PrimeStroker", "ShortStroker", "ShortStrokerV2", "Puncher"])
SolenoidAccess.OnEvent("Change", SolenoidIDs)
;CBS_DISABLENOSCROLL
MyGui.Add("Text",, "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogSolenoid)
MyGui.Add("Text",, "Install Firmware to Solenoid")
MyGui.Add("Button",, "Install").OnEvent("Click", InstallFWSolenoid)

MyGui.Add("Text","ys+30", "Change Solenoid Usage")
SolenoidUse := MyGui.AddDropDownList("W150", ["FlexDrive", "MotorPump", "CompactTracMP", "SJR", "PrimeStroker", "ShortStroker", "ShortStrokerV2", "Puncher"])
SolenoidUse.OnEvent("Change", SolenoidUsage)
MyGui.Add("Text","" , "Choose Sensor Type")
SensorType := MyGui.AddDropDownList("W150",["HallEffect", "QuadEncoder", "Mech", "Unknown"])
SensorType.OnEvent("Change", SensorTypeChange)

MyGui.Add("Text","" , "Update Sensor Data For:")
SolenoidSensors := MyGui.AddDropDownList("W150", ["Sensor1", "Sensor2", "Sensor3", "Sensor4", "Sensor5", "Sensor6 'Not in Use'", "Sensor7 'Not in Use'"])
SolenoidSensors.OnEvent("Change", SensorIDs)



MyGui.Add("Text","ys+60", "SensorLinear m")
MyGui.Add("Text",, "SensorLinear b")
MyGui.Add("Text",, "SensorQuadtratic Cb")
MyGui.Add("Text",, "SensorQuadtratic Cm")
MyGui.Add("Text",, "SensorQuadtratic Bb")
MyGui.Add("Text",, "SensorQuadtratic Bm")
MyGui.Add("Text",, "SensorQuadtratic Ab")
MyGui.Add("Text",, "SensorQuadtratic Am")
MyGui.Add("Text",, "Update Sensor Values")

MyGui.Add("Text","ys+30","Add Sensor values")
Sensorm := MyGui.Add("Edit")
Sensorb := MyGui.Add("Edit")
SensorCb := MyGui.Add("Edit")
SensorCm := MyGui.Add("Edit")
SensorBb := MyGui.Add("Edit")
SensorBm := MyGui.Add("Edit")
SensorAb := MyGui.Add("Edit")
SensorAm := MyGui.Add("Edit")
MyGui.Add("Button",, "Update").OnEvent("Click", UpdateSensorValues)


MyGui.Show()


Sleep 200
TraySetIcon(,, true)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon (iconPath)

SendKeystrokeFromListbox(*){
    SelectedOption := ComChoice.Text
    switch SelectedOption {
        case "PCAN":
            Keystroke1()
        case "QPSK":
            Keystroke2()
        case "OFDM":
            Keystroke3()
        Case "Abort":
            Keystroke4()
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
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "MotorPump":
        Keystroke3()
        Sleep 200
        ControlSend  "{n}", , "tkToolUtility.exe"
        case "CompactTracMP":
        Keystroke3()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "SJR":
        Keystroke4()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "PrimeStroker":
        Keystroke5()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStroker":
        Keystroke5()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStrokerV2":
        Keystroke5()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "Puncher":
        Keystroke6()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
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
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "MotorPump":
        Keystroke1()
        Sleep 200
        ControlSend  "{n}", , "tkToolUtility.exe"
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "CompactTracMP":
        Keystroke2()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "SJR":
        Keystroke4()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "PrimeStroker":
        Keystroke5()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStroker":
        Keystroke6()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStrokerV2":
        Keystroke7()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        Hex0xCB()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "Puncher":
        Keystroke8()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
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
        case "Mech":
            Keystroke1()
        case "HallEffect":
            Keystroke2()
        Case "QuadEncoder":
            Keystroke3()

}
}

SensorIDs(*){
    Hex0xFA()
    Sleep 200
    SelectedSensorIDs := SolenoidSensors.Text
    switch SelectedSensorIDs {
        case "Sensor1":
            Keystroke1()
            Sleep 100
            Keystroke1()
        case "Sensor2":
            Keystroke2()
            Sleep 100
            Keystroke1()
        case "Sensor3":
            Keystroke3()
            Sleep 100
            Keystroke1()
        Case "Sensor4":
            Keystroke4()
            Sleep 100
            Keystroke2()
        Case "Sensor5":
            Keystroke5()
            Sleep 100
            Keystroke2()
        Case "Sensor6":
            Keystroke6()
        Case "Sensor7":
            Keystroke7()

}
}

UpdateSensorValues(*){
    
    SelectedSensors := SolenoidSensors.Text
    switch SelectedSensors {
        case "Sensor1":
            ControlSend  Sensorm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  Sensorb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        case "Sensor2":
            ControlSend  Sensorm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  Sensorb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        case "Sensor3":
            ControlSend  Sensorm.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  Sensorb.Value ,, "tkToolUtility.exe"
            Sleep 100
            ControlSend  "{Enter}", , "tkToolUtility.exe"
            Sleep 300
            Hex0xCD()
            Sleep 100
            ControlSend  "{y}", , "tkToolUtility.exe"
        Case "Sensor4":
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
        Case "Sensor5":
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
        Case "Sensor6":
            MsgBox "Don't Use this DumbDumb"
        Case "Sensor7":
            MsgBox "Don't Use this DumbDumb"

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