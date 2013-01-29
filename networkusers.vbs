'==========================================================================
'
' NAME: networkusers.vbs
'
' AUTHOR: Matt Fuhrman
'
' DATE  : 8/24/2012
'
' COMMENT: Finds all AD user accounts, generates random passwords 
'	   meeting complexity requirements, changes each users password,
'	   and then prints a password list to the default printer.
'          By default will generate a 15 digit password.
'==========================================================================

Dim uName(100)

'Domain Name change this to match the domain you are running this for
dName = "ccdcitt.local"

'Change this to set password length
passLen = 15

i = 0

'Retrieves all usernames from the domain
Set objDomain = GetObject("WinNT://" & dName & ",domain")
objDomain.Filter = Array("User")

'Sets password filename to the domain name for easy tracking purposes
filename = dName & "-PWLIST.txt"

'Goes through each user found on the domain
For Each objUser In objDomain
	'Saves the user name to an array used in the password list file
	uName(i) = objUser.Name

	'Generates a new random complex password
	newpass = generatePassword(passLen)

	'Sets the newly generated password for the user
	objuser.SetPassword newpass
	objuser.SetInfo

	'Creates information used for the password list file
	passlist = passlist & vbCrLf
	passlist = passlist & "User Name: " & uName(i) & vbCrLf
	passlist = passlist & "Password: " & newpass & vbCrLf
	
	i = i+1
Next

'Creates the password list file
Set fso = CreateObject("Scripting.FileSystemObject")
Set ts = fso.CreateTextFile (filename, true)
ts.write passlist

'Prints the password list file to the default printer
PrintFile(filename)

'Calls the delete script and passes this script name and the password filename to it for deletion, recycle bin clearing, and rebooting.
scrName = WScript.ScriptName
set objshell = WScript.CreateObject("WScript.Shell")
objShell.Run "Delete.vbs " & scrName & " " & filename

'Function to generate the random complex password
Function generatePassword(PASSWORD_LENGTH)

Dim NUMLOWER, NUMUPPER, LOWERBOUND, UPPERBOUND, LOWERBOUND1, UPPERBOUND1, SYMLOWER, SYMUPPER
Dim newPassword, count, pwd 
Dim pCheckComplex, pCheckComplexUp, pCheckComplexLow, pCheckComplexNum, pCheckComplexSym, pCheckAnswer


 NUMLOWER    = 48  ' 48 = 0
 NUMUPPER    = 57  ' 57 = 9
 LOWERBOUND  = 65  ' 65 = A
 UPPERBOUND  = 90  ' 90 = Z
 LOWERBOUND1 = 97  ' 97 = a
 UPPERBOUND1 = 122 ' 122 = z
 SYMLOWER    = 33  ' 33 = !
 SYMUPPER    = 46  ' 46 = .
 pCheckComplexUp  = 0 ' used later to check number of character types in password
 pCheckComplexLow = 0 ' used later to check number of character types in password
 pCheckComplexNum = 0 ' used later to check number of character types in password
 pCheckComplexSym = 0 ' used later to check number of character types in password
 
 
 ' initialize the random number generator
 Randomize()

 newPassword = ""
 count = 0
 DO UNTIL count = PASSWORD_LENGTH
   ' generate a num between 2 and 10 
  
 ' if num <= 2 create a symbol 
   If Int( ( 10 - 2 + 1 ) * Rnd + 2 ) <= 2 Then
    pwd = Int( ( SYMUPPER - SYMLOWER + 1 ) * Rnd + SYMLOWER )

   ' if num is between 3 and 5 create a lowercase
   Elseif Int( ( 10 - 2 + 1 ) * Rnd + 2 ) > 2 And  Int( ( 10 - 2 + 1 ) * Rnd + 2 ) <= 5 Then
    pwd = Int( ( UPPERBOUND1 - LOWERBOUND1 + 1 ) * Rnd + LOWERBOUND1 )

    ' if num is 6 or 7 generate an uppercase
   Elseif Int( ( 10 - 2 + 1 ) * Rnd + 2 ) > 5 And  Int( ( 10 - 2 + 1 ) * Rnd + 2 ) <= 7 Then
    pwd = Int( ( UPPERBOUND - LOWERBOUND + 1 ) * Rnd + LOWERBOUND ) 

   Else
       pwd = Int( ( NUMUPPER - NUMLOWER + 1 ) * Rnd + NUMLOWER )
   End If

  newPassword = newPassword + Chr( pwd )
  
  count = count + 1
  
  'Check to make sure that a proper mix of characters has been created.  If not discard the password.
  If count = (PASSWORD_LENGTH) Then
      For pCheckComplex = 1 To PASSWORD_LENGTH
          'Check for uppercase
          If Asc(Mid(newPassword,pCheckComplex,1)) >64 And Asc(Mid(newPassword,pCheckComplex,1))< 90 Then
                  pCheckComplexUp = 1 
          'Check for lowercase
          ElseIf Asc(Mid(newPassword,pCheckComplex,1)) >96 And Asc(Mid(newPassword,pCheckComplex,1))< 123 Then
                  pCheckComplexLow = 1 
          'Check for numbers
          ElseIf Asc(Mid(newPassword,pCheckComplex,1)) >47 And Asc(Mid(newPassword,pCheckComplex,1))< 58 Then
                  pCheckComplexNum = 1
          'Check for symbols
          ElseIf Asc(Mid(newPassword,pCheckComplex,1)) >32 And Asc(Mid(newPassword,pCheckComplex,1))< 47 Then
                  pCheckComplexSym = 1
          End If
      Next
      
      'Add up the number of character sets.  We require 3 or 4 for a complex password.
      pCheckAnswer = pCheckComplexUp+pCheckComplexLow+pCheckComplexNum+pCheckComplexSym
            
      If pCheckAnswer < 3 Then
          newPassword = ""
          count = 0
      End If
  End If
 Loop
'The password is good so return it
 generatePassword = newPassword

End Function 

'Function to print the password file to the default printer
Function PrintFile(fName)

'Gets folder name of the file location for enumerating
folderName = Replace(WScript.ScriptFullName, "\" & WScript.ScriptName, "")
TargetFolder = foldername
Set objShell = CreateObject("Shell.Application")
Set objFolder = objShell.Namespace(TargetFolder)
set collitems = objFolder.Items

'Creates the filename minus the extension for newer systems where extensions are hidden
NoExtName = Replace(fName, ".txt", "")

'Goes through each item in the target folder until the password file is found and invokes the right click print option
For Each objitem in collitems
	If objitem.Name = fName Then
		objitem.InvokeVerbEx("Print")
	ElseIf objitem.Name = NoExtName Then
		objitem.InvokeVerbEx("Print")
	End If
Next

End Function