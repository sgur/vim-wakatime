scriptencoding utf-8


" POST users/:user/heartbeats
" POST users/current/heartbeats

function! wakatime#api#v1#heartbeats#post(...) abort
  let param = a:0 > 0 ? a:1 : {}
  let user = a:0 > 1 ? a:2 : 'current'
  call wakatime#api#v1#post_bg(printf('/users/%s/heartbeats', user), param)
endfunction
