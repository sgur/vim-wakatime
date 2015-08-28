scriptencoding utf-8



" Internal {{{1

" if &filetype matches dict below, determine language
 let s:languages_by_filetype =
       \ { 'AppleScript': ['applescript']
       \ , 'Awk': ['awk']
       \ , 'C#': ['cs']
       \ , 'C++': ['cpp']
       \ , 'CSS': ['css']
       \ , 'Delphi': ['pas']
       \ , 'Erlang': ['erlang']
       \ , 'Fortran': ['fortran']
       \ , 'Git': ['git', 'gitconfig', 'gitcommit', 'gitrebase', 'gitsendemail']
       \ , 'Go': ['go']
       \ , 'Groovy': ['groovy']
       \ , 'Haskell': ['haskell']
       \ , 'HTML': ['html']
       \ , 'INI': ['dosini']
       \ , 'Java': ['java']
       \ , 'JSON': ['json']
       \ , 'JavaScript': ['javascript']
       \ , 'Lua': ['lua']
       \ , 'Markdown': ['markdown']
       \ , 'Objective-C': ['objc']
       \ , 'Objective-C++': ['objcpp']
       \ , 'OCaml': ['ocaml']
       \ , 'Perl': ['perl']
       \ , 'PHP': ['php']
       \ , 'Prolog': ['prolog']
       \ , 'Python': ['python']
       \ , 'R': ['r']
       \ , 'Ruby': ['ruby']
       \ , 'reStructuredText': ['rst']
       \ , 'Sass': ['sass']
       \ , 'Scheme': ['scheme']
       \ , 'SCSS': ['scss']
       \ , 'Shell': ['sh']
       \ , 'Smalltalk': ['st']
       \ , 'SQL': ['sql']
       \ , 'Text': ['text']
       \ , 'VB.net': ['vb']
       \ , 'VimL': ['vim', 'help']
       \ , 'XML': ['xml']
       \ , 'YAML': ['yaml']
       \ }

 let s:languages_by_extension =
       \ { 'ASP': ['asp', 'aspx', 'ascx']
       \ , 'AppleScript': ['applescript']
       \ , 'CoffeeScript': ['coffee']
       \ , 'Common Lisp': ['cl']
       \ , 'CSHTML': ['cshtml']
       \ , 'Dart': ['dart']
       \ , 'Elixir': ['ex', 'esx']
       \ , 'Elm': ['elm']
       \ , 'Emacs Lisp': ['el']
       \ , 'F#': ['fs', 'fsi', 'fsx', 'fsscript']
       \ , 'JSX': ['jsx']
       \ , 'Objective-J': ['j']
       \ , 'PowerShell': ['ps1']
       \ , 'Rust': ['rs', 'rlib']
       \ , 'Scala': ['scala']
       \ , 'Swift': ['swift']
       \ , 'Slim': ['slim']
       \ , 'TypeScript': ['ts']
       \ , 'XAML': ['xaml']
       \ }
 " else captialize
 " 'C', 'Clojure',
 " else unknown
 " 'ActionScript', 'ApacheConf', 'Assembly', 'Bash', 'Cocoa', 'ColdFusion', 'Gosu', 'HaXe', 'Hxml', 'Jade', 'LESS', 'Matlab', 'Mustache', 'Puppet', 'Turing', 'Twig'


" Interface {{{1

" >>> echo wakatime#languages#find(expand('%:p:r'), 'vim')
" VimL
" >>> echo wakatime#languages#find(expand('%:p:r') . '.vim', 'vim')
" VimL
" >>> echo wakatime#languages#find(expand('%:p:r') . '.cl', 'lisp')
" Common Lisp
" >>> echo wakatime#languages#find(expand('%:p:r') . '.jsx', 'javascript')
" JSX

function! wakatime#languages#find(path, filetype) abort
  let ext = fnamemodify(a:path, ':e')
  if !empty(ext)
    let lang = filter(copy(s:languages_by_extension), 'index(v:val, ext) > -1')
    if !empty(lang)
      return keys(lang)[0]
    endif
  endif
  let lang = filter(copy(s:languages_by_filetype), 'index(v:val, a:filetype) > -1')
  if !empty(lang)
    return keys(lang)[0]
  endif
  return 'Other'
endfunction


" Initialization {{{1



" 1}}}
