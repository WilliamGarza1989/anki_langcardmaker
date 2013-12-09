#SingleInstance force
#MaxMem 556  ; Allow 256 MB per variable

;Audio_Lang=en ;for use with the google audio mp3 downloader

OutFile = %A_ScriptDir%\Anki_VocabList.txt 
SETTINGS_FILE=%A_ScriptDir%\Latin-Based_MCD_Maker_Settings.ini ;Program will create new Settings file if Settings file does not exist.

;Load settings from ini file.
  IniRead, TextTitle, %SETTINGS_FILE%, Title, TextTitle,  %A_Space%
  IniRead, File1, %SETTINGS_FILE%, files, file1,  %A_Space%
  IniRead, File2, %SETTINGS_FILE%, files, file2,  %A_Space%
  IniRead, File3, %SETTINGS_FILE%, files, file3,  %A_Space%
 
;Create GUI 
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



; Create card and statistic files
CompareTexts:
CreateDictionaries()
return


GetTitle:
GuiControlGet, TextTitle
;msgbox, %optTextTitle%
IniWrite, "%TextTitle%", %SETTINGS_FILE%, Title, TextTitle
Gui, Submit, NoHide
Return


; Text to create cards from i.e. novels, articles, scripts...
GetFile1:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectfile, File1, , 3
    IniWrite, "%File1%", %SETTINGS_FILE%, files, File1
	    GuiControl,, File1, %File1%
	Gui, Submit, NoHide
return

; Frequency/Vocab terms list
GetFile2:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectfile, File2, , 3
    IniWrite, "%File2%", %SETTINGS_FILE%, files, File2
	GuiControl,, File2, %File2%
	Gui, Submit, NoHide
return

; Tab-delimited Dictionary to create definitions from (these definitions will be for the words in the context that are not the main target term the card will focus on, this will be good for people with no internet connection)
GetFile3:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectfile, File3, , 3
    IniWrite, "%File3%", %SETTINGS_FILE%, files, File3
	GuiControl,, File3, %File3%
	Gui, Submit, NoHide
return

; The main function
CreateDictionaries()
{
	Global
	  ;Add Progress Bar 
	  Gui, 3:Add, Progress, xp-500 yp+25 w300 h20 Range0-50000  -Smooth vMyProgress
	  Gui, 3:Add, Text, xp+320 w300 vcurrenttask

	  ;clear workspace
	FileDelete, %OutFile%
	FileDelete, %A_Desktop%\Freq_STATS\Freq_Unique_list.txt
	FileDelete, %A_Desktop%\Freq_STATS\Freq_Redundant_list.txt
	FileDelete, %A_ScriptDir%\UndefinedTermsintheCorpus.txt


	GuiControl,3:, currenttask, Parsing Source Text
	Fileread, NovelText,%File1%


	; Temporarily remove delimiters from word endings like so.  'the cat is fat.'   >>   'the cat is fat .' Note the added space before the period
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


	GuiControl,3:, MyProgress, +50000 


	sleep 1000
	GuiControl,3:, MyProgress, -50000  
	GuiControl,3:, currenttask, Loading Terms


	;create an empty Array from Frequency/Vocab terms list--------------------------------------------
	;-------------------------------------------------------------------------------------------------
	Freq_Array := []
	; Read the Terms TSV list file to an array
	Loop, Read, %File2%
	{
	;use tab as delimiter to read contents of first line to a file. 
	 Loop, parse, A_LoopReadLine, %A_Tab%
		{
		;for first field i.e. target term
		if A_Index=1
		{
		Field_Term=%A_LoopField%
		
			 Value := Freq_Array[Field_Term]
			 
			 ; if the Array item does not exist, create it
			 If Value =
			 {
				 Freq_Array[Field_Term] :=Field_Term
				 Freq_Unique_list=%Freq_Unique_list%%Field_Term%`n
				 Freq_Unique_Counter++
				}
			; if it already exists, then the item is redundant and it should be skipped
			Else
			{
				Freq_Redundant_list=%Freq_Redundant_list%%Field_Term%`n
				Freq_Redundant_Counter++
				}
			 }
		}
	}
	fileappend, %Freq_Unique_list%`n ,%A_Desktop%\Freq_STATS\Freq_Unique_list.txt,UTF-8
	fileappend, %Freq_Redundant_list%`n ,%A_Desktop%\Freq_STATS\Freq_Redundant_list.txt,UTF-8
	GuiControl,3:, MyProgress, +50000  
	;------------------------------------------------------------------------------------------------
	;------------------------------------------------------------------------------------------------



	sleep 1000
	GuiControl,3:, MyProgress, -50000 
	GuiControl,3:, currenttask, Loading Dictionary


	;create Dictionary Array from chosen Corpus------------------------------------------------------
	;------------------------------------------------------------------------------------------------
	Corpus_Array := []
	Loop, Read, %file3%
	{
	 Loop, parse, A_LoopReadLine, %A_Tab%
		{
		
		;Read Corpus Term and Definition to variables and create a Dictionary Array from these.
		if A_Index=1
		{
		Field_Term=%A_LoopField%
		}
		if A_Index=2
		{
		Field_Translation=%A_LoopField%
		
			 Value := Corpus_Array[Field_Term]
			 
			 ;Check if Array Term-Definition pair has been created yet
			 If Value =
			 {
				 Corpus_Array[Field_Term] := Field_Term A_Tab Field_Translation
				 Corpus_Unique_list=%Corpus_Unique_list%%Field_Term%%A_Tab%%Field_Translation%`n
				 Corpus_Unique_counter++
				 
				}
			; if not take not of redundancy and add these pairs to a list
			Else
				{
				Corpus_Redundant_list=%Corpus_Redundant_list%%Field_Term%%A_Tab%%Field_Translation%`n
				Corpus_Redundant_counter++
				}
		}
		}
	} 
	;-----------------------------------------------------------------------------------------------
	;-----------------------------------------------------------------------------------------------
	GuiControl,3:, MyProgress, +50000  

	sleep 1000
	GuiControl,3:, MyProgress, -50000 
	GuiControl,3:, currenttask, Writing cards to TSV File
	IncreaseProgresBy :=50000/Freq_Unique_Counter

	
	
	
	
	
; Create cards-----------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------
	Loop, parse, Freq_Unique_list,`n
	{
		GuiControl,3:, MyProgress, +%IncreaseProgresBy%  

		;Rervert changes to Context for new card
		Haystack=%NovelText%
		
		;Parse Freq_Unique_list for target terms from top of list to bottom. 
		Loop, parse, A_LoopField, %A_Tab%
		{	
			; Read first and only field of tsv file, the target term, to 'Field_Term'
			if A_Index=1
			{
					Field_Term=%A_LoopField%
					;Find and save term-definition pair in Corpus_Array to 'termdefinition_pair'
					termdefinition_pair := Corpus_Array[Field_Term]
					
					; skip to end of loop if term-definition pair does not exist.
					if termdefinition_pair=
						{
						fileappend, %Field_Term%`n ,%A_ScriptDir%\UndefinedTermsintheCorpus.txt,UTF-8
						goto, endloop
						}
					; if term-definition pair does exist save translation(field 2=A_index 2) to variable 'Field_Translation'
					loop, Parse, termdefinition_pair, %A_Tab%
						{
							if A_Index=2
							{
							Field_Translation=%A_LoopField%
							}
							
						}
					
					;cloze all occurrences of TERM in context
					IfInString, Haystack, %A_space%%Field_Term%%A_space%
						{
						StringReplace, Haystack, Haystack,%A_space%%Field_Term%%A_space%,%A_space%[••]%A_space%,,all
						}	
					;measure haystack----------
					Length := StrLen(Haystack)
					;find nth occurrence of [••] and save position to 'pos_term'
					StringGetPos, pos_term, Haystack, [••], L1
					if errorlevel=1
						{
						Not_foundCounter++
						fileappend, %Field_Term%%A_Tab%%Field_Translation%`n ,%A_ScriptDir%\Leydana_STILL_UNKNOWN_Vocab.txt,UTF-8
						Freq_STILL_UNKNOWN_Vocab=%Freq_STILL_UNKNOWN_Vocab%%Field_Term%%A_Tab%%Field_Translation%`n
						goto, endLoop
						}
					CardMade_Counter++

					/* --------------------------------Too Slow find another way--------------------------------------
					; Download mp3 from google
					FileCreateDir, %A_Desktop%\%TextTitle%
					sleep 10000
					Field_Term_mp3=%Field_Term%
					 IfInString, Field_Term_mp3, %A_Space% ; Looks for spaces in Field_Term_mp3 variable
					  StringReplace, Field_Term_mp3, Field_Term_mp3, %A_Space%, `%20, All ; Replaces spaces with "%20" (html) to minimize errors from Google Translate
					 IfInString, Field_Term_mp3, `? ; Looks for question marks in Field_Term_mp3 variable
					  StringReplace, Field_Term_mp3, Field_Term_mp3, `?, `&`#63, All ; Replaces question marks with "?" (html)
					UrlDownloadToFile, http://translate.google.com/translate_tts?ie=utf-8&tl=%Audio_Lang%&q=%Field_Term_mp3%`., C:\Users\Will\Desktop\%TextTitle%\%Field_Term_mp3%.mp3
					*/
					;----------------------------------Too Slow find another way--------------------------------------

					; if position is negative or zero it was not found so go to end of loop
					if pos_term < 1
						{
						goto, endLoop
						}
					;THIS PART IS REALLY CONVULUTED, I'LL PROBABLY FIND A BETTER WAY OF ORGANIZING IT SOON ENOUGH. SORRY ABOUT THAT...
					
					; get text surrounding target term 9 spaces forward and 14 backward and save to variable '1stclozedinHaystack'****************
					;the extra space ensures that cloze deletion that will occur later will be unique so more than one instance of the words is not 
					;replaced in a single card. This allows the user to focus only on the missing word and prevents confusion.
					1stclozedinHaystack := SubStr(Haystack, pos_term-9, 14)
					;De-cloze (i.e. fill in the cloze with term) delete text from snippet of text '1stclozedinHaystack'
					StringReplace, DeClozed, 1stclozedinHaystack, [••],%Field_Term%,,all
					;Find position of target term in context and save this to 'FromRightOffset'
					FromRightOffset := Length-pos_term
					;Get position of periods 2 sentences to the left and right using '.' as a delimiter, for a total of 5 sentences for the anki card. 
					StringGetPos, pos_L, Haystack,`., R3, FromRightOffset
					StringGetPos, pos_R, Haystack,`., L3, pos_term
					
					;Save Text within the position of these two periods to variable'Sentences'
					Sentences := SubStr(Haystack, pos_L+2, pos_R-pos_L)
					; reverse cloze delete the target term. i.e. fill the holes
					StringReplace, Sentences, Sentences, [••],%Field_Term%,,all
					; replace unique text snippet (9-14 spaces around term) surrounding target term with clozed snippet. ************************
					StringReplace, Sentences, Sentences, %DeClozed%,%1stclozedinHaystack%,,all

					;Revert context to original state before adding spaces around potential delimiters i.e. '.,;:?!etc'
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


					; Format the sentences with color for use with ANki html import--------------------------------------
					StringReplace, Question_Cloze, Sentences,[••],<span style="font-weight:600; color:#0000ff;">[••]</span>,,
					StringReplace, AnswerSent, Sentences,[••],<span style="font-weight:600; color:#0000ff;">%Field_Term%</span>,,
					
					;--------OPTIONAL------------------------OPTIONAL----------------------------------OPTIONAL-------------------------------------------------------------
					;-----The following lines 331-354 are optional as they may make the anki cards too heavy for reasonable use.-------------------------
					;This part will add definitions to bottom of card for the words in the context surrounding the target term (i.e. the non-clozed text)
					; adding the extra definitions can make the cards extremely memory heavy and thus make importing impossible. 
					; Fill in clozes again and remove symbols for use in new variable 'ParseParagraph'
					StringReplace, ParseParagraph, Sentences,[••],%Field_Term%,,
					StringReplace, ParseParagraph, ParseParagraph,`.,,,All
					StringReplace, ParseParagraph, ParseParagraph,`,,,,All
					StringReplace, ParseParagraph, ParseParagraph,`?,,,All
					StringReplace, ParseParagraph, ParseParagraph,`!,,,All
					StringReplace, ParseParagraph, ParseParagraph,`",,,All
					StringReplace, ParseParagraph, ParseParagraph,`",,,All
					StringReplace, ParseParagraph, ParseParagraph,`,,,All
					FileAppend, %ParseParagraph%, %A_ScriptDir%\Temp.txt,UTF-8


					; Add definitions at bottom of card for the context surrounding the target term (i.e. the non-clozed text)	
					;clear definitions for next Loop
					Definitions=
					;Parse through paragraph text with space as a delimiter and add words to an array
					Loop, Parse, ParseParagraph, %A_Space%
						{
						Value := Corpus_Array[A_LoopField]
						;Make definitions pretty by ading a '--' between the term and the definition
						StringReplace, Value, Value,%A_Tab%,%A_Tab%`-`-%A_Space%%A_Space%%A_Space%,,All
						; make them even prettier by putting each definition on a new line
						Definitions=%Definitions%%Value%<br>
						}
						; Get ride of all double new lines in paragraph text so we get one definition pair per line
						StringReplace, Definitions, Definitions,%A_Tab%,%A_Space%%A_Space%,,All
						StringReplace, Definitions, Definitions,<br><br>,<br>,,All
						StringReplace, Definitions, Definitions,<br><br>,<br>,,All
						StringReplace, Definitions, Definitions,<br><br>,<br>,,All
						StringReplace, Definitions, Definitions,<br><br>,<br>,,All
					;----End of--OPTIONAL--------------------End of--OPTIONAL---------------------------------End of--OPTIONAL-------------------------------------------------------------
					FileDelete,%A_ScriptDir%\Temp.txt
					
					;append card contents to file with Tabs as delimiters between each field
					FileAppend, %Field_Term%%A_Tab%%Field_Translation%%A_Tab%%AnswerSent%%A_Tab%%Question_Cloze%%A_Tab%<span style=" color:#FF0000;">Meaning</span>%A_Tab%<span style=" color:#0000FF;">Reading</span>%A_Tab%%TextTitle%%A_Tab%%Definitions%%A_Tab%`[sound`:%Field_Term%`.mp3`]%A_Tab%Italiano `n , %OutFile%,UTF-8

					sleep 1
					endLoop:
			}
		}
	}
	
	; A messagebox with statistics regarding terms that were found, not found, redundant, made, and not made into cards. 
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
