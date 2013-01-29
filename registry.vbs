'============================================================================
'
' NAME: registry.vbs
'
' AUTHOR: Matt Fuhrman
'
' DATE  : 11/02/2012
'
' COMMENT: First run will create a text file with all registry entries to 
'	   be used for later runs. All additional runs will create a new 
'	   registry file compare it to the base file and show any additions.
'	   Will create a text file with the differences.
'============================================================================

' Constants (taken from WinReg.h)
'
Const HKEY_CLASSES_ROOT   = &H80000000
Const HKEY_CURRENT_USER   = &H80000001
Const HKEY_LOCAL_MACHINE  = &H80000002
Const HKEY_USERS          = &H80000003

Const REG_SZ        = 1
Const REG_EXPAND_SZ = 2
Const REG_BINARY    = 3
Const REG_DWORD     = 4
Const REG_MULTI_SZ  = 7

Const ForReading = 1

fileName = Replace(WScript.ScriptFullName, WScript.ScriptName, "Registry.txt")
filename1 = Replace(WScript.ScriptFullName, WScript.ScriptName, "Registry1.txt")
filename2 = Replace(WScript.ScriptFullName, WScript.ScriptName, "RegistryDifferences.txt")
folder = Replace(WScript.ScriptFullName, WScript.ScriptName, "")

' Chose computer name, registry tree and key path
'
strComputer = "."
hDefKey = HKEY_LOCAL_MACHINE
strKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

' Connect to registry provider on target machine with current user
'
Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

' Show its value names and types
'
strSubKeyPath = strKeyPath
oReg.EnumValues hDefKey, strSubKeyPath, arrValueNames, arrTypes

For i = LBound(arrValueNames) To UBound(arrValueNames)
  strValueName = arrValueNames(i)
  Select Case arrTypes(i)

    ' Show a REG_SZ value
    '
    Case REG_SZ          
      oReg.GetStringValue hDefKey, strSubKeyPath, strValueName, strValue
      reglist = reglist & "  " & strValueName & " (REG_SZ) = " & strValue & vbCrLf

    ' Show a REG_EXPAND_SZ value
    '
    Case REG_EXPAND_SZ
      oReg.GetExpandedStringValue hDefKey, strSubKeyPath, strValueName, strValue
      reglist = reglist & "  " & strValueName & " (REG_EXPAND_SZ) = " & strValue & VbCrLf

    ' Show a REG_BINARY value
    '          
    Case REG_BINARY
      oReg.GetBinaryValue hDefKey, strSubKeyPath, strValueName, arrBytes
      strBytes = ""
      For Each uByte in arrBytes
        strBytes = strBytes & Hex(uByte) & " "
      Next
      reglist = reglist & "  " & strValueName & " (REG_BINARY) = " & strBytes & VbCrLf

    ' Show a REG_DWORD value
    '
    Case REG_DWORD
      oReg.GetDWORDValue hDefKey, strSubKeyPath, strValueName, uValue
      reglist = reglist & "  " & strValueName & " (REG_DWORD) = " & CStr(uValue) & VbCrLf				

    ' Show a REG_MULTI_SZ value
    '
    Case REG_MULTI_SZ
      oReg.GetMultiStringValue hDefKey, strSubKeyPath, strValueName, arrValues				  				
      reglist = reglist & "  " & strValueName & " (REG_MULTI_SZ) ="
      For Each strValue in arrValues
        reglist = reglist & "    " & strValue & VbCrLf
      Next

  End Select
Next

'Checks if text file exsists and creates it if not or creates a second one and compares it
'
Set fso = CreateObject("Scripting.FileSystemObject")
If (fso.FileExists(fileName)) Then
   	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.CreateTextFile ("Registry1.txt", ForWriting)
	ts.write reglist

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile1 = objFSO.OpenTextFile(filename, ForReading)

	strCurrentReg = objFile1.ReadAll
	objFile1.Close

	Set objFile2 = objFSO.OpenTextFile(filename1, ForReading)

	Do Until objFile2.AtEndOfStream
    		strNewReg = objFile2.ReadLine
    		If InStr(strCurrentReg, strNewReg) = 0 Then
        		strNotCurrent = strNotCurrent & strNewReg & vbCrLf
    		End If
	Loop

	objFile2.Close

	msgbox("New Registry entires since last scan: " & vbCrLf & strNotCurrent)

	Set objFile3 = objFSO.CreateTextFile(folder & "RegistryDifferences.txt")

	objFile3.WriteLine strNotCurrent
	objFile3.Close
Else
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.CreateTextFile ("Registry.txt", ForWriting)
	ts.write reglist
End If