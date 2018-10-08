;==================================================================================
;=
;= Project Name: NSIS_DotNetVersion
;= 
;= File Name: DotNetVersion.nsh
;= File Version: 1.0 Beta
;= 
;= Descritoin: NSIS Library used to detect that a compatibility .Net Framework 
;=  version is installed on the system at installation time. Best usage is to
;=  include the required framework version and install it if the check returns 
;=  false. Handles the hard version compatibility breaks between 1.0, 1.1-3.5, 4+.
;=
;==================================================================================
;= Copyright (C) 2018 Peter Varney - All Rights Reserved
;= You may use, distribute and modify this code under the
;= terms of the MIT license, 
;=
;= You should have received a copy of the MIT license with
;= this file. If not, visit : https://github.com/fatalwall/NSIS_DotNetVersion
;==================================================================================
;=
;= Usage:
;=   DotNetVersion OutVariable Major Minor Build
;= 
;=   OutVariable	Variable such as $0 that the resutl is returned in
;=   Major			Interger value which at this time should be between 1 and 4
;=   Minor			Interger value or wildcard *
;=   Build			Interger value or wildcard *
;= 
;= Example 1 - with fully defined minimum version:
;=   !include DotNetVersion.nsh
;=   DotNetVersion $0 '4' '6' '7'
;=   ${If} $0 == "FALSE"
;=     DetailPrint ".Net Framework 4.6.7 is not installed"
;=   ${Else}
;=     DetailPrint ".Net Framework 4.6.7 or greater already installed"
;=   ${EndIf}
;= 
;= Example 2 - with wildcard Minor and Build number:
;=   !include DotNetVersion.nsh
;=   DotNetVersion $0 '2' '*' '*'
;=   ${If} $0 == "FALSE"
;=     DetailPrint ".Net Framework 2.0 is not installed"
;=   ${Else}
;=     DetailPrint ".Net Framework 2.0 or greater already installed"
;=   ${EndIf}
;=
;==================================================================================


!ifndef DotNetVersion
!define DotNetVersion "!insertmacro DotNetVersion"
!include x64.nsh
!include Explode.nsh

Var PARAM_MAJOR
Var PARAM_MINOR
Var PARAM_BUILD

Var REGISTRY_Key
Var REGISTRY_Value
Var REGISTRY_BUILD
Var REGISTRY_MINOR
Var REGISTRY_MAJOR

Var BOOL_RETURN

!macro DotNetVersion Out Major Minor Build
  Push `${Major}`
  Push `${Minor}`
  Push `${Build}`
  !ifdef __UNINSTALL__
    Call un.DotNetVersion
  !else
    Call DotNetVersion
  !endif
  Pop `${OUT}`
!macroend

!macro Func_DotNetVersion un
  Function ${un}DotNetVersion
    ClearErrors
    Pop $PARAM_BUILD
    Pop $PARAM_MINOR
    Pop $PARAM_MAJOR

    ${If} ${RunningX64}
    SetRegView 64
    ${Else}
    SetRegView 32
    ${EndIf}

    StrCpy $0 0
    ${do}
      EnumRegKey $REGISTRY_Key HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP" $0
      StrCmp $REGISTRY_Key "" done ;Exit loop if empty
      StrCpy $1 $REGISTRY_Key 1 ;Get First character
      ${If} $1 == "v" ;If Key name start with a V continue processing
        ReadRegStr $REGISTRY_Value HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\$REGISTRY_Key" "Version"
        ${If} ${Errors}
          ClearErrors
          ReadRegStr $REGISTRY_Value HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\$REGISTRY_Key\Client" "Version"
        ${EndIf}
        ${If} ${Errors}
          ClearErrors
          ReadRegStr $REGISTRY_Value HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\$REGISTRY_Key\Full" "Version"
        ${EndIf}
        ${Explode} $1  "." "$REGISTRY_Value"
        Pop $REGISTRY_MAJOR
        Pop $REGISTRY_MINOR
        Pop $REGISTRY_BUILD
        ;Clear the stack if anything exta is in it
        ${do}
          Pop $1
          ${If} ${Errors}
            ClearErrors
            ${ExitDo}
          ${EndIf}
        ${loop}
		
		;Version 1.0 Check (Not Compatable with any other version)
		${If} $PARAM_MAJOR == 1
		${AndIf} PARAM_MINOR == 0
        ${AndIf} $REGISTRY_MAJOR >= 1
		${AndIf} $REGISTRY_MINOR >= 1
          StrCpy $BOOL_RETURN "FALSE"
          GoTo CheckNext
		${EndIf}

		;Version 1.1 to 3.5 Check (Not Compatable with 4+)
        ${If} $PARAM_MAJOR <= 3
        ${AndIf} $REGISTRY_MAJOR >= 4
          StrCpy $BOOL_RETURN "FALSE"
          GoTo CheckNext
		${EndIf}
		
		;Check Major Version for Match
        ${If} $PARAM_MAJOR == $REGISTRY_MAJOR
          ;Match
          StrCpy $BOOL_RETURN "TRUE"
        ${ElseIf} $PARAM_MAJOR < $REGISTRY_MAJOR
          ;Match
          StrCpy $BOOL_RETURN "TRUE"
          GoTo CheckNext
        ${Else}
          ;Not a Match
          StrCpy $BOOL_RETURN "FALSE"
          GoTo CheckNext
        ${EndIf}
        
        ;Check Minor Version for Match
        ${If} $PARAM_MINOR == '*'
        ${OrIf} $PARAM_MINOR == $REGISTRY_MINOR
          ;Match
          StrCpy $BOOL_RETURN "TRUE"
        ${ElseIf} $PARAM_MINOR < $REGISTRY_MINOR
          ;Newer Version
          StrCpy $BOOL_RETURN "TRUE"
          GoTo CheckNext
        ${Else}
          ;Not a Match
          StrCpy $BOOL_RETURN "FALSE"
          GoTo CheckNext
        ${EndIf}
        
        ;Check Build Version for Match
        ${If} $PARAM_BUILD == '*'
        ${OrIf} $PARAM_BUILD == $REGISTRY_BUILD
          ;Match
          StrCpy $STR_getUninstaller_RETURN_VAR "TRUE"
        ${ElseIf} $PARAM_BUILD < $REGISTRY_BUILD
          ;Newer Version
          StrCpy $BOOL_RETURN "TRUE"
          GoTo CheckNext
        ${Else}
          ;Not a Match
          StrCpy $BOOL_RETURN "FALSE"
        ${EndIf}
        
        CheckNext:
      ${EndIf}
      ${if} $BOOL_RETURN == "TRUE"
        ${ExitDo}
      ${EndIF}
      IntOp $0 $0 + 1 ;increment to next registry key
    ${loop}
	
    done: ;goto reference for use with StrCmp
    Push $BOOL_RETURN
  FunctionEnd
!macroend

!insertmacro Func_DotNetVersion ""
!insertmacro Func_DotNetVersion "un."

!endif