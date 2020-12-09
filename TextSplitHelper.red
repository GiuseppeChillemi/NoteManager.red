Red [
	name: "TextSplitHelper"
	needs: view

	Purpose: {Help split a single list of notes in different lists corresponding to categories provided.
					 The category names are set in the CATEGORIES block.}
	
	author: "Giuseppe Chillemi"
	
	notes: {Base code provided by 
					
		Toomaas Vooglaid (cut&paste) https://gist.github.com/toomasv/2cda8fb4ebe258d76c8f0cfddaf478e3 
		Vladimir Vasilyev (dynamic coded gui) https://gitter.im/red/help?at=5bca5313ae7be94016849d31 
			
		on RED/HELP GITTER CHAT. 
					
		************** THANKS FRIENDS ! ************
					
					}
					
	Date: 2020-12-02
	Version: 0.8
	
	License: "GNU GPLv3 - https://www.gnu.org/licenses/gpl-3.0.html"
	
	
	Usage: {Insert the text you want to manually split in the big area. The small righ one are destination areas.
					Select the text you want to catalog and hit the category button to cut and paste it to the corresponding area for the category
					The Select button highlight text starting from the first character and ending to the "N th" end-of-line (the number displayed on screen)
					Hit SAVE to store destinantion areas on disk, 
					load to retrieve previous saved one. 
					Clear will empty main entry area. 
					Up/Down change the auto select function to stop on the "N th" newline
							 
					Each category button move the selected text the the corresponding area and AUTOSELECT the next text.				 
				  I have adopted this work mode for speed reason.}


	
	VersionNotes: { 0.7: Added Auto deletion of first Newline of the text in input area
		Added RIGHT MOUSE BUTTON Support: Now Left one move text without adding NEWLINE after it in the 
		destination area while LMB adds without newline. RMB is not fully working as first text cut and 
		pasted has no empty line after it but the second one has it
		Addeded Handling of -empty: ""- and -none- main input area
		0.8: Area and button have been shortened to have some more of them on screen
		Added NL = 1 button to reset the number of newlines to select to 1
		The program now load and save the big note area too
		0.9: Adapted to RED 30th November 2020 where the newline bug has been removed
		
										   }
	TODO: {
			ADD a COPY combination wihtout deleting
			SAVE MUST WARN THE USER ABOUT OVERWRITING FILES ! Empty areas could destroy your work ! Double check
				Add a numerated backup file for each text category we save and main area (in a separate dir)
				Add a "pre screen" with group of categories. Selecting a group you edit categories and then dinamycally create
				the gui. Categories will be saved either in an external (unique) file or directly in source code (NOOOO)
				Provide names above each destination text area
				let destination areas scroll when text overflows
				Add warning if files are orphaned.
				Elaboratefilename to add GROUP-CTG- to NAME
				Code cleaning
				Add a way to select and load the NOTE textfile
				Add a way to create a queue of textfile
				Save the unfinished textfile *DONE on 0.7 (automatically with question)
				Load the unfinisched textfile *DONE on 0.7 (Automaticalli with question
				Investigate how to keep the selection visible in the first area after you select another area 
				or you press a button.
				Investigate what happen when you insert and the cursor is a a different position than the end
				Investigate if you could get and move the cursor position
				Investigate why after save/load cycle the last space of area1 seems to be removed
				Investigate why software becames slow and after a move the highlight appears late. GP}
	BUG: {
		If you select to the END OF LINE it does not consider the end as EOF but the next one
		If the next one is NEWLINE and you take the text, it does not remove the newline
		If the text is loaded again, then it keeps the previous position of AREA1!!! You have to quit and restart!
		CR are deleted but if it skips the first one, then they are no more deleted
		Seems excess of CR are removed at the end
		There seems to be a BIG COPY or PARSE which slows everityng


		RMB does not add newline after first moving but foes it from the second move - TOFIX
				If RMB has added a space, it retains adding a space for the next addition
				when you select another area the text higlighting disappear.
				How to reselect the first one without loosing the seleaction too ?
				It seems that you can store lines with only spaces and EOL, those lines should go >NIL. If
				this bug is not found here is soe wrong condition on empty lines which are copied
				It seems that after manually selecting and then moving the NL is not added in the destination area
				
				}
	Usage: {LMB adds the selected text (or autoselect if no text selected), RMB as before but adds a newline}
]



;======================= CHANGE CATEGORIES HERE ====================
categories: load %categories.txt
;===================================================================


buttons: copy []
tx: "Brief^/Example^/text^/select me and^/hit a category button^/I will move there^/Up - down autoselect more lines^/select to manually select^/Hope will help you !"


foreach tag categories [
	append buttons to-word rejoin ['BT- tag]
	append buttons to-word tag	
]


B2: none		
count: 0
totalnl: 1
startidx: 1

;======================= COPY SELECTED TEXT ====================

arealist: [
	area1
	areaoggi
	areaselected
]

;bottoni: - TOP , bottom, muovi in area, TOAREA1 TOAREA TOGGI, TOAREAx
;evita riposizionamento dopo il CUT
;Metti backup
;Metti possibilit? di colorare testo


swapareas: func [] []


;Il programma elimina i newline in eccesso

copycut: func [
	"The function copies an area of text and calls another function tu cut and paste it"
	pname mode /top] [
	if focused-area/selected [
  		nls1: nls2: 0 
		if system/platform = 'Windows [
			;Inserts some newlines but I don't know the reason
;			parse txt: copy focused-area/text [some [newline c: (c: insert c newline) :c | skip]] 

			txt: copy focused-area/text 
		]
     	  either not top [
		add-word txt B2 mode
	] [
		add-word/top txt B2 mode]
		focused-area/selected: none 
	 ]
   set-focus focused-area
]
	
;===============================================================


;======================= ADD A WORDS TO AREA ==================
add-word: func [txt area mode /top][
	;Removes the focused part in the selected area
	txt2: take/part at txt focused-area/selected/1
		;Takes the lenght of the focalized area + 1 which is the text selected + the carriage returns?
 
		focused-area/selected/2 - focused-area/selected/1 + 1;Senza il + 1 Non si ha selezione e spostamento corretto

;If you uncomment it, it removes all the newlines

;	if system/platform = 'Windows [
;		parse txt [some [newline  remove newline | skip]]
;		parse txt2 [some [newline remove newline | skip]]
;	]
	focused-area/text: txt

	;Append to area/text a the text found and a newline (to the end) or inser to the head the new text found and a newline

	if mode = 'newline [either not top [append append area/text txt2 newline][insert head area/text rejoin [txt2 newline]]]

	;As before without a newline
	if mode = 'single [either not top [append area/text txt2][insert head area/text copy txt2]]
	
]
;================================================================


remove-eol: does [
	if (first focused-area/text) = newline [remove focused-area/text print ["RIMOSSO NL"]]
]


;==================== SELECT TEXT IN MAIN AREA ==================
select-text: [
;	print ["Length? Area1/Text;" length? area1/text probe area1/text type? area1/text]

	;Search text in AREA1

	;If the selected text is not NONE or EMPTY STRING	
	if (focused-area/text <> "") and (focused-area/text <> none) [

	    	skey: newline

		;Get the text of the selected Area
	    	areatext: copy focused-area/text 

	    	
		;Repeat until the end element position is found
		;totalnl parte con 1
	   	
		;Select after one or more NEWLINES. Totalnl is set by UP AND DOWN but printed nowhere
		;endidx is the position of the latest newline!
	    	repeat count totalnl [
	    		either found: find areatext skey [
				;Set the point where the element has been found
	    			endidx: index? found
				;Set the area as the next element
	    			areatext: next found



	    		]
	    		[;If not END element has been found, then it is the whole file
				endidx: length? focused-area/text
			]


			]

			;If FIND has returned an element FOUND is not NONE so it is TRUE

			either found [
				if system/platform = 'Windows [
					;If a new line is found, the end idx is the next, otherwhile, skip to the next character
;					parse copy/part focused-area/text endidx [some [newline (endidx: endidx + 1) | skip]]
					parse copy/part focused-area/text endidx [some [newline (endidx: endidx) | skip]]

				]
			;Highlight the focused are. Area STARTIDX is 1

			  focused-area/selected: as-pair startidx endidx

				;Set focus to the previously focued area
				set-focus focused-area
			]
			[
;			 	parse copy/part focused-area/text endidx [some [newline (endidx: endidx) | skip]]				
			 	parse copy/part focused-area/text endidx [some [newline (endidx: endidx) | skip]]

			 	focused-area/selected: as-pair startidx endidx
			 	set-focus focused-area
			]
		]
]
;===============================================================




;=========== DYNAMIC VID LAYOUT COSTRUCUIN HERE ================

mask: collect [
	Tittle: "Text Split Helper"

	keep compose [
		below
		Text "Da Smistare" 100x16
		area1: area 400x300 focus wrap tx
		Text "Diario" 100x16
		areaoggi: area 400x300 focus wrap
		return
		Text "Calendario" 100x16
		Text "di Oggi" 100x16
		areacalendario: area 180x280 focus wrap
		Text "Procedure" 100x16
		areaprocedure: area 180x260 focus wrap
		return
		Text "Sposta Categorie" 100x16
	]

	keep [below button 80x13 green "Diario" data get 'areaoggi on-click [
						focused-area: w/selected	;w e' il LAYOUT, quindi prende il testo selezionato nell'area focalizzata
;		  			probe focused-area/text
		  			either focused-area/selected <> none [
		  				b2: face/data 
		  				copycut/top "areaoggi" 'single
 
		  				do select-text 
		  			]
		  			[remove-eol do select-text] 
			]
			on-alt-down [
						focused-area: w/selected
;		  			probe focused-area/text
		  			either focused-area/selected <> none [
		  				b2: face/data 
		  				copycut/top "areaoggi" 'newline 
		  				do select-text 
		  			]
		  			[remove-eol do select-text] 
			]			
			
			
			
		]

	keep [below button 80x13 green "OGGI" data get 'areacalendario on-click [ ;Area Calendario è l'area al centro
						focused-area: w/selected
;		  			probe focused-area/text
		  			either focused-area/selected <> none [
		  				b2: face/data 
		  				copycut/top "areacalendario" 'single 
		  				do select-text 
		  			]
		  			[remove-eol do select-text] 
			]
			on-alt-down [
						focused-area: w/selected
;		  			probe focused-area/text
		  			either focused-area/selected <> none [
		  				b2: face/data 
		  				copycut/top "areacalendario" 'newline 
		  				do select-text 
		  			]
		  			[remove-eol do select-text] 
			]			
			
			
			
		]
	
	foreach [tag name] buttons [
		keep compose [
	  	 below (to set-word! name) area 300x25 (copy "") wrap 
	  	]
	]
  
	  keep compose [return across below return]

		keep compose [Text "Sezioni  Categorie" 100x16]

		button-idx: 0
	  foreach [tag name] buttons [
	  button-idx: button-idx + 1		  	
		name-string: to string! probe name
	      keep compose/deep [
		  (to set-word! tag) button 80x13 (name-string) data (name) ;scoprire perche' qui funziona senza GET 'NAME
		  	on-click 
		  		[	focused-area: w/selected
;		  			probe focused-area/text
		  			either focused-area/selected <> none [
		  				b2: face/data 
		  				copycut (name-string) 'single 
		  				do select-text 
		  			] 
		  		[remove-eol do select-text]] 
		  	on-alt-down 
		  		[b2: face/data view [area 600x400 with [text: b2/text]]]
	      ]
	      if button-idx = 30 [keep compose [return] button-idx: 1]
	  ]


;https://gitter.im/red/help?at=5c0079719aec405095a1741c
;view window: layout [area "this" area "that" area "other" button [probe window/selected/text]]
;https://gitter.im/red/help?at=5c007f96500e8e3728363b5d
    	

	keep compose [
		 nlnum: text 40 data to-string totalnl
		 return
	   BT-Select: button "Seleziona" 70 [do select-text]
	]
	
	keep compose [
		upkey: button "Up" 40 [totalnl: totalnl + 1 nlnum/data: to-string totalnl do select-text] ;mettere select
		below
		downkey: Button "down" 40 [if totalnl <> 1 [totalnl: totalnl - 1 nlnum/data: to-string totalnl] do select-text] ;mettere select
		resetnlkey: Button "NL = 1" 40 [totalnl: 1 do select-text]
	]
		
		


	keep compose/deep [
	 	BT-SAVE: button "Save" 50 [
			write to-file "area1" area1/text 
			write to-file "areaoggi" areaoggi/text
			write to-file "areacalendario" areacalendario/text 
			write to-file "areaprocedure" areaprocedure/text 
	 		foreach [tag name] buttons [write to-file name select get to-word name 'text]]
		]
	
	keep compose/deep [
		BT-LOAD: button "Load" 50 [
			if exists? to-file "area1" [
				area1/text: read to-file "area1"
			] 

			if exists? to-file "areaoggi" [
				areaoggi/text: read to-file "areaoggi"
			] 


			if exists? to-file "areacalendario" [
				areacalendario/text: read to-file "areacalendario"
			]
			
			if exists? to-file "areaprocedure" [
				areaprocedure/text: read to-file "areaprocedure"
			]


			foreach [tag name] buttons [
				if exists? to-file name [
					filebody: read to-file name 
					change select get to-word name 'text filebody
				]
			]
		]
		BT-CLEAR: Button "Clear" 50 [area1/text: copy ""]
	]
]   

;===============================================================


view  w: layout mask
