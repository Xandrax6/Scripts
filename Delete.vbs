'==========================================================================
'
' NAME: delete.vbs
'
' AUTHOR: Matt Fuhrman
'
' DATE  : 9/04/2012
'
' COMMENT: Recieves the password creation script name and password filename
'	   and deletes those files, clears the recycle bin, and reboots
'	   the computer.
'==========================================================================

'Gets filename of password script for deletion
strFile = Replace(WScript.ScriptFullName, WScript.ScriptName, Wscript.Arguments.Item(0))
set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.DeleteFile strFile

'Gets filename of password file for deletion
strFile = Replace(WScript.ScriptFullName, WScript.ScriptName, Wscript.Arguments.Item(1))
set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.DeleteFile strFile

'Clears the recycle bin
Const RECYCLE_BIN = &Ha&
Const FILE_SIZE = 3
Dim objShell, objFolder, objFSO, colItems
Set objShell = CreateObject("Shell.Application")
Set objFolder = objShell.Namespace(RECYCLE_BIN)
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set colItems = objFolder.Items
For Each objItem in colItems
    If (objItem.Type = "File folder") Then
        objFSO.DeleteFolder(objItem.Path)
     Else
        objFSO.DeleteFile(objItem.Path)
    End If
Next

'Reboots the computer to ensure deleted files can't be recovered easily
MsgBox ("Click OK to reboot computer. Once rebooted delete the delete.vbs file and clear the recycle bin manually")
Set objShell = WScript.CreateObject("WScript.Shell")
objShell.Run "C:\WINDOWS\system32\shutdown.exe -r -t 0"