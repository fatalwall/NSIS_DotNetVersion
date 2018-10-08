# NSIS DotNetVersion
NSIS Library used to detect that a compatible .Net Framework version is installed on the system at installation time. Best usage is to include the required framework version and install it if the check returns false. Handles the hard version compatibility breaks between 1.0, 1.1-3.5, 4+.

For more information on NSIS please see http://nsis.sourceforge.net

## Expected Warnings
The following warning may be thrown by the NSIS compiler and can be ignored
```
Warning 1  FIXME
```
```
Warning 2 un.  FIXME
```

## Dependancies
String Explode Function - Library has not been posted yet. This will be updated once project is posted

## Usage:
DotNetVersion OutVariable Major Minor Build

| Parameter    | Type            | Description                     |
| :---         |      :---:      | :---                            |
| OutVariable	 | bool            | return result (TRUE or FALSE)   |  
| Major			     | int             | numerical value between 1 and 4 |
| Minor			     | int or wildcard | numerical value or wildcard *   |
| Build			     | int or wildcard | numerical value or wildcard *   |
 
### Example 1 - with fully defined minimum version:
```NSIS
!include DotNetVersion.nsh
DotNetVersion $0 '4' '6' '7'
${If} $0 == "FALSE"
  DetailPrint ".Net Framework 4.6.7 is not installed"
${Else}
  DetailPrint ".Net Framework 4.6.7 or greater already installed"
${EndIf}
```
 
### Example 2 - with wildcard Minor and Build number:
```NSIS
!include DotNetVersion.nsh
DotNetVersion $0 '2' '*' '*'
${If} $0 == "FALSE"
  DetailPrint ".Net Framework 2.0 is not installed"
  File "/oname=dotNetFx40_Full_x86_x64.exe" "..\Dependencies\dotNetFx40_Full_x86_x64.exe"
  DetailPrint "Installing .Net Framework 4.0 (Installation will take several minutes)"
  nsExec::Exec '"$INSTDIR\dotNetFx40_Full_x86_x64.exe" /q /norestart'
${Else}
  DetailPrint ".Net Framework 2.0 or greater already installed"
${EndIf}
```
