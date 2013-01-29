'==========================================================================
'
' NAME: users.vbs
'
' AUTHOR: Matt Fuhrman
'
' DATE  : 9/19/2012
'
' COMMENT: First run will create a text file with all user names to be used
'	   for later runs. All additional runs will create a new user file
'	   compare it to the base file and show any additions. Will create
'	   a text file with the differences.
'==========================================================================

Dim uName(100)

'Retrieves usernames from the local computer
Set objNetwork = CreateObject("Wscript.Network")
strComputer = objNetwork.ComputerName
Set colAccounts = GetObject("WinNT://" & strComputer & "")
colAccounts.Filter = Array("user")

For Each objUser In colAccounts
uName(i) = objUser.Name
namelist = namelist & uName(i) & vbCrLf
next

msgbox(namelist)


fileName = Replace(WScript.ScriptFullName, WScript.ScriptName, "Users.txt")
filename1 = Replace(WScript.ScriptFullName, WScript.ScriptName, "Users1.txt")
filename2 = Replace(WScript.ScriptFullName, WScript.ScriptName, "UserDifferences.txt")
folder = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
Set fso = CreateObject("Scripting.FileSystemObject")
If (fso.FileExists(fileName)) Then
   	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.CreateTextFile ("Users1.txt", ForWriting)
	ts.write namelist

Const ForReading = 1

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile1 = objFSO.OpenTextFile(filename, ForReading)

strCurrentUsers = objFile1.ReadAll
objFile1.Close

Set objFile2 = objFSO.OpenTextFile(filename1, ForReading)

Do Until objFile2.AtEndOfStream
    strNewUsers = objFile2.ReadLine
    If InStr(strCurrentUsers, strNewUsers) = 0 Then
        strNotCurrent = strNotCurrent & strNewUsers & vbCrLf
    End If
Loop

objFile2.Close

msgbox("New Users since last scan: " & vbCrLf & strNotCurrent)

Set objFile3 = objFSO.CreateTextFile(folder & "UserDifferences.txt")

objFile3.WriteLine strNotCurrent
objFile3.Close

Set objFile3 = objFSO.OpenTextFile(filename2, ForReading)
     Do Until objFile3.AtEndofStream
	  strComputer = "."
          strDelUsers = objFile3.Readline
	  If strDelUsers = "" Then
	  Else
	       Set objComputer = GetObject("WinNT://" & strComputer & "")
	       objComputer.Delete "user", strDelUsers
	  End If
     Loop

Else
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.CreateTextFile ("Users.txt", ForWriting)
	ts.write namelist
End If