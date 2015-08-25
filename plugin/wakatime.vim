" wakatime
" Version: 0.0.1
" Author: sgur
" License: MIT License

if exists('g:loaded_wakatime')
  finish
endif
let g:loaded_wakatime = 1

let s:save_cpo = &cpo
set cpo&vim



" Internal {{{1

function! s:do(path, func) "{{{
  if !filewritable(a:path) || &readonly || !&modifiable
    return
  endif
  call call(a:func, [a:path])
endfunction "}}}

" Interface {{{1

augroup plugin-wakatime
  autocmd!
  autocmd BufWritePost *  call s:do(expand("<afile>:p"), 'wakatime#write')
  autocmd BufWinEnter,WinEnter,FocusGained *  call s:do(expand("<afile>:p"), 'wakatime#open')
  autocmd BufDelete *  call s:do(expand("<afile>:p"), 'wakatime#close')
  autocmd InsertEnter,InsertLeave,TextChanged,TextChangedI,CursorHoldI *  call s:do(expand("<afile>:p"), 'wakatime#update')
augroup END

" 1}}}



let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
