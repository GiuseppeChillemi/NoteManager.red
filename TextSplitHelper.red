Red [
	name: "TextSplitHelper"

	Purpose: {Help split a single list of notes in different lists corresponding to categories provided.
					 The category names are set in the CATEGORIES block.}
	
	author: "Giuseppe Chillemi"
	
	notes: {Base code provided by 
					
		Toomaas Vooglaid (cut&paste) https://gist.github.com/toomasv/2cda8fb4ebe258d76c8f0cfddaf478e3 
		Vladimir Vasilyev (dynamic coded gui) https://gitter.im/red/help?at=5bca5313ae7be94016849d31 
			
		on RED/HELP GITTER CHAT. 
					
		************** THANKS FRIENDS ! ************
					
					}
					
	Date: 2018-10-23
	Version: 0.6
	
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
	       
	 TODO: {Provide names above each destination text area
	 	let destination areas scroll when text overflows
	  	Provide an ON/OFF switch for auto code
	  	Add text description to the Newlines to skip number display
	  	Code cleaning }
	  		 
	]



;======================= CHANGE CATEGORIES HERE ====================
categories: [personal programming articles todo shopping fun ideas sites]
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

copycut: func [pname] [if area1/selected [
   nls1: nls2: 0 
		if system/platform = 'Windows [
			parse txt: copy area1/text [some [newline c: (c: insert c newline) :c | skip]] 
		]
       add-word txt B2
       area1/selected: none 
	 ]
   set-focus area1
]
	
;===============================================================


;======================= ADD A WORDS TO AREA ==================
add-word: func [txt area][
	txt2: take/part at txt area1/selected/1 
		area1/selected/2 - area1/selected/1 + 1
	if system/platform = 'Windows [
		parse txt [some [newline remove newline | skip]]
		parse txt2 [some [newline remove newline | skip]]
	]
	area1/text: txt
	append append area/text txt2 newline
]
;================================================================





;==================== SELECT TEXT IN MAIN AREA ==================
select-text: [

	    	skey: newline
	    	areatext: copy area1/text 

	    	
	   	
	    	repeat count totalnl [
	    		either found: find areatext skey [
	    			endidx: index? found
	    			areatext: next found


	    		]
	    		[endidx: length? area1/text]


			]

			either found [
				if system/platform = 'Windows [
					parse copy/part area1/text endidx [some [newline (endidx: endidx + 1) | skip]]

				]

			        area1/selected: as-pair startidx endidx
				set-focus area1
			]
			[

			 	parse copy/part area1/text endidx [some [newline (endidx: endidx + 1) | skip]]

			 	area1/selected: as-pair startidx endidx
			 	set-focus area1
			]
]
;===============================================================




;=========== DYNAMIC VID LAYOUT COSTRUCUIN HERE ================

mask: collect [
	Tittle: "Text Split Helper"

	keep compose [
		area1: area 500x500 focus wrap tx 
	]

	foreach [tag name] buttons [
		keep compose [
	  	 below (to set-word! name) area 300x50 (copy "") wrap 
	  	]
	]
		



  
	  keep compose [return across below return]

	  foreach [tag name] buttons [
		name-string: to string! name
	      keep compose/deep [
		  (to set-word! tag) button 80 (name-string) data (name) [if area1/selected <> none [b2: face/data (to-string name) copycut (name-string) do select-text ]]
	      ]
	  ]


    	

	keep compose [
		 nlnum: text 40 data to-string totalnl
		 across
	   BT-Select: button "Seleziona" 70 [do select-text]
	]
	
	keep compose [
	  across 
		upkey: button "Up" 40 [totalnl: totalnl + 1 nlnum/data: to-string totalnl do select-text] ;mettere select
		below
		downkey: Button "down" 40 [if totalnl <> 1 [totalnl: totalnl - 1 nlnum/data: to-string totalnl] do select-text] ;mettere select
	]
		
		


	keep compose/deep [
		return
	 	BT-SAVE: button "Save" 50 [foreach [tag name] buttons [write to-file name select get to-word name 'text]]
	]
	
	keep compose/deep [
		return
		BT-LOAD: button "Load" 50 [foreach [tag name] buttons [
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


view  mask

