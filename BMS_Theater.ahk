#SingleInstance force
;#Persistent
;
;Theater Picker by ZIPGUN  ©2017
;	v3	13 MAR 18			Added version to help
; Create the ListView with two columns, Name and Size:
START:
Gui, Add, Button, gHelp, Help
Gui, Add, Button, Default gCloser, Close
Gui, Add, ListView, r20 w700 gMyListView, Theater|Current
DEV	:= 0
empty := false
BMS_VER := "Falcon BMS 4.33 U1"

if (DEV ==1)
{
	BMS_VER := "Falcon BMS 4.34 (Internal)"
}
RegRead, BMS_DIR, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, baseDir	
RegRead, curTheater, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater
;curTheater := SubStr(curTheater, StrLen(curTheater))
dataF := BMS_DIR . "\Data\"
theater_lst_loc := BMS_DIR . "\Data\Terrdata\theaterdefinition\theater.lst"
theater_lst_dir := BMS_DIR . "\Data\Terrdata\theaterdefinition"
;			MsgBox, "TBase: " %BMS_DIR%
;			MsgBox, "Theater file: " %theater_lst_loc%
;			MsgBox, "Theater file: " %dataF%
ao := "Add-On "						; pattern for the check
terr := "Terrdata"

;Loop
Loop, read, %theater_lst_loc%
{
	If A_LoopReadLine=
	{
		empty := true
	}else{
	
;    FileReadLine, line, %theater_lst_loc%, %A_Index%
;	    if ErrorLevel
;        break	
		fChar := SubStr(A_LoopReadLine, 1, 1)
		If (fChar != "#")
		{
			tdf := dataF . A_LoopReadLine
			Loop
			{
				FileReadLine, line2, %tdf%, %A_Index%
;				MsgBox, "read: " %line2%	
				line2 := RTrim(line2)		
				if (SubStr(line2, 1, 5) == "name ")
				{
					if(SubStr(line2, 6) == curTheater)
					{
						curIndex := A_Index
						LV_Add("", SubStr(line2, 6), "CURRENT")
					}else{
					LV_Add("", SubStr(line2, 6), "")
					}
					break
				}
			}								; inner loop end -- read for name in TDF file

		}									; not a # end
	}										; not empty line end		

}												; read loop end
If (empty)
{
	MsgBox, 4,, Empty lines found in Theater List`r`n   -- I can create a backup and remove blank lines`r`n`r`n CONTINUE?`r`n 
	IfMsgBox Yes
	{
		FileCopy, %theater_lst_loc%, %theater_lst_dir%\theater.bak, 1
		fWork=%theater_lst_dir%\theater.wrk
			ifexist,%fWork%
			filedelete,%fWork%
		Loop, read, %theater_lst_loc%
		{
			If A_LoopReadLine=
			{
				
			}else{
				if(A_Index == 1)
				{
					fileappend, %A_LoopReadLine%, %fWork%
				}else{
					fileappend, `n%A_LoopReadLine%, %fWork%
				}
;				MsgBox, %A_Index%
			}
		}
		FileCopy, %fWork%, %theater_lst_dir%\theater.lst, 1
		MsgBox Theater List Updated -- Old Version Saved to:`r`n`r %theater_lst_dir%\theater.bak
		Gui Destroy
		goto START
	}else{
		MsgBox Program will exit, please edit your list located at:`r`n`r%theater_lst_loc%
		ExitApp
	}
}

LV_ModifyCol()  ; Auto-size each column to fit its contents.
Gui, Show

return

MyListView:
if A_GuiEvent = DoubleClick
{
    LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
;    ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"
    MsgBox, 4, , Set curTheater to %RowText%".  Continue?
	   IfMsgBox, No
	   return
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater, %RowText%
}
		Gui Destroy
		goto START
return
Help:
	msgbox "BMS Theater Changer v.3 (13 MAR 18)`r`n`nDouble Click Theater Name to Change Theaters
Closer:
GuiClose:  ; When the window is closed, exit the script automatically:
ExitApp
