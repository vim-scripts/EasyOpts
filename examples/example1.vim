
let uservars = [ 
	\[ "Name", "string", "g:user_name", "Goofy" ],
	\[ "Age", "integer", "g:user_age", 30 ],
	\[ "Height", "float", "g:user_height", "1.75" ],
	\[ "Male", "boolean", "g:user_sex", 0 ],
	\[ "Zodiac", "zodiac", "g:user_zodiac", "Aries" ],
	\[ "Home directory", "path", "g:user_home", "/home/goofy" ]
\]

let s:zodiacs = [ 
    \"Aries", "Taurus", "Gemini", "Cancer", 
    \"Leo", "Virgo", "Libra", "Scorpio", 
    \"Sagittarius", "Capricorn", "Acquarius", "Pisces"
\]

function Zodiac_complete ( ArgLead, CmdLine, CursorPos )
	let retList = []

	for i in s:zodiacs 
		if match ( i, "^".a:ArgLead.".*" ) != -1
			call add( retList, i )
		endif
	endfor 

	return retList
endfunction

function EasyOpts_Get_Option_Type_Zodiac ( name, current )
	return input ( "Insert the value for '".a:name."': ", "", "customlist,Zodiac_complete" )
endfunction

function EasyOpts_Check_Option_Type_Zodiac ( value )
	if index ( s:zodiacs, a:value ) == -1
		return 0
	else
		return 1
	endif
endfunction

function EasyOpts_Put_Option_Type_Zodiac ( value )
        return a:value
endfunction

