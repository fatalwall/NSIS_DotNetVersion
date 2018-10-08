# NSIS_DotNetVersion
NSIS Library used to detect that a compatible .Net Framework version is installed on the system at installation time. Best usage is to include the required framework version and install it if the check returns false. Handles the hard version compatibility breaks between 1.0, 1.1-3.5, 4+.

## Usage:
DotNetVersion OutVariable Major Minor Build

| Parameter    | Type            | Description                     |
| :---         |      :---:      | :---                            |
| OutVariable	 | bool            | return result (TRUE or FALSE)   |  
| Major			   | int             | numerical value between 1 and 4 |
| Minor			   | int or wildcard | numerical value or wildcard *   |
| Build			   | int or wildcard | numerical value or wildcard *   |
 
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
${Else}
  DetailPrint ".Net Framework 2.0 or greater already installed"
${EndIf}
```
