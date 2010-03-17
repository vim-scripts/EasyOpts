" easyopts.vim - Easy Options Management
" ---------------------------------------------------------------
" Version:  0.1
" Authors:  HoX <mail2hox@gmail.com>
" Last Modified: 2009 Sept 25
" Script:   Still doesn't known
" License:  GPL (Gnu Public License)

let g:easyopts_version = 001

let g:easyopts_known_types = [  "Boolean", "String", "Integer", "Float", "Path" ]

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
		if !exists ( expand ( opt[ 2 ] ) )
			execute "let ".opt[ 2 ]." = \"".opt[ 3 ]."\""
		endif
	endfor
endfunction

 """""""""""""""
" Menu Function "
"               "
 """""""""""""""
function EasyOpts_Menu_Open ( menuTitle, optList )
	call EasyOpts_Menu_Close()

	let lists = a:optList
	let s:current_menu = a:optList

	let l:numitems = len ( lists )
	execute "bo ".( len( lists ) + 3 )."new"

	let out = "   ".a:menuTitle
	put =out

	for opt in lists
		call s:Put_Option ( opt, 1 )
	endfor

	let out = "\n"
	put =out
	
	setlocal nonumber
	setlocal wrap
	setlocal nomodifiable
	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal nobuflisted
	
	let s:current_menu_buffer = bufname ( "%" )

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
	execute ":let l:tmp = GetCB ( sublist[ 0 ], ".sublist[ 2 ]." )"
	let l:allowed = CheckCB ( l:tmp )

	if l:allowed == 0
		echohl ErrorMsg
		echo "Invalid value for type ".sublist[ 1 ]
		echohl None
		let l:tmp = l:prevalue
	endif

	execute "let ".sublist[ 2 ]." = l:tmp"
	setlocal modifiable
	delete 
	call s:Put_Option ( sublist, 0 )
	setlocal nomodifiable
	echo
endfunction

function EasyOpts_Menu_Close ()
	if exists ( "s:current_menu_buffer" ) && bufexists ( s:current_menu_buffer )
		bdelete s:current_menu_buffer
		unlet s:current_menu
		nunmap <Enter>
		return 1
	endif

	return 0
endfunction

