
" A simple script go generate document for C/C++ function
" Author: sheny@baidu.com
" Date: 2006-07-09
" Version: 0.1
" TODO: 1 like :  if (!doc) , not valid param info, fixed but param info like
"                 void  aaa(void), failed
"
"

syntax on

set nocompatible    " Use Vim defaults (much better!)

set smarttab
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set cindent
retab


"public auto indent
set cino=g0
set nocp
"namespaces auto indent
function! IndentNamespace()
        let l:cline_num = line('.')
        let l:pline_num = prevnonblank(l:cline_num - 1)
        let l:pline = getline(l:pline_num)
        let l:retv = cindent('.')
        while l:pline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
            let l:pline_num = prevnonblank(l:pline_num - 1)
            let l:pline = getline(l:pline_num)
        endwhile
        if l:pline =~# '^\s*namespace.*'
            let l:retv = 0
        endif
        return l:retv
endfunction
setlocal indentexpr=IndentNamespace()

if exists("loaded_gendocument")
    finish
endif
let loaded_gendocument = 1

let g:KeyWordsPrefixToErase = "inline,extern,\"C\",virtual,static"
let g:TokenNotInFunDeclare = "#,{,},;,"
let g:MAX_PARAM_LINE = 12

function! <SID>DateInsert()
	$read !date /T
endfunction

function! <SID>OpenNew()
	let s = input("input file name: ")
	execute  ":n"." ".s
endfunction


" Function : GetNthItemFromList (PRIVATE)
" Purpose  : Support reading items from a comma seperated list
"            Used to iterate all the extensions in an extension spec
"            Used to iterate all path prefixes
" Args     : list -- the list (extension spec, file paths) to iterate
"            n -- the extension to get
" Returns  : the nth item (extension, path) from the list (extension
"            spec), or "" for failure
" Author   : Michael Sharpe <feline@irendi.com>
" History  : Renamed from GetNthExtensionFromSpec to GetNthItemFromList
"            to reflect a more generic use of this function. -- Bindu
function! <SID>GetNthItemFromList(list, n, sep)
   let itemStart = 0
   let itemEnd = -1
   let pos = 0
   let item = ""
   let i = 0
   while (i != a:n)
      let itemStart = itemEnd + 1
      let itemEnd = match(a:list, a:sep, itemStart)
      let i = i + 1
      if (itemEnd == -1)
         if (i == a:n)
            let itemEnd = strlen(a:list)
         endif
         break
      endif
   endwhile
   if (itemEnd != -1)
      let item = strpart(a:list, itemStart, itemEnd - itemStart)
   endif
   return item
endfunction


function! DebugStr(s)
    return
	echo a:s
endfunction

function! <SID>MatchInList(s, l)
	let i=1
	let kw = <SID>GetNthItemFromList(a:l, i, ",")
	while (strlen(kw)>0)
		call DebugStr("MatchInList Nth ".kw)
		if (match(a:s, kw)!=-1)
			return i
		endif
		let i = i+1
		let kw = <SID>GetNthItemFromList(a:l, i, ",")
	endwhile
	return -1
endfunction


function! <SID>ErasePrefix(s)
	let i=1
	let ts = substitute(a:s, '^\s\+', "", "")
	let kw = <SID>GetNthItemFromList(g:KeyWordsPrefixToErase, i, ",")

	while (strlen(kw)>0)
		call  DebugStr("ErasePrefix Nth ".kw)
		let ts = substitute(ts, '^'.kw, "", "")
		let ts = substitute(ts, '^\s\+', "", "")
		let i = i+1
		let kw = <SID>GetNthItemFromList(g:KeyWordsPrefixToErase, i, ",")
	endwhile
	return ts
endfunction

function! <SID>GetCurFunction()
	let cur_line_no = line(".")
	let max_line_no = line("$")
	let fun_str = ""
	let raw_fun_str = ""
	let fun_line_count=0

	while (fun_line_count<g:MAX_PARAM_LINE && cur_line_no<=max_line_no)
		let cur_line = getline(cur_line_no)
		let cur_line_no = cur_line_no + 1
		let fun_line_count = fun_line_count+1
		if ( strlen(cur_line)>0 )
			let raw_fun_str = raw_fun_str . cur_line . " \n"
		endif
	endwhile

	call DebugStr("raw_fun_str ".raw_fun_str)

	let idx =0
	let fun_over=0
	let raw_fun_str_len = strlen(raw_fun_str)
	let quote=0
	while (idx<raw_fun_str_len && fun_over==0)
		let cur_char = raw_fun_str[idx]
		"exec DebugStr("cur_char:".cur_char)
		let idx = idx+1

		if (cur_char=="/")
			"check next char
			let next_char = raw_fun_str[idx]
			"exec DebugStr("next_char:".next_char)

			if (next_char=="/")
				"find /n
				let new_line_pos = match(raw_fun_str, "\n", idx)
				if (new_line_pos==-1)
					"echo "error format near //"
					return ""
				endif
				let idx = new_line_pos+1
				continue
			elseif (next_char=="*")
				let idx = idx+1
				let right_pos = match(raw_fun_str, "*/", idx)
				if (right_pos==-1)
					 "error format near /*"
					return ""
				endif
				let idx = right_pos+2
				continue
			else
				 "error format near /"
				return ""
			endif
		endif

		if (cur_char=="(")
			let quote = quote+1
		endif

		if (cur_char==")")
			let quote = quote-1
			if (quote==0)
				let fun_over=1
			endif
		endif

		if (cur_char!="\n")
			let fun_str = fun_str . cur_char
        else
            exec DebugStr("fun_str:".fun_str)
            let is_py = <SID>IsPythonEnv()
            if (is_py == 1 && match(fun_str, "class") == 0)
                let fun_over=1
                let fun_str = strpart(fun_str, 0, strlen(fun_str) - 2) . "()"
            endif
		endif
		"exec DebugStr(fun_str)
	endwhile


	if (fun_over==1)
		if ( <SID>MatchInList(fun_str, g:TokenNotInFunDeclare)==-1)
			return <SID>ErasePrefix(fun_str)
		endif
	endif

	 "can't find function format!"
	return ""

endfunction


"pass in : ' int a[23] '
"return  : "int[23],a"
function! <SID>GetSingleParamInfo(s, isparam)
	" unsigned int * ass [1][2]

	let single_param = a:s
	call DebugStr("single param ".single_param)


	if (a:isparam)
		" erase default value , eg int a = 10
		let single_param = substitute(single_param, '=\(.\+\)', "", "g")
	endif

	" erase ending blank
	let single_param = substitute(single_param, '\(\s\+\)$' , "", "")

	" erase blank before '['
	let single_param = substitute(single_param, '\(\s\+\)[', "[", "g")
	"exec DebugStr(single_param)

	let single_param = substitute(single_param, '^\s\+', "", "")
	"exec DebugStr(single_param)

	" erase blank before '*' | '&'
	let single_param = substitute(single_param, '\(\s\+\)\*', "*", "g")
	let single_param = substitute(single_param, '\(\s\+\)&', "\\&", "g")
	"exec DebugStr(single_param)

	" insert blank to * (&), eg int *i => int * i
	let single_param = substitute(single_param, '\(\*\+\)', "\\0 ", "")
	let single_param = substitute(single_param, '\(&\+\)', "\\0 ", "")

	call DebugStr("single param processed:" .single_param. "END")
	"call DebugStr("single param processed:" .single_param)

	"let match_res = matchlist(single_param, '\(.\+\)\s\+\(\S\+\)')
	"'^\s/*\(.\+\)\s\+\(.\+\)\s/*$')
	"exec DebugStr(match_res)
	"let type = match_res[1]
	"let name = match_res[2]

	let pos = match(single_param, '\S\+$')

	if (pos==-1)
		call DebugStr("pos==-1")
		return ""
	endif

	let type = strpart(single_param, 0, pos-1)
	let name = strpart(single_param, pos)

	" type can be "", eg c++ constructor
	if (strlen(name)==0)
		call DebugStr("strlen(name)==0")
		return ""
	endif

    let is_py = <SID>IsPythonEnv()
    if (is_py == 0)
        if (a:isparam && strlen(type)==0)
            call DebugStr("a:isparam && strlen(type)==0")
            return ""
        endif
    endif

	let bpos = match(name, "[")
	if (bpos!=-1)
		let type = type . strpart(name, bpos)
		let name = strpart(name, 0, bpos)
	endif

	"trim final string
	let type = substitute(type, '\(\s\+\)$' , "", "")
	let name = substitute(name, '\(\s\+\)$' , "", "")

	let ret = type.",". name.","
	call DebugStr("RET GetSingleParamInfo " . ret)
	return ret
endfunction


" format are "type,name,"
"  begin with function name and then "\n" then followed by param
function! <SID>GetFunctionInfo(fun_str)
	let param_start = match(a:fun_str, "(")
	let fun_info = ""

	if (param_start==-1)
		  "can't find '(' in function "
		return ""
	endif

	let fun_name_part = strpart(a:fun_str, 0, param_start)
	let param_start = param_start + 1
	let param_len   = strlen(a:fun_str) - param_start -1
	let fun_param_part = strpart(a:fun_str, param_start, param_len)

	call DebugStr("FUN :".fun_name_part)
	call DebugStr("PARAM :".fun_param_part)

	"analysis fun_name_part
	let temp = <SID>GetSingleParamInfo(fun_name_part, 0)
	if (strlen(temp)==0)
		 "function name analysis failed!!"
		return ""
	endif
	let fun_info = fun_info . temp

	"analysis fun_param_part
	let cur_idx = 0
	let comma_idx = match(fun_param_part, "," , cur_idx)
	while (comma_idx!=-1)
		"for earch param
		let single_param = strpart(fun_param_part, cur_idx, comma_idx - cur_idx)
		let temp = <SID>GetSingleParamInfo(single_param, 1)
		if (strlen(temp)>0)
			let fun_info = fun_info.temp
			let cur_idx = comma_idx + 1
			let comma_idx = match(fun_param_part, "," , cur_idx)
		else
			echo "function param analysis failed!!"
			return ""
		endif
	endwhile

	"last param
	let single_param = strpart(fun_param_part, cur_idx)

	if (strlen(matchstr(single_param, '\S'))>0)
		let temp = <SID>GetSingleParamInfo(single_param, 1)
		if (strlen(temp)>0)
			let fun_info = fun_info.temp
		"else
			"echo "function param analysis failed!!"
		"	return ""
		endif

	endif

	return fun_info
endfunction


function! <SID>GetUserName()
	let home = $HOME
	let user = matchstr(home, '[^/\\]\+$')
	return user
endfunction

function! <SID>GetDate()
	"windows
	let date = system("date /T")
	if (v:shell_error!=0)
		"linux
		let date = system("date +\"%Y/%m/%d %H:%M:%S\" ")
	endif

	if (date[strlen(date)-1]=="\n")
		let date = strpart(date, 0, strlen(date)-1)
	endif
	return date
endfunction

function! <SID>GetYear()
	return strftime("%Y")
endfunction

function! <SID>GetLastModifiedDate()
	let fname = expand("%")
	let	date = getftime(fname)
	let strDate = strftime("%c", date)
	return strDate
endfunction
"     /**
"      * @brief This is a function called Test
"      *
"      * Details about Test
"      * @param a an integer argument.
"      * @param s a constant character pointer.
"      * @return The test results
"      * @author sprite
"      * @date 2006-07:
"      * @version 1.0
"      * @todo
"      */

function! <SID>GetDoxygenStyleDoc(fun_info, leading_blank)

	let doc=""
	let idx=1
	let doc  = a:leading_blank."/**\n"

	let ret_type = <SID>GetNthItemFromList(a:fun_info, idx, ",")
	let idx = idx + 1
	let fun_name = <SID>GetNthItemFromList(a:fun_info, idx, ",")
	let idx = idx + 1
	if (strlen(fun_name)==0)
		return ""
	endif

	"let doc = doc . a:leading_blank." * @brief brief description about ".fun_name."\n"
	let doc = doc . a:leading_blank." * @brief \n"
	let doc = doc. a:leading_blank." *\n"
	"let doc = doc . a:leading_blank." * detail description about ".fun_name."\n"

	"gen function name part
	let type = <SID>GetNthItemFromList(a:fun_info, idx, ",")
	let idx = idx + 1
	let name = <SID>GetNthItemFromList(a:fun_info, idx, ",")
	let idx = idx + 1

	"gen param part
	while(strlen(type)>0 && strlen(name)>0)

		let doc = doc . a:leading_blank." * @param [in] ".name." "."  : ".type.  "\n"
		let type = <SID>GetNthItemFromList(a:fun_info, idx, ",")
		let idx = idx + 1
		let name = <SID>GetNthItemFromList(a:fun_info, idx, ",")
		let idx = idx + 1
	endwhile

	if (! (strlen(type)==0 && strlen(name)==0) )
		return ""
	endif

	"ret
	if (strlen(ret_type)>0)
		let doc = doc . a:leading_blank." * @return  ".ret_type. " \n"
		let doc = doc . a:leading_blank." * @retval  "." \n"
	endif

	"other
  let doc = doc . a:leading_blank." * @see \n"
	let doc = doc . a:leading_blank." * @author ".<SID>GetUserName()."\n"
  let doc = doc . a:leading_blank." * @date ".<SID>GetDate()."\n"
	"let doc = doc . a:leading_blank." * @version 1.0.0 \n"
	"let doc = doc . a:leading_blank." * @todo \n"

	" end
	let doc = doc . a:leading_blank."**/\n"
	return doc
endfunction
function! <SID>GetFileName()
	let fname = expand("%")
	return fname
endfunction
function! <SID>GetVer()
  let fname = system("cvs st ".<SID>GetFileName()." |grep -o \"Sticky Tag:.*\"|awk -F'[\t\t]' '{print $3}' ")
  if (strlen(matchstr(fname, "PD_BL")) <= 0)
	  let fname = system("cvs st ".<SID>GetFileName()."|grep -o \"Working revision:.*\"|awk -F'[\t]' '{print $2}' ")
	  if ( strlen(fname) > 6)
		  let fname = "1.0"
	  endif
  endif
	if (fname[strlen(fname)-1]=="\n")
		let fname = strpart(fname,0,strlen(fname)-1)
	endif
	return fname
endfunction

function! <SID>GetEmail()
	let home = $HOME
	let user = matchstr(home, '[^/\\]\+$')
	return user . "@baidu.com"
endfunction

function! <SID>GetDoxFileHeader(leading_blank)

	let doc = ""
  let doc = doc. a:leading_blank."/***************************************************************************\n"
	let doc = doc. a:leading_blank." * \n"
  let doc = doc. a:leading_blank." * Copyright (c) ".<SID>GetYear()." Baidu.com, Inc. All Rights Reserved\n"
  let doc = doc. a:leading_blank." * $Id$ \n"
  let doc = doc. a:leading_blank." * \n"
  let doc = doc. a:leading_blank." **************************************************************************/\n"
  let doc = doc. a:leading_blank." \n "
  let doc = doc. a:leading_blank."/**\n"
	let doc = doc. a:leading_blank." * @file ".<SID>GetFileName()."\n"
	let doc = doc. a:leading_blank." * @author ".<SID>GetUserName()."(".<SID>GetEmail().")\n"
	let doc = doc. a:leading_blank." * @date ".<SID>GetDate()."\n"
	let doc = doc. a:leading_blank." * @version $Revision$ \n"
	let doc = doc. a:leading_blank." * @brief \n"
	let doc = doc. a:leading_blank." *  \n"
	let doc = doc. a:leading_blank." **/\n"
  call append(line('$'), "/* vim: set ts=4 sw=4 sts=4 tw=100 */")
	return doc


endfunction

function! <SID>GetDoxMainpage(leading_blank)

	let doc = ""
	let doc = doc.a:leading_blank."/**\n"
	let doc = doc.a:leading_blank."* @mainpage xxx介绍及使用方法 \n"
	let doc = doc.a:leading_blank."* \<h2>概述</h2>\n"
	let doc = doc.a:leading_blank."* <p>xxxxxxxxxxx</p>\n"
	let doc = doc.a:leading_blank."* <ol></ol>\n"
	let doc = doc.a:leading_blank."* <h2>使用方法</h2>\n"
	let doc = doc.a:leading_blank."* <hr>\n"
	let doc = doc.a:leading_blank."* <p>问题请发送<a href=\"mailto:".<SID>GetEmail()."?subject=[dilib]\">.".<SID>GetEmail()."</a></p>\n"
	let doc = doc. a:leading_blank."*/\n"
	return doc
endfunction

function! <SID>GetDoxClass(leading_blank)
	let doc = ""
	let doc = doc.a:leading_blank."/**\n"
	let doc = doc. a:leading_blank."* @brief \n"
	let doc = doc. a:leading_blank."*  \n"
	let doc = doc. a:leading_blank."*  \n"
	let doc = doc. a:leading_blank."*/\n"
	return doc
endfunction
function! <SID>GetDoxGroup(leading_blank)
	let doc = ""
	let doc = doc.a:leading_blank."/** @addtogroup groupname\n"
	let doc = doc. a:leading_blank."*  \n"
	let doc = doc. a:leading_blank."* <ul>\n"
	let doc = doc. a:leading_blank."* <li> item1\n"
	let doc = doc. a:leading_blank."* 	<ol>\n"
	let doc = doc. a:leading_blank."* 	<li> subitem11\n"
	let doc = doc. a:leading_blank."* 	<li> subitem12\n"
	let doc = doc. a:leading_blank."* 	</ol>\n"
	let doc = doc. a:leading_blank."* <li> item2\n"
	let doc = doc. a:leading_blank."* 	<ol>\n"
	let doc = doc. a:leading_blank."* 	<li> subitem21\n"
	let doc = doc. a:leading_blank."* 	<li> subitem22\n"
	let doc = doc. a:leading_blank."* 	</ol>\n"
	let doc = doc. a:leading_blank."* </ul>\n"
	let doc = doc. a:leading_blank."* @{\n"
	let doc = doc. a:leading_blank."*/\n"
	let doc = doc. a:leading_blank." \n"
	let doc = doc. a:leading_blank."/** @} */\n"
	return doc
endfunction

function! <SID>ReTab()
    retab
    startinsert!

endfunction

function! <SID>GenCppDoc()
	let l:synopsisLine=line(".")+1
    let l:synopsisCol=col(".")

	let cur_line = line(".")
       	let first_line = getline(cur_line)
	let leading_blank = ""

	if (strlen(matchstr(first_line, '\S'))==0)
		return
	else
		let leading_blank = matchstr(first_line, '\(\s*\)')
	endif

	let fun_str = <SID>GetCurFunction()
	if (strlen(fun_str)==0)
		"exec cursor(cur_line, 0)
		return
	endif

	call DebugStr("FUN_BODY ".fun_str)

	let fun_info = <SID>GetFunctionInfo(fun_str)
	call DebugStr("fun_info ".fun_info."END")

	let doc = <SID>GetDoxygenStyleDoc(fun_info, leading_blank)
	"echo "doc \n".expand(doc)

	if (strlen(doc)>0)
		let idx =1
		let li = <SID>GetNthItemFromList(doc, idx, "\n")
		while (strlen(li)>0)
			call append( cur_line-1, li.expand("<CR>"))
			let idx = idx + 1
			let cur_line = cur_line + 1
			let li = <SID>GetNthItemFromList(doc, idx, "\n")
		endwhile
	endif
    exec l:synopsisLine
    exec "normal " . l:synopsisCol . "|"
    startinsert!

endfunction
function! <SID>GetDoxFH(type)
	let l:synopsisLine=line(".")+1
    let l:synopsisCol=col(".")

	let cur_line = line(".")
    let first_line = getline(cur_line)
	let leading_blank = matchstr(first_line, '\(\s*\)')
	if (a:type == 1)

		let doc = <SID>GetDoxFileHeader(leading_blank)
	elseif (a:type == 0)
		let doc = <SID>GetDoxMainpage(leading_blank)
	elseif (a:type == 2)
		let doc = <SID>GetDoxClass(leading_blank)
		if (strlen(matchstr(first_line, '\S'))==0)
			return
		endif
	elseif (a:type == 3)
		let doc = <SID>GetDoxGroup(leading_blank)
	elseif (a:type == 4)
		let doc = <SID>GetPyDocFileHeader(leading_blank)
	endif
	if (strlen(doc)>0)
		let idx =1
		let li = <SID>GetNthItemFromList(doc, idx, "\n")
		while (strlen(li)>0)
			call append( cur_line-1, li.expand("<CR>"))
			let idx = idx + 1
			let cur_line = cur_line + 1
			let li = <SID>GetNthItemFromList(doc, idx, "\n")
		endwhile
	endif

    exec l:synopsisCol
    exec "normal " . l:synopsisCol . "|"
    startinsert!


endfunction

function! <SID>ValCppComment()

  call cursor(line('.'), col('$'))
  exec "normal! a\t\t  /**<        */"
  call cursor(line('.'), col('$')-9)

endfunction

function! <SID>InsertFormat()
  call <SID>GetDoxFH(1)
  let idx = 0
    "20
  while (idx > 0)
    call append(line('$') - 1, "")
    let idx = idx - 1
  endwhile

  "call append(line('$'), "/* vim: set ts=4 sw=4 sts=4 tw=100 */")
  call cursor(15, 11)
endfunction

function! <SID>InsertHeadFormat()
  let s = toupper(<SID>GetFileName())
  let s = substitute(s, "[\.]", "_", "g")
"  call append(line('$')-2, "#ifndef <产品线>_<模块>_". s. "")
"  call append(line('$')-2, "#define <产品线>_<模块>_". s. "")
"  call append(line('$')-2, "")
"  call append(line('$')-2, "#endif  //<产品线>_<模块>_". s. "")

" modified by anqin to fix the unknown display
  call append(line('$')-2, "#ifndef ". s. "")
  call append(line('$')-2, "#define ". s. "")
  call append(line('$')-2, "")
  call append(line('$')-2, "#endif  // ". s. "")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""
"  python specification
"        by qinan@baidu.com
"
""""""""""""""""""""""""""""""""""""""""""""""""""


function! <SID>GetPydocStyleDoc(fun_info, leading_blank)
    let doc = ""
    let idx = 1
    let doc  = a:leading_blank."    \"\"\"\n"

    let ret_type = <SID>GetNthItemFromList(a:fun_info, idx, ",")
    let idx = idx + 1
    let fun_name = <SID>GetNthItemFromList(a:fun_info, idx, ",")
    let idx = idx + 1
    if (strlen(fun_name)==0)
        return ""
    endif

    "let doc = doc . a:leading_blank." * @brief brief description about ".fun_name."\n"
    let doc = doc . a:leading_blank."        brief info for: ".fun_name."\n"
    let doc = doc. a:leading_blank."        \n"
    let doc = doc. a:leading_blank."        Args:\n"
    "let doc = doc . a:leading_blank." * detail description about ".fun_name."\n"

    "gen function name part
    let type = <SID>GetNthItemFromList(a:fun_info, idx, ",")
    let idx = idx + 1
    let name = <SID>GetNthItemFromList(a:fun_info, idx, ",")
    let idx = idx + 1

    "gen param part
    while(strlen(name) > 0)
        if (strlen(<SID>ErasePrefix(name)) > 0)
            let doc = doc . a:leading_blank."    ".name." ".":\n"
        endif

        let type = <SID>GetNthItemFromList(a:fun_info, idx, ",")
        let idx = idx + 1
        let name = <SID>GetNthItemFromList(a:fun_info, idx, ",")
        let idx = idx + 1
    endwhile

    if (! (strlen(type) == 0 && strlen(name) == 0) )
        return ""
    endif

    "ret
"    if (strlen(ret_type) > 0)
        let doc = doc . a:leading_blank."        Return:  "." \n"
"        let doc = doc . a:leading_blank."  retval  "." \n"
"    endif

    "other
    let doc = doc . a:leading_blank."        Raise: \n"
"    let doc = doc . a:leading_blank." * @note \n"
"    let doc = doc . a:leading_blank." * @author ".<SID>GetUserName()."\n"
"    let doc = doc . a:leading_blank." * @date ".<SID>GetDate()."\n"
    "let doc = doc . a:leading_blank." * @version 1.0.0 \n"
    "let doc = doc . a:leading_blank." * @todo \n"

    " end
    let doc = doc . a:leading_blank."    \"\"\"\n"
    return doc
endfunction


function! <SID>GetPyDocFileHeader(leading_blank)
    let doc = "#!/usr/bin/env python\n"
    let doc = doc. a:leading_blank."# -*- coding: utf-8 -*-\n"
    let doc = doc. a:leading_blank."########################################################################\n"
    let doc = doc. a:leading_blank."# \n"
    let doc = doc. a:leading_blank."# Copyright (c) ".<SID>GetYear()." Baidu.com, Inc. All Rights Reserved\n"
    let doc = doc. a:leading_blank."# \n"
    let doc = doc. a:leading_blank."########################################################################\n"
    let doc = doc. a:leading_blank." \n"
    let doc = doc. a:leading_blank."\"\"\"\n"
    let doc = doc. a:leading_blank."File: ".<SID>GetFileName()."\n"
    let doc = doc. a:leading_blank."Author: ".<SID>GetUserName()."(".<SID>GetUserName()."@baidu.com)\n"
    let doc = doc. a:leading_blank."Date: ".<SID>GetDate()."\n"
    let doc = doc. a:leading_blank."\"\"\"\n"
    return doc
endfunction

function! <SID>GenPyDoc()
    call DebugStr("call: GenPyDoc()")

    let l:synopsisLine = line(".") + 1
    let l:synopsisCol = col(".")

    let cur_line = line(".")
        let first_line = getline(cur_line)
    let leading_blank = ""

    call DebugStr("CUR_LINE ".first_line)
    if (strlen(matchstr(first_line, '[def|class]')) == 0)
        call DebugStr("FUN_LINE ".first_line)
        return
    else
        let leading_blank = matchstr(first_line, '\(\s*\)')
    endif

    let fun_str = <SID>GetCurFunction()
    if (strlen(fun_str) == 0)
        "exec cursor(cur_line, 0)
        call DebugStr("FUN_LINE ".first_line)
        return
    endif

    call DebugStr("FUN_BODY ".fun_str)

    let fun_info = <SID>GetFunctionInfo(fun_str)
    call DebugStr("fun_info ".fun_info."END")

    let doc = <SID>GetPydocStyleDoc(fun_info, leading_blank)
"    echo "doc \n".expand(doc)

    if (strlen(doc) > 0)
        let idx = 1
        let li = <SID>GetNthItemFromList(doc, idx, "\n")
        while (strlen(li) > 0)
            call append(cur_line, li.expand("<CR>"))
            let idx = idx + 1
            let cur_line = cur_line + 1
            let li = <SID>GetNthItemFromList(doc, idx, "\n")
        endwhile
    endif
    exec l:synopsisLine
    exec "normal " . l:synopsisCol . "|"
    startinsert!
endfunction

function! <SID>ValPyComment()
    call cursor(line('.'), col('$'))
    exec "normal! a\t # "
    call cursor(line('.'), col('$')-3)
    startinsert!
endfunction


function! <SID>InsertPyFormat()
  call <SID>GetDoxFH(4)
  call cursor(13, 1)
endfunction

function! <SID>IsPythonEnv()
    let cur_ft = &filetype
    let ret = 0
    call DebugStr("file type:".cur_ft)
    if (match(cur_ft, 'python') != -1)
        let ret = 1
    endif
    return ret
endfunction

function! <SID>GenDoc()
    let is_py = <SID>IsPythonEnv()
    if (is_py == 1)
        call <SID>GenPyDoc()
    else
        call <SID>GenCppDoc()
    endif
endfunction


function! <SID>ValPyComment()
    call cursor(line('.'), col('$'))
    exec "normal! a\t # "
    call cursor(line('.'), col('$')-3)
    startinsert!
endfunction

function! <SID>ValComment()
    let is_py = <SID>IsPythonEnv()
    if (is_py == 1)
        call <SID>ValPyComment()
    else
        call <SID>ValCppComment()
    endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""

"autoindent
map  ;nb      gg=G
map  ;re      :call <SID>ReTab()<CR>
imap ;re <ESC>:call <SID>ReTab()<CR>
"function
map  ;df      :call <SID>GenDoc()<CR>
imap ;df <ESC>:call <SID>GenDoc()<CR>
"variable
map  ;dv      :call <SID>ValComment()<CR>
imap ;dv <ESC>:call <SID>ValComment()<CR>
"main page
map  ;dm      :call <SID>GetDoxFH(0)<CR>
imap ;dm <ESC>:call <SID>GetDoxFH(0)<CR>
autocmd FileType c,cpp,java,sh,awk,vim,sed,perl nnoremap <silent> <Leader>a :call <SID>GetDoxFH(0)<CR>
"start
map  ;ds      :call <SID>GetDoxFH(1)<CR>
imap ;ds <ESC>:call <SID>GetDoxFH(1)<CR>
autocmd FileType c,cpp,java,sh,awk,vim,sed,perl nnoremap <silent> <Leader>s :call <SID>GetDoxFH(1)<CR>
"description
map  ;dd      mz:call <SID>GetDoxFH(2)<CR><Esc>'z
imap ;dd <ESC>;dda
autocmd FileType c,cpp,java,sh,awk,vim,sed,perl nnoremap <silent> <Leader>d :call <SID>GetDoxFH(2)<CR>
"group
map  ;dg      :call <SID>GetDoxFH(3)<CR>
imap ;dg <ESC>:call <SID>GetDoxFH(3)<CR>
autocmd FileType c,cpp,java,sh,awk,vim,sed,perl nnoremap <silent> <Leader>f :call <SID>GetDoxFH(3)<CR>
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType proto   let b:comment_leader = '# '
autocmd BufNewFile *.h,*.cpp,*.c,*.cc,*.java,*.pl,*.php  :call <SID>InsertFormat()
autocmd BufNewFile *h :call <SID>InsertHeadFormat()
autocmd BufNewFile *.py :call <SID>InsertPyFormat()
