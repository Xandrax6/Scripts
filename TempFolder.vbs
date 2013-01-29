'==========================================================================
'
' NAME: TempFolder.vbs
'
' AUTHOR: Matt Fuhrman
'
' DATE  : 10/23/2012
'
' COMMENT: Deletes all files and folders in the windows temp directory.
'==========================================================================

'Sets the path of the windows Temp directory
set shell = CreateObject("WScript.Shell")
strPath = shell.ExpandEnvironmentStrings("%WinDir%")
strPath2 = strPath & "\Temp\"

'Deletes everything in it if it exists
Set fso = CreateObject("Scripting.FileSystemObject")
If fso.FolderExists(strPath2) Then
    fso.DeleteFile strPath2 & "*.*"
    fso.DeleteFolder strpath2 & "*.*"
End If