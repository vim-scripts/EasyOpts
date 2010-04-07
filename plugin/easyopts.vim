" easyopts.vim - Easy Options Management
" ---------------------------------------------------------------
" Version:  0.2
" Authors:  HoX <mail2hox@gmail.com>
" Last Modified: 2010 apr 07 14:42:25
" Script:   http://www.vim.org/scripts/script.php?script_id=3020
" License:  GPL (Gnu Public License)
"
" A special thanks to Alessandro who helps me when Vim doesn't

let g:easyopts_version = 002
let g:easyopts_known_types = [  "Boolean", "String", "Integer", "Float", "Path" ]


" Load previously saved options
let s:easyopts_savefile = $HOME."/.vim/easyopts.sav"

if filereadable ( s:easyopts_savefile )
	silent! execute "source ".s:easyopts_savefile
endif

" Buffer number
let s:current_menu_buffer = -1

 """""""""""""""
" Var Functions "
"               "
 """""""""""""""
function s:Get_Type ( text )
	let retval =  substitute ( a:text, "\\(.\\)\\(.*\\)", "\\u\\1\\L\\2", "" )

	if retval == "Bool"
		return "Boolean"
	else
		return retval
	endif
endfunction

function s:Get_Callback ( action, type )
	let l:type = s:Get_Type ( a:type )

	if exists ( "*EasyOpts_".a:action."_Option_Type_".l:type )
		return "EasyOpts_".a:action."_Option_Type_".l:type
	elseif index ( g:easyopts_known_types, l:type ) >= 0
		return "s:".a:action."_Option_Type_".l:type
	else
		echoe "Unknown type '".l:type."' (using string)"
		return "s:".a:action."_Option_Type_String"
	endif
endfunction

 """""""""""""""""
" CHECK Functions "
"                 "
 """""""""""""""""
function s:Check_Option_Type_Boolean ( value )
	if a:value != 0 && a:value != 1
		return 0
	else
		return 1
	endif
endfunction

function s:Check_Option_Type_Float ( value )
	return match ( a:value, "^\\d*\\(\\.\\d\\+\\)\\=$" ) != -1 && !empty ( a:value )
endfunction

function s:Check_Option_Type_Integer ( value )
	return match ( a:value, "^\\d\\+$" ) != -1 && !empty ( a:value )
endfunction

function s:Check_Option_Type_Path ( value )
	return !empty ( a:value )
endfunction

function s:Check_Option_Type_String ( value )
	return !empty ( a:value )
endfunction


 """""""""""""""
" GET Functions "
"               "
 """""""""""""""
function s:Get_Option_Type_Boolean ( name, current )
	if a:current == 0
		return 1
	else
		return 0
	endif
endfunction

function s:Get_Option_Type_Float ( name, current )
	let l:tmp = input ( "Insert value for '".a:name."': " )
	return l:tmp
endfunction

function s:Get_Option_Type_Integer ( name, current )
	let l:tmp = input ( "Insert value for '".a:name."': " )
	return l:tmp
endfunction

function s:Get_Option_Type_Path ( name, current )
	let l:tmp = input ( "Insert path for '".a:name."': ", "", "file" )
	return l:tmp
endfunction

function s:Get_Option_Type_String ( name, current )
	let l:tmp = input ( "Insert value for '".a:name."': " )
	return l:tmp
endfunction

 """""""""""""""
" PUT Functions "
"               "
 """""""""""""""
function s:Put_Option_Type_Boolean (value)
	if a:value == 1
		return "true"
	else
		return "false"
	endif
endfunction

function s:Put_Option_Type_Integer (value)
	return a:value + 0
endfunction

function s:Put_Option_Type_Float (value)
	execute "let ret = printf ( \"%2.3f\", ".a:value." ) "
	return ret
endfunction

function s:Put_Option_Type_Path (value)
	return a:value
endfunction

function s:Put_Option_Type_String (value)
	return "\"".a:value."\""
endfunction

function s:Put_Option (option,forward)
	let l:tmpList = a:option

	let PutCB = function ( s:Get_Callback ( "Put", l:tmpList[ 1 ] ) )
	let l:tmpPut = "    * ".l:tmpList[ 0 ].": "
	execute ":let l:tmpPut .= PutCB ( ".l:tmpList[ 2 ]." )"

	if a:forward
		put =l:tmpPut
	else
		-1put =l:tmpPut
	endif
endfunction


 """""""""""""""
" Init Function "
"               "
 """""""""""""""

function EasyOpts_Init ( optList )
	let lists = a:optList

	for opt in lists
		if !exists ( expand ( opt[ 2 ] ) ) || exists ( "s:easyopts_defaults" )
			execute "let ".opt[ 2 ]." = \"".opt[ 3 ]."\""
		endif
	endfor
endfunction

 """""""""""""""
" Save Function "
"               "
 """""""""""""""
function EasyOpts_Menu_Save ( )
	let lists = s:current_menu

	execute "edit! ".$HOME."/.vim/easyopts.sav"

	for opt in lists
		silent! execute "g/^let ".expand ( opt[ 2 ] )."/d"
		execute "let l:value = " . opt[ 2 ]
		let l:out = "let ".opt[ 2 ]." = \"".l:value."\"\n"
		put =l:out
	endfor

	write
	bdelete
endfunction

 """""""""""""""
" Menu Function "
"               "
 """""""""""""""
function EasyOpts_Menu_Open ( menuTitle, optList )
	call EasyOpts_Menu_Close()

	let lists = a:optList
	let s:current_menu_title = a:menuTitle
	let s:current_menu = a:optList

	let l:numitems = len ( lists )
	execute "bo ".( len( lists ) + 5 )."new"

	let out = "   ".a:menuTitle
	put =out

	for opt in lists
		call s:Put_Option ( opt, 1 )
	endfor

	let out = "\n    [q] -> quit (temporary save) - [s] -> quit (permanent save) - [d] -> set default value - [D] -> set defaults all\n"
	put =out

	let out = "\n"
	put =out

	setlocal nonumber
	setlocal wrap
	setlocal nomodifiable
	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal nobuflisted

	let s:current_menu_buffer = bufnr ( "%" )

	call cursor ( 3, 5 )
	nnoremap <silent> <buffer> <CR>	:call EasyOpts_Menu_Update_Option()<CR>
	nnoremap <silent> <buffer> <Up>		:call PrevMenuItem()<CR>
	nnoremap <silent> <buffer> <Down>	:call NextMenuItem()<CR>
	nnoremap <silent> <buffer> <Left>	<Nop>
	nnoremap <silent> <buffer> <Right>	<Nop>
	nnoremap <silent> <buffer> <PageUp>	<Nop>
	nnoremap <silent> <buffer> <PageDown>	<Nop>
	nnoremap <silent> <buffer> <End>	<Nop>
	nnoremap <silent> <buffer> <Home>	<Nop>
	nnoremap <silent> <buffer> k		:call PrevMenuItem()<CR>
	nnoremap <silent> <buffer> j		:call NextMenuItem()<CR>
	nnoremap <silent> <buffer> h		<Nop>
	nnoremap <silent> <buffer> l		<Nop>
	nnoremap <silent> <buffer> b		<Nop>
	nnoremap <silent> <buffer> <Space>	<Nop>
	nnoremap <silent> <buffer> <BS>		<Nop>
	nnoremap <silent> <buffer> q		:call EasyOpts_Menu_Close()<CR>
	nnoremap <silent> <buffer> s		:call EasyOpts_Menu_Save()<CR>
	nnoremap <silent> <buffer> d		:call EasyOpts_Menu_Set_Default()<CR>
	nnoremap <silent> <buffer> D		:call EasyOpts_Menu_All_Defaults()<CR>
endfunction

function PrevMenuItem ()
	let cl = line ( "." )
	let max = len ( s:current_menu ) + 2

	if cl > 3
		let cl -= 1
		call cursor ( cl, 5 )
	else
		call cursor ( 3, 5 )
	endif
endfunction

function NextMenuItem ()
	let cl = line ( "." )
	let max = len ( s:current_menu ) + 2

	if cl < max
		let cl += 1
		call cursor ( cl, 5 )
	else
		call cursor ( max, 5 )
	endif
endfunction

function EasyOpts_Menu_Update_Option ()
	let current_line = line ( "." ) - 3

	if current_line < 0 || current_line >= len ( s:current_menu )
		return
	endif

	let sublist = s:current_menu[ current_line ]

	let GetCB = function ( s:Get_Callback ( "Get", sublist[ 1 ] ) )
	let CheckCB = function ( s:Get_Callback ( "Check", sublist[ 1 ] ) )

	execute ":let l:prevalue = ".sublist[ 2 ]

	if !exists ( "s:easyopts_defaults" )
		execute ":let l:tmp = GetCB ( sublist[ 0 ], ".sublist[ 2 ]." )"
		let l:allowed = CheckCB ( l:tmp )

		if l:allowed == 0
			echohl ErrorMsg
			echo "Invalid value for type ".sublist[ 1 ]
			echohl None
			let l:tmp = l:prevalue
		endif
	else
		let l:tmp = expand ( sublist[ 3 ] )
	endif

	execute "let ".sublist[ 2 ]." = l:tmp"
	setlocal modifiable
	delete
	call s:Put_Option ( sublist, 0 )
	setlocal nomodifiable
	echo
endfunction

function EasyOpts_Menu_Set_Default ()
	let s:easyopts_defaults = 1
	call EasyOpts_Menu_Update_Option()
	unlet s:easyopts_defaults
endfunction

function EasyOpts_Menu_All_Defaults ()
	let s:easyopts_defaults = 1
	call EasyOpts_Init ( s:current_menu )
	call EasyOpts_Menu_Open ( s:current_menu_title, s:current_menu )
	unlet s:easyopts_defaults
endfunction

function EasyOpts_Menu_Close ()
	if exists ( "s:current_menu_buffer" ) && bufexists ( s:current_menu_buffer )
		execute "bdelete ".s:current_menu_buffer
		unlet s:current_menu
		unlet s:current_menu_title
		return 1
	endif

	return 0
endfunction

