'==========================================================================
'
' NAME: netstat.vbs
'
' AUTHOR: Matt Fuhrman
'
' DATE  : 9/20/2012
'
' COMMENT: First run will create a base netstat text file to compare with
'	   later runs. All additional runs will create a new netstat file
'	   compare it to the base file and show any additions. Will create
'	   a text file with the differences.
'==========================================================================

fileName = Replace(WScript.ScriptFullName, WScript.ScriptName, "netstat.txt")
filename1 = Replace(WScript.ScriptFullName, WScript.ScriptName, "netstat1.txt")
filename2 = Replace(WScript.ScriptFullName, WScript.ScriptName, "netstatDifferences.txt")
folder = Replace(WScript.ScriptFullName, WScript.ScriptName, "")

Set fso = CreateObject("Scripting.FileSystemObject")

'Checks to see if the netstat.txt file already exists
If (fso.FileExists(fileName)) Then

	'Deletes the secondary files for comparison if they exist
	if (fso.FileExists(filename1)) Then
		fso.DeleteFile filename1
		fso.DeleteFile filename2
		call GetConnections1()
	Else
		call GetConnections1()
	End If

	'Reads the data from the text files and compares them to create the difference file
	Const ForReading = 1

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile1 = objFSO.OpenTextFile(fileName, ForReading)

	strCurrentStat = objFile1.ReadAll
	objFile1.Close

	Set objFile2 = objFSO.OpenTextFile(filename1, ForReading)

	Do Until objFile2.AtEndOfStream
    		strNewStat = objFile2.ReadLine
    		If InStr(strCurrentStat, strNewStat) = 0 Then
        		strNotCurrent = strNotCurrent & strNewStat & vbCrLf
    		End If
	Loop

	objFile2.Close

	msgbox("New stat since last scan: " & vbCrLf & strNotCurrent)

	Set objFile3 = objFSO.CreateTextFile(folder & "netstatDifferences.txt")

	objFile3.WriteLine strNotCurrent
	objFile3.Close

Else
	call GetConnections()
End If

'Creates the base netstat file
Function GetConnections()
  set sh = CreateObject("Wscript.Shell")
  i = 0  
  set shExec = sh.Exec("netstat -aon")
   	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.CreateTextFile ("netstat.txt", ForWriting)
   Do While Not shExec.StdOut.AtEndOfStream
     	statlist = shExec.StdOut.ReadLine()
	ts.WriteLine(statlist)
  Loop
End Function

'Creates the comparison netstat file
Function GetConnections1()
  set sh = CreateObject("Wscript.Shell") 
  i = 0  
  set shExec = sh.Exec("netstat -aon")
   	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.CreateTextFile ("netstat1.txt", ForWriting)
   Do While Not shExec.StdOut.AtEndOfStream
     	statlist = shExec.StdOut.ReadLine()
	ts.WriteLine(statlist)
  Loop
End Function