
#SingleInstance force
#MaxMem 556  ; Allow 256 MB per variable
Desktop_Location=C:\Users\Will\Desktop
Audio_Lang=en
SETTINGS_FILE=%A_ScriptDir%\Latin-Based_MCD_Maker_Settings.Ini 

  IniRead, TextTitle, %SETTINGS_FILE%, Title, TextTitle,  %A_Space%
  IniRead, File1, %SETTINGS_FILE%, files, file1,  %A_Space%
  IniRead, File2, %SETTINGS_FILE%, files, file2,  %A_Space%
  IniRead, File3, %SETTINGS_FILE%, files, file3,  %A_Space%
 
  Gui, 3:Destroy
  Gui, 3:Add, GroupBox, x20 y5 w605 h200,
  Gui, 3:Add, Text, xp+5 yp+10  ,Title
  Gui, 3:Add, Edit, xp+35 r1 w250 vTextTitle gGetTitle, %TextTitle%
  Gui, 3:Add, Text, xp-35 yp+25  ,Novel
  Gui, 3:Add, Edit, xp+35 r1 w500 ReadOnly vFile1, %File1%
  Gui, 3:Add, Button, xp+500 yp-1 r1 w60 gGetFile1,  Browse
  Gui, 3:Add, Text, xp-535 yp+25 ,Terms
  Gui, 3:Add, Edit, xp+35 r1 w500 ReadOnly vFile2, %File2%
  Gui, 3:Add, Button, xp+500 yp-1 r1 w60 gGetFile2,  Browse
  Gui, 3:Add, Text, xp-535 yp+25 ,Dict.
  Gui, 3:Add, Edit, xp+35 r1 w500 ReadOnly vFile3, %File3%
  Gui, 3:Add, Button, xp+500 yp-1 r1 w60 gGetFile3,  Browse
  Gui, 3:Add, Button, yp+25  r1 w60 gCompareTexts,  Compare
  Gui, 3:show
Return




CompareTexts:
CreateDictionaries()
return


GetTitle:
GuiControlGet, TextTitle
;msgbox, %optTextTitle%
IniWrite, "%TextTitle%", %SETTINGS_FILE%, Title, TextTitle
Gui, Submit, NoHide
Return


GetFile1:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectfile, File1, , 3
    IniWrite, "%File1%", %SETTINGS_FILE%, files, File1
	    GuiControl,, File1, %File1%
	Gui, Submit, NoHide
return

GetFile2:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectfile, File2, , 3
    IniWrite, "%File2%", %SETTINGS_FILE%, files, File2
	GuiControl,, File2, %File2%
	Gui, Submit, NoHide
return

GetFile3:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectfile, File3, , 3
    IniWrite, "%File3%", %SETTINGS_FILE%, files, File3
	GuiControl,, File3, %File3%
	Gui, Submit, NoHide
return


CreateDictionaries()
{
Global
  Gui, 3:Add, Progress, xp-500 yp+25 w300 h20 Range0-50000  -Smooth vMyProgress
  Gui, 3:Add, Text, xp+320 w300 vCurrentTask
OutFile = %A_ScriptDir%\Leydana_MCD_Vocab1.txt
FileDelete, %OutFile%
FileDelete, %Desktop_Location%\Freq_STATS\Freq_Unique_list.txt
FileDelete, %Desktop_Location%\Freq_STATS\Freq_Redundant_list.txt
FileDelete, %A_ScriptDir%\UndefinedTermsintheCorpus.txt


GuiControl,3:, currenttask, Parsing Source Text
Fileread, NovelText,%File1%
;StringReplace, NovelText, NovelText,`n`n,`n,,all
;StringReplace, NovelText, NovelText,`n`n,`n,,all
;StringReplace, NovelText, NovelText,`n`n,`n,,all
;StringReplace, NovelText, NovelText,`n`n,`n,,all
;StringReplace, NovelText, NovelText,`n`n,`n,,all
;StringReplace, NovelText, NovelText,`n,,,all
StringReplace, NovelText, NovelText,`a,,,all
StringReplace, NovelText, NovelText,Mr`.,Mr,,all
StringReplace, NovelText, NovelText,Mrs`.,Mrs,,all
StringReplace, NovelText, NovelText,`.,%A_Space%`.%A_Space%,,all
StringReplace, NovelText, NovelText,`,,%A_Space%`,%A_Space%,,all
StringReplace, NovelText, NovelText,`;,%A_Space%`;%A_Space%,,all
StringReplace, NovelText, NovelText,`:,%A_Space%`:%A_Space%,,all
StringReplace, NovelText, NovelText,`?,%A_Space%`?%A_Space%,,all
StringReplace, NovelText, NovelText,`!,%A_Space%`!%A_Space%,,all
StringReplace, NovelText, NovelText,`.`.`.,%A_Space%`,`,`,%A_Space%,,all
StringReplace, NovelText, NovelText,`(,%A_Space%`(%A_Space%,,all
StringReplace, NovelText, NovelText,`),%A_Space%`)%A_Space%,,all
StringReplace, NovelText, NovelText,`",%A_Space%`"%A_Space%,,all
NovelText := RegExReplace( NovelText, "[”“%1234567890«»<>:]", "")
;msgbox, %NovelText%
;msgbox,%NovelText%
GuiControl,3:, MyProgress, +50000 


sleep 1000
GuiControl,3:, MyProgress, -50000  
GuiControl,3:, currenttask, Loading Terms
;create Dictionary for Freq terms
Freq_Array := []
Loop, Read, %File2%
{
 Loop, parse, A_LoopReadLine, %A_Tab%
    {
	
	if A_Index=1
	{
	Field_Term=%A_LoopField%
	
		 Value := Freq_Array[Field_Term]
		 
		 If Value =
		 {
			 Freq_Array[Field_Term] :=Field_Term
			 Freq_Unique_list=%Freq_Unique_list%%Field_Term%`n
			 Freq_Unique_Counter++
			}
		Else
		{
			Freq_Redundant_list=%Freq_Redundant_list%%Field_Term%`n
			Freq_Redundant_Counter++
			}
		 }
    }
}
fileappend, %Freq_Unique_list%`n ,%Desktop_Location%\Freq_STATS\Freq_Unique_list.txt,UTF-8
fileappend, %Freq_Redundant_list%`n ,%Desktop_Location%\Freq_STATS\Freq_Redundant_list.txt,UTF-8
GuiControl,3:, MyProgress, +50000  


sleep 1000
GuiControl,3:, MyProgress, -50000 
GuiControl,3:, currenttask, Loading Dictionary
;create dictionary for Japanese Corpus
Corpus_Array := []
Loop, Read, %file3%
{
 Loop, parse, A_LoopReadLine, %A_Tab%
    {
	
	if A_Index=1
	{
	Field_Term=%A_LoopField%
	}
	if A_Index=2
	{
	Field_Translation=%A_LoopField%
	
		 Value := Corpus_Array[Field_Term]
		 
		 If Value =
		 {
			 Corpus_Array[Field_Term] := Field_Term A_Tab Field_Translation
			 Corpus_Unique_list=%Corpus_Unique_list%%Field_Term%%A_Tab%%Field_Translation%`n
			 Corpus_Unique_counter++
			 
			}
		Else
			{
			Corpus_Redundant_list=%Corpus_Redundant_list%%Field_Term%%A_Tab%%Field_Translation%`n
			Corpus_Redundant_counter++
			}
    }
	}
} 
GuiControl,3:, MyProgress, +50000  


sleep 1000
GuiControl,3:, MyProgress, -50000 
GuiControl,3:, currenttask, Writing cards to TSV File
IncreaseProgresBy :=50000/Freq_Unique_Counter
; Create cards=============================================================================================================================================================
Loop, parse, Freq_Unique_list,`n
{
;MsgBox A_index: %A_index%
;If A_index=%Progress_increase_condition_value%
;{
;;MsgBox hey 
GuiControl,3:, MyProgress, +%IncreaseProgresBy%  
;Progress_increase_condition_value := Progress_increase_condition_value + Progress_increase_condition_value
;}
Haystack=%NovelText%
	Loop, parse, A_LoopField, %A_Tab%
	{
	;msgbox, %A_LoopField%
	if A_Index=1
	{
	Field_Term=%A_LoopField%
	
	Language_Pair := Corpus_Array[Field_Term]
	if Language_Pair=
		{
		fileappend, %Field_Term%`n ,%A_ScriptDir%\UndefinedTermsintheCorpus.txt,UTF-8
		goto, endloop
		}
	loop, Parse, Language_Pair, %A_Tab%
	{
		if A_Index=2
		{
		Field_Translation=%A_LoopField%
		}
		
	}
	;MsgBox, Field_Term%Field_Term%`n Field_Translation: %Field_Translation%

;StringReplace, Haystack, Haystack,%Field_Term%,`.,%A_Space%`.,all ;get rid of the ends of words touching the beginning of "."
;cloze all occurrences of TERM----------------------------------------------------------------
IfInString, Haystack, %A_space%%Field_Term%%A_space%
{
;msgbox
StringReplace, Haystack, Haystack,%A_space%%Field_Term%%A_space%,%A_space%[••]%A_space%,,all
}	
;msgbox, Field_Term=%Field_Term%
;measure haystack----------
Length := StrLen(Haystack)
StringGetPos, pos_la, Haystack, [••], L1 ;find nth occurrence of [••]
if errorlevel=1
{
Not_foundCounter++
fileappend, %Field_Term%%A_Tab%%Field_Translation%`n ,%A_ScriptDir%\Leydana_STILL_UNKNOWN_Vocab.txt,UTF-8
Freq_STILL_UNKNOWN_Vocab=%Freq_STILL_UNKNOWN_Vocab%%Field_Term%%A_Tab%%Field_Translation%`n
goto, endLoop
}
CardMade_Counter++

/*
; Download mp3 from google
FileCreateDir, %Desktop_Location%\%TextTitle%
sleep 10000
Field_Term_mp3=%Field_Term%
 IfInString, Field_Term_mp3, %A_Space% ; Looks for spaces in Field_Term_mp3 variable
  StringReplace, Field_Term_mp3, Field_Term_mp3, %A_Space%, `%20, All ; Replaces spaces with "%20" (html) to minimize errors from Google Translate
 IfInString, Field_Term_mp3, `? ; Looks for question marks in Field_Term_mp3 variable
  StringReplace, Field_Term_mp3, Field_Term_mp3, `?, `&`#63, All ; Replaces question marks with "?" (html)
UrlDownloadToFile, http://translate.google.com/translate_tts?ie=utf-8&tl=%Audio_Lang%&q=%Field_Term_mp3%`., C:\Users\Will\Desktop\%TextTitle%\%Field_Term_mp3%.mp3
*/

if pos_la < 1
{
;msgbox, errorlevel=%errorlevel% `n`nField_Term:%Field_Term% `nField_Translation:%Field_Translation% `n pos_la:%pos_la%`n pos_R:%pos_R% `n Length:%Length% `n FromRightOffset: %FromRightOffset%`n Clozearea `n`n%Clozearea%
goto, endLoop
}
Clozearea := SubStr(Haystack, pos_la-9, 14)
StringReplace, MinusSave, Clozearea, [••],%Field_Term%,,all
FromRightOffset := Length-pos_la
	StringGetPos, pos_L, Haystack,`., R3, FromRightOffset
StringGetPos, pos_R, Haystack,`., L3, pos_la
;msgbox, Field_Term:%Field_Term% `nField_Translation:%Field_Translation% `n pos_la:%pos_la%`n pos_R:%pos_R% `n Length:%Length% `n FromRightOffset: %FromRightOffset%`n Clozearea `n`n%Clozearea%

Sentences := SubStr(Haystack, pos_L+2, pos_R-pos_L)
;create
StringReplace, Sentences, Sentences, [••],%Field_Term%,,all
StringReplace, Sentences, Sentences, %MinusSave%,%Clozearea%,,all


StringReplace, Sentences, Sentences,Mr`.,Mr,,all
StringReplace, Sentences, Sentences,Mrs`.,Mrs,,all
StringReplace, Sentences, Sentences,%A_Space%`.%A_Space%,`.,,all
StringReplace, Sentences, Sentences,%A_Space%`,%A_Space%,`,,,all
StringReplace, Sentences, Sentences,%A_Space%`;%A_Space%,`;,,all
StringReplace, Sentences, Sentences,%A_Space%`:%A_Space%,`:,,all
StringReplace, Sentences, Sentences,%A_Space%`?%A_Space%,`?,,all
StringReplace, Sentences, Sentences,%A_Space%`!%A_Space%,`!,,all
StringReplace, Sentences, Sentences,%A_Space%`,`,`,%A_Space%,`.`.`.,,all
StringReplace, Sentences, Sentences,%A_Space%`(%A_Space%,`(,,all
StringReplace, Sentences, Sentences,%A_Space%`)%A_Space%,`),,all
StringReplace, Sentences, Sentences,%A_Space%`"%A_Space%,`",,all


; Format the sentences for ANki--------------------------------------
StringReplace, Question_Cloze, Sentences,[••],<span style="font-weight:600; color:#0000ff;">[••]</span>,,
StringReplace, AnswerSent, Sentences,[••],<span style="font-weight:600; color:#0000ff;">%Field_Term%</span>,,
StringReplace, ParseParagraph, Sentences,[••],%Field_Term%,,


StringReplace, ParseParagraph, ParseParagraph,`.,,,All
StringReplace, ParseParagraph, ParseParagraph,`,,,,All
StringReplace, ParseParagraph, ParseParagraph,`?,,,All
StringReplace, ParseParagraph, ParseParagraph,`!,,,All
StringReplace, ParseParagraph, ParseParagraph,`",,,All
StringReplace, ParseParagraph, ParseParagraph,`",,,All
StringReplace, ParseParagraph, ParseParagraph,`,,,All
FileAppend, %ParseParagraph%, %A_ScriptDir%\Temp.txt,UTF-8


	
Definitions= ;clear definitions for next Loop
Loop, Parse, ParseParagraph, %A_Space%
	{
	Value := Corpus_Array[A_LoopField]
	StringReplace, Value, Value,%A_Tab%,%A_Tab%`-`-%A_Space%%A_Space%%A_Space%,,All
	Definitions=%Definitions%%Value%<br>
	}
StringReplace, Definitions, Definitions,%A_Tab%,%A_Space%%A_Space%,,All
StringReplace, Definitions, Definitions,<br><br>,<br>,,All
StringReplace, Definitions, Definitions,<br><br>,<br>,,All
StringReplace, Definitions, Definitions,<br><br>,<br>,,All
StringReplace, Definitions, Definitions,<br><br>,<br>,,All
FileDelete,%A_ScriptDir%\Temp.txt
;msgbox, %Field_Term%%A_Tab%%Field_Translation%%A_Tab%%AnswerSent%%A_Tab%%Question_Cloze%%A_Tab%<span style=" color:#00FFFF;">Meaning</span>%A_Tab%<span style=" color:#FFFF33;">Reading</span>%A_Tab%%TextTitle%%A_Tab%%Definitions%%A_Tab%Japanese_Reading `n , %OutFile%
FileAppend, %Field_Term%%A_Tab%%Field_Translation%%A_Tab%%AnswerSent%%A_Tab%%Question_Cloze%%A_Tab%<span style=" color:#FF0000;">Meaning</span>%A_Tab%<span style=" color:#0000FF;">Reading</span>%A_Tab%%TextTitle%%A_Tab%%Definitions%%A_Tab%`[sound`:%Field_Term%`.mp3`]%A_Tab%Italiano `n , %OutFile%,UTF-8

sleep 1
endLoop:
}
}
}
Statistics=`n
.Freq_Unique_Counter=%Freq_Unique_Counter%`n
.Freq_Redundant_Counter=%Freq_Redundant_Counter%`n
.Corpus_Unique_counter=%Corpus_Unique_counter%`n
.Corpus_Redundant_counter=%Corpus_Redundant_counter%`n
.Not_foundCounter=%Not_foundCounter%`n
.CardMade_Counter=%CardMade_Counter%`n
GuiControl,3:, currenttask, Task Completed!
SoundPlay, %A_ScriptDir%\Soundeffect2.mp3
MsgBox, %Statistics%
MsgBox, there were a number of missing terms from the corpus. Please find a list of this and other missing terms in the following file in the program's directory. UndefinedTermsintheCorpus.txt
}

3GuiClose:  ; User closed the window.
ExitApp
