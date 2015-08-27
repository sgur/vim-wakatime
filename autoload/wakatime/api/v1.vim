scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" Internal {{{1

let s:V = vital#of('wakatime')
let s:base64 = s:V.import('Data.Base64')
let s:json = s:V.import('Web.JSON')

let s:url = 'https://wakatime.com/api/v1'
let s:auth = {'Authorization': 'Basic ' . s:base64.encode(get(g:, 'wakatime_api_key', ''))}
let s:user_agent = printf('vim-wakatime/%s (%s) Vim%s vim-wakatime'
      \ , "0.1.0"
      \ , (has('win32') ? 'Windows'
      \   : executable('uname') ? system('uname -s') : 'Unknown')
      \ , printf('%d.%d', v:version / 100, v:version % 100)
      \ )

function! s:header() abort "{{{
  return extend(
        \ { 'X-Machine-Name': hostname()
        \ , 'Content-Type': 'application/json'
        \ , 'Accept': 'application/json'
        \ , 'User-Agent': s:user_agent
        \ }, s:auth)
endfunction "}}}


" Interface {{{1

function! wakatime#api#v1#true() abort
  return s:json.true
endfunction

function! wakatime#api#v1#false() abort
  return s:json.false
endfunction

function! wakatime#api#v1#post_bg(path, param) abort
  if empty(get(g:, 'wakatime_api_key', '')) | return | endif
  let url = s:url . a:path
  let postdata = s:json.encode(a:param)
  let headdata = s:header()
  let file = tempname()
  if executable('curl')
    let command = 'curl -q -L -s -k -X POST'
    let quote = &shellxquote ==# '"' ?  "'" : '"'
    for key in keys(headdata)
      if has('win32')
        let command .= " -H " . quote . key . ": " . substitute(headdata[key], '"', '"""', 'g') . quote
      else
        let command .= " -H " . quote . key . ": " . headdata[key] . quote
      endif
    endfor
    let command .= " " . quote . url . quote
    call writefile(split(postdata, "\n"), file, "b")
    if has('win32')
      silent execute '!start /b cmd /c' command "--data-binary @" . quote . file . quote '& DEL "' . file . '"'
    else
      silent execute '!(' . command "--data-binary @" . quote . file . quote ' ; rm -f "' . file . '") > /dev/null &'
    endif
  endif
endfunction

" Initialization {{{1

if !exists('g:wakatime_api_key')
  echohl WarningMsg | echomsg 'wakatime: g:wakatime_api_key not defined' | echohl NONE
endif
" 1}}}



let &cpo = s:save_cpo
unlet s:save_cpo
