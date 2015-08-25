scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


let s:update_log = {}

function! s:heartbeat_timer_expired() dict "{{{
  return self.time[-1] - self.time[0] > get(g:, 'wakatime_heartbeat_interval', 60)
endfunction "}}}

function! s:heartbeat_reset() dict "{{{
  let self.time = self.time[-1:-1]
endfunction "}}}

function! s:git_branch(dir) "{{{
  return matchstr(readfile(a:dir . '/HEAD', 'b')[0], '/\zs[^/]\+$')
endfunction "}}}

function! s:hg_branch(dir) "{{{
  return readfile(a:dir . '/branch', 'b')[0]
endfunction "}}}

function! s:find_repotype(dir) "{{{
  let parent = fnamemodify(a:dir, ':h')
  if a:dir == parent
    return ['', '']
  endif
  let type = filter(map(['git', 'hg'], '[v:val, printf("%s/.%s", a:dir, v:val)]'), 'isdirectory(v:val[1])')
  if !empty(type)
    return type[0]
  endif
  return s:find_repotype(parent)
endfunction "}}}

function! s:re_match_pattern(path, patterns) "{{{
  for pattern in a:patterns
    let pat = pattern . (has('win32') ? '\c' : '')
    if a:path =~ pat || substitute(a:path, '\', '/', 'g') =~ pat
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:is_hidden(path) "{{{
  return s:re_match_pattern(a:path, get(g:, 'wakatime_hidden_patterns', []))
endfunction "}}}

function! s:is_ignored(path) "{{{
  return s:re_match_pattern(a:path, get(g:, 'wakatime_ignore_patterns', []))
endfunction "}}}

function! s:hidden_name(path) "{{{
  let ext = fnamemodify(a:path, ':e')
  return empty(ext) ? 'HIDDEN' : 'HIDDEN.' . ext
endfunction "}}}

function! s:format_date(date) "{{{
  return printf('%8S: %s', strftime('%X', float2nr(a:date.time)), a:date.entity)
endfunction "}}}

function! s:ping(path, time, param) "{{{
  let param = a:param
  let param.entity = a:path
  let param.time = a:time
  let [type, dir] = s:find_repotype(a:path)
  if !empty(type)
    let param.project = fnamemodify(dir, ':p:h:h:t')
    let param.branch = s:{type}_branch(dir)
  endif
  call wakatime#api#v1#heartbeats#post(param)
endfunction "}}}

function! s:get_entity(path) "{{{
  return s:is_hidden(a:path) ? s:hidden_name(a:path) : a:path
endfunction "}}}

function! s:new(language, lines) "{{{
  return
        \ { 'attr':
        \   { 'type': 'file'
        \   , 'language': a:language
        \   , 'lines': a:lines
        \   }
        \ , 'time': []
        \ , 'is_expired' : function('s:heartbeat_timer_expired')
        \ , 'reset' : function('s:heartbeat_reset')
        \ }
endfunction "}}}

function! s:tick(path, is_write, force, ...) "{{{
  let entity = s:get_entity(a:path)

  if !has_key(s:update_log, entity)
    let s:update_log[entity] = s:new(wakatime#languages#find(a:path, &l:filetype), line('$'))
  endif
  let logs = s:update_log[entity]
  let logs.time += [localtime()]

  if a:force || logs.is_expired()
    let param = copy(logs)
    let param.is_write = a:is_write ? wakatime#api#v1#true() : wakatime#api#v1#false()
    if a:0 && type(a:1) == type([]) && len(a:1) == 2
      let [param.lineno, param.cursorpos] = a:1
    endif
    call s:ping(entity, logs.time[0], param)
    call logs.reset()
  endif
endfunction "}}}

function! s:close(path) "{{{
  let entity = s:get_entity(a:path)

  if has_key(s:update_log, entity)
    call remove(s:update_log, entity)
  endif
endfunction "}}}

function! wakatime#write(path)
  if s:is_ignored(a:path) | return | endif
  call s:tick(a:path, 1, 1)
endfunction

function! wakatime#close(path)
  if s:is_ignored(a:path) | return | endif
  call s:tick(a:path, 0, 1)
  call s:close(a:path)
endfunction

function! wakatime#open(path)
  if s:is_ignored(a:path) | return | endif
  call s:tick(a:path, 0, 0)
endfunction

function! wakatime#update(path)
  if s:is_ignored(a:path) || localtime() - get(b:, 'wakatime_last_ticked', 0) <= get(g:, 'wakatime_tick_period', 5)
    return
  endif
  call s:tick(a:path, 0, 0, getcurpos()[1 : 2])
  let b:wakatime_last_ticked = localtime()
endfunction

function! wakatime#dump()
  return s:update_log
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
