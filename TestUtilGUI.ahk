Run "tkToolUtility.exe"
Sleep 200
ControlSend  "{Enter}", , "tkToolUtility.exe"
SetWorkingDir(A_ScriptDir)


MyGui := Gui(, "TestUtil")



WinMove(0,0,,, "ahk_exe tkToolUtility.exe")


Tab := MyGui.add("Tab3",, ["Master Controller", "Solenoid", "TC"])
MyGui.add("Button", "default" ,"Master Controller").OnEvent("Click",ButtonClick)
Tab.UseTab("Solenoid")
MyGui.Add("Text",,"Press button for selecting Solenoid")
SolenoidButton := MyGui.Add("Button", ,"Solenoid", ).OnEvent("Click",enter,)
MyGui.Add("Text",,"Select Communication Choice")
ComChoice := MyGui.AddDropDownList("w50", ["PCAN","QPSK","OFDM", "ABORT"])
ComChoice.OnEvent("Change", SendKeystrokeFromListbox)
MyGui.Add("Edit", "W50")
MyGui.Add("UpDown") 
MyGui.Add("Text",, "Access Solenoid Board")
MyGui.Add("Button", "" ,"Access").OnEvent("Click", AccessSolenoid)
MyGui.Add("Text","", "Rescan Nodes If Necessecary")
MyGui.Add("Button",, "Ping").OnEvent("Click",PingNodes)
MyGui.Add("Text",, "Choose Solenoid Board")
SolenoidAccess := MyGui.AddDropDownList("W100", ["FlexDrive", "MotorPump", "CompactTracMP", "SJR", "PrimeStroker", "ShortStroker", "ShortStrokerV2", "Puncher"])
SolenoidAccess.OnEvent("Change", SolenoidIDs)
MyGui.Add("Text",, "Select Firmware Version")
MyGui.Add("Button",, "Browse").OnEvent("Click", OpenFiledialogSolenoid)
MyGui.Add("Text",, "Install Firmware to Solenoid")
MyGui.Add("Button",, "Install").OnEvent("Click",InstallFWSolenoid)
MyGui.Add("Text",, "Select Solenoid Usage")
SolenoidUse := MyGui.AddDropDownList("W100", ["FlexDrive", "MotorPump", "CompactTracMP", "SJR", "PrimeStroker", "ShortStroker", "ShortStrokerV2", "Puncher"])
SolenoidUse.OnEvent("Change",SolenoidUsage)
MyGui.Add("Text","ys+28", "Choose Sensor Type")
MyGui.Add("Button","ys", "SensorType")
MyGui.Add("Text","ys", "")
MyGui.Add("Text",,"Add Sensor values")
MyGui.Add("Text",, "Sensor Cm")
MyGui.Add("Text",, "Sensor Cb")
MyGui.Add("Text",, "Sensor Bm")
MyGui.Add("Text",, "Sensor Bb")
MyGui.Add("Text",, "Sensor Am")
MyGui.Add("Text",, "Sensor Ab")
MyGui.Add("Text","", " ")
MyGui.AddEdit("vblank ys+50")
MyGui.AddEdit("vSensorCm")
MyGui.AddEdit("vSensorCb")
MyGui.AddEdit("vSensorBm")
MyGui.AddEdit("vSensorBb")
MyGui.AddEdit("vSensorAm")
MyGui.AddEdit("vSensorAb")

MyGui.Show()


Sleep 200
TraySetIcon(,, true)
iconPath := A_ScriptDir . "\\icoFiles\\toolsICO.ico"
TraySetIcon "toolsICO.ico"
TraySetIcon "Shell32.dll", 174

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
        case "MotorPump":
        Keystroke1()
        Sleep 200
        ControlSend  "{n}", , "tkToolUtility.exe"
        case "CompactTracMP":
        Keystroke2()
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
        Keystroke6()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "ShortStrokerV2":
        Keystroke7()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
        case "Puncher":
        Keystroke8()
        Sleep 200
        ControlSend  "{y}", , "tkToolUtility.exe"
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
    Test()
    }
    

Test(*) {
    MsgBox "testing"
}

Keystroke1(*){
    ControlSend "{1}",, "tkToolUtility.exe"
    ControlSend  "{Enter}", , "tkToolUtility.exe"

}Keystroke2(*){
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

Hex0x1(*){
    ControlSend "{0}",, "tkToolUtility.exe"
    ControlSend "{x}",, "tkToolUtility.exe"
    ControlSend "{1}",, "tkToolUtility.exe"
}

