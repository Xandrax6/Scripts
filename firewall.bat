REM==========================================================================
REM
REM NAME: firewall.bat
REM
REM AUTHOR: Matt Fuhrman
REM
REM DATE  : 9/19/2012
REM
REM COMMENT: Disables all current local firewall rules. Asks which ports you
REM	     want opened and in what direction. Then blocks all ports that
REM	     you did not open.
REM==========================================================================

@echo off

REM Asks what OS you are running to determin which type of blocking pattern can be used
set /p OS=What OS are you running this on(Vista, 7, 2008, 2008R2)?

REM Disables all current firewall rules
netsh advfirewall firewall set rule name=all new enable=no

REM Asks what ports you want opened
set /a count=0

@echo For this section enter the port number you want opened. You will be asked for a rule name use something like Service+Direction (ie: HTTPIn). Then enter the direction you want the port opened.

:loop
set /p Ports=Port(1-65535):
set /p Name=RuleName(Service+Direction):
set /p Direction=Direction(in/out):
netsh advfirewall firewall add rule name="%Name%" protocol=TCP dir=%Direction% localport=%Ports% remoteport=%Ports% action=allow
set /p Continue=Open another port(y/n)?:
if %continue% EQU y goto loop

REM Determies which blocking patter to run based on user input from earlier
if %OS% EQU 7 goto Win7/2008R2
if %OS% EQU 2008 goto WinVista/2008
if %OS% EQU Vista goto WinVista/2008
if %OS% EQU 2008R2 goto Win7/2008R2

REM Vista and 2008 blocking rules
:WinVista/2008
set "count=1"
set /a rule=0
@echo For this section you will need to enter the outbound port numbers that you opened in the section above. Please start with the lowest port first and work your way in ascending order to the highest port. If you have no more ports to enter please enter 65536 to finish the configuration.
:control
set /p stop=Enter port to stop at(1-65535 start at lowest port, enter 65536 when done):
:control1
set "count1=1"
set /a rule+=1
set /a diff=%stop%-%count%
if %diff% GTR 1000 (set /a stop1=%count%+1000) else (set /a stop1=%stop%)
:loop1
If %count1% EQU 1 (set "output=%count%") else (set "output=%output%,%count%")
set /a count+=1
set /a count1+=1
if %count% LSS %stop1% goto loop1
netsh advfirewall firewall add rule name="BlockLocalOut%rule%" protocol=TCP dir=out localport=%output% action=block

netsh advfirewall firewall add rule name="BlockRemoteOut%rule%" protocol=TCP dir=out remoteport=%output% action=block

set "output="
if %stop1% EQU %stop% (set /a count+=1)
if %count% LSS %stop% goto control1
if %count% LSS 65535 goto control

set "count=1"
set /a rule=0
@echo For this section you will need to enter the inbound port numbers that you opened in the section above. Please start with the lowest port first and work your way in ascending order to the highest port. If you have no more ports to enter please enter 65536 to finish the configuration.
:control2
set /p stop=Enter port to stop at(1-65535 start at lowest port, enter 65536 when done):
:control3
set "count1=1"
set /a rule+=1
set /a diff=%stop%-%count%
if %diff% GTR 1000 (set /a stop1=%count%+1000) else (set /a stop1=%stop%)
:loop2
If %count1% EQU 1 (set "output=%count%") else (set "output=%output%,%count%")
set /a count+=1
set /a count1+=1
if %count% LSS %stop1% goto loop2

netsh advfirewall firewall add rule name="BlockLocalIn%rule%" protocol=TCP dir=in localport=%output% action=block

netsh advfirewall firewall add rule name="BlockRemoteIn%rule%" protocol=TCP dir=in remoteport=%output% action=block

set "output="
if %stop1% EQU %stop% (set /a count+=1)
if %count% LSS %stop% goto control3
if %count% LSS 65535 goto control2

goto :end

REM Windows 7 and 2008 R2 blocking rules
:Win7/2008R2
@echo For this section enter the ranges of outbound ports that need to be blocked use a comma to seperate ranges (ie: 1-79,81-442,etc.).

set /p Ports=Ports(1-79,81-442,###-65535 to end):

netsh advfirewall firewall add rule name="BlockOut" protocol=TCP dir=out localport=%Ports% remoteport=%Ports% action=block

@echo For this section enter the ranges of inbound ports that need to be blocked use a comma to seperate ranges (ie: 1-79,81-442,etc.).

set /p Ports=Ports(1-79,81-442,###-65535 to end):

netsh advfirewall firewall add rule name="BlockIn" protocol=TCP dir=in localport=%Ports% remoteport=%Ports% action=block

:end
@echo Configuration Complete.
pause