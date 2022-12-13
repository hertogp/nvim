" ~/.config/nvim/init.vim  -- NVIM config (separate from vim)
"
" set runtimepath^=~/.vim runtimepath+=~/.vim/after
" Show script -> see order in which scripts are loaded

let &packpath = &runtimepath

" Filetypes: {{{2
augroup vimrcEx
au!
autocmd FileType text setlocal textwidth=79

" try moving to last known cursor position upon re-editing a file
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif
augroup END

" EasyQuit: {{{3
" Easy quit nofile-like windows
" augroup QuitNoFile
" au!
" Notes:
" - sometimes buftype gets set after the bufenter event
augroup EasyQuit
  au!
"  au bufenter * if &buftype=='nofile'|nnoremap <buffer> q <esc>:q<cr>|endif
  au FileType nofile, qf nnoremap <buffer> q <esc>:q<cr><c-w>p
  au syntax * if &buftype=='nofile'|nnoremap <buffer> q <esc>:q<cr>|endif
  au syntax * if &buftype=='quickfix'|nnoremap <buffer> q <esc>:q<cr>|endif
  au syntax * if &buftype=='loclist'|nnoremap <buffer> q <esc>:q<cr>|endif
  au syntax * if &buftype=='help'|nnoremap <buffer> q <esc>:q<cr>|endif
  au syntax * if &syntax == 'man'|nnoremap <buffer> q <esc>:q<cr>|endif
  au syntax * if &syntax == 'Godoc'|nnoremap <buffer> q <esc>:q<cr>|endif
  " au syntax * if bufname('%')=='__doc__'|nnoremap <buffer> q <esc>:q<cr>|endif
  " au syntax * if bufname('%')=='[Scratch]'|nnoremap <buffer> q <esc>:q<cr>|endif
augroup END

"
" Pandoc: {{{3
augroup auPandoc
  au!
  autocmd FileType pandoc set formatoptions="want"
  " makeprg is setup via vim-pandoc's compiler
  "   see ~/.vim/after/compiler/pandoc.vim, where a proper makeprg is set
  "   this method does not need the ~/bin/mk.notes shell script.
  " <F4> - to compile the current markdown buffer to pdf
  " <S-F4> - to compile & preview the current markdown buffer in evince
  " See help jobstart (neovim) -> arg ["cmd", "args"] -> run directly
  autocmd FileType markdown,pandoc nnoremap <buffer><S-F4> <esc>:silent make\|redraw!\|copen<cr>
  autocmd FileType markdown,pandoc nnoremap <buffer><F4> <esc>:silent make\|redraw!\|call jobstart(["xdg-open", expand("%:r").".pdf"])<cr>
  autocmd FileType markdown,pandoc compiler pandoc
augroup END

" Generic: {{{2
" TODO
" nnoremap <f8> :echom 'pos:(' . line(".") . "," . col(".") . ")"
"     \. ' -> hi:<'
"     \. synIDattr(synID(line("."),col("."),1),"name")
"     \. '>, transparent:<'
"     \. synIDattr(synID(line("."),col("."),0),"name")
"     \. '>, local:<'
"     \. synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
"     \. '>'<CR>

" Use :W to write a file you opened with sudo (you'll need sudo rights)
command! W  execute 'silent w !sudo tee % % > /dev/null' | :edit!

" SYSTEM: {{{2
" PythonLib: {{{3
" python <<EOF
" #py3 <<EOF
" # add (n)vim's pylib to sys.path
" # no import sys -> it's already available
" from os.path import expanduser, abspath
" PYLIB = abspath(expanduser('~/.config/nvim/pylib'))
" # sys.path.append(PYLIB)
" sys.path.insert(0, PYLIB)
" del expanduser, abspath
" EOF

" CODING: {{{2

" LSP: {{{3
"
" Elixir {{{2
" let g:neomake_elixir_enabled_makers = ['credo']
augroup Elixir
  au!
  autocmd FileType elixir set nostartofline
  " this overrides neoterm's check for config/config.exs which libraries donot
  " have
  autocmd FileType elixir
        \ if filereadable('mix.exs') |
        \ call neoterm#repl#set('iex -S mix') |
        \ else |
        \ call neoterm#repl#set('iex') |
        \ end

   autocmd BufWritePost *.exs silent :MixFormat
   autocmd BufWritePost *.ex silent :MixFormat
  " autocmd BufWritePost * Neomake
augroup END


" C language {{{2
augroup Clang
  au!
  au FileType C set path+=,/usr/include/x86_64-linux-gnu/,/usr/include/linux
  au FileType C set tw=79 sw=2 ts=2
augroup END

" GOlang {{{2
augroup GO
  au!
  au FileType GO set tw=79 sw=2 ts=2
augroup END



" LUA: {{{2
" https://github.com/WolfgangMehner/lua-support
augroup Lua
au!
au FileType lua
      \ set tw=79 sw=2 ts=2 fo-=cro |
      \ let b:closer = 1 |
      \ let b:closer_flags = '[{'
augroup end

" JAVASCRIPT: {{{2
augroup JS
au!
au FileType javascript set tw=79 sw=2 ts=2
augroup end

" PYTHON: {{{2
" pylint3 error output format string: see: https://docs.pylint.org/en/1.6.0/output.html
augroup PyMake
  au!
  " *Trick*  -- make error code/category visible in quick window
  " - ensure msg-template list that info in efm's %m part
  " - 1st efm string, 'eats' output given by msg-template:
  "   %f:    {path}:
  "   %t%n:  {msg_id}  (eg C301)
  "   %l:%c: {line}:{column}:
  "   %m:    |{msg_id}| {msg} [{symbol}]
  " - 2nd efm string, ignores all (other) lines:
  "   %-G    means ignore
  "   %.%#   means .* and matches all (other) lines not matched previously
  " - quickfix syntax hihglighting should make Error codes (msg_id) standout
  au FileType python set makeprg=pylint3\ -rn\ -ftext\ --msg-template='{path}:{msg_id}:{line}:{column}:\|{msg_id}\|\ {msg}\ [{symbol}]'\ *.py
  " au FileType python set efm=%f:%t%n:%l:%c:%m,*%#\ %#%m
  au FileType python set efm=%f:%t%n:%l:%c:%m,%-G%.%#
augroup end

augroup OnColorScheme
au!
autocmd ColorScheme * hi Comment cterm=italic
augroup END


" MyFunctions: {{{1
" Show: {{{2
" Usage
" :Show map  -> show mappings in scratch tab
" :Show let b: -> shows buffer variables (also let s: let v: etc..)
command! -nargs=+ -complete=command Show call TabCmd(<q-args>)

function! TabCmd(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echoerr "no output"
  else
    " use "new" instead of "tabnew" below if you prefer split windows instead of tabs
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    call setline(1, a:cmd . ' ~>')
    call setline(2, '')
    call setline(3, '--')
    normal gg
    " silent normal nohl " <- causes errmsg if nothing was highlighted
    silent put=message
  endif
  nnoremap <buffer><silent>q :<c-u>q<cr><c-w>p
endfunction


" Shell: {{{2
" Run a script, capture output in scratch buffer.
command! -complete=shellcmd -nargs=+ Shell call RunShellCommand(<q-args>)


function! RunShellCommand(cmdline)
  "echo a:cmdline
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  " set q to quit the scratch buffer & return to previous window (previous position)
  nnoremap <buffer><silent>q :<c-u>q<cr><c-w>p
  call setline(1, a:cmdline . ' ~> ' . expanded_cmdline . ' :')
  call setline(2,substitute(getline(1),'.','=','g'))
  call setline(3,'')
  execute '$read !'. expanded_cmdline . ' 2>&1'
  " surround possible headerlines with empty lines
  silent g/^#/ s/^\|$//g
  " when used for ri <method>, reduce verbosity of "Implemenation from <class>"" headers
  " this is Ruby stuff, I know... perhaps check first is a:cmdline =~ 'ri' ...
  silent g/Implementation from/s///
  nohl
  setlocal nomodifiable
  setlocal ft=pandoc
  1
endfunction

" ShellTab: {{{2
" Run shell cmd, capture output in new tab
command! -complete=shellcmd -nargs=+ ShellTab call ShellCmdTab(<q-args>)

function! ShellCmdTab(cmdline)
  "echo a:cmdline
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  tabnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  " set q to quit the scratch buffer & return to previous window (previous position)
  nnoremap <buffer><silent>q :<c-u>q<cr><c-w>p
  call setline(1, expanded_cmdline . ' ~>')
  "call setline(2,substitute(getline(1),'.','=','g'))
  call setline(2,'')
  execute 'silent $read !'. expanded_cmdline
  " surround possible headerlines with empty lines
  silent g/^#/ s/^\|$//g
  " when used for ri <method>, reduce verbosity of "Implemenation from <class>"" headers
  " this is Ruby stuff, I know... perhaps check first is a:cmdline =~ 'ri' ...
  silent g/Implementation from/s///
  nohl
  setlocal nomodifiable
  setlocal ft=pandoc
  normal \v
  1
endfunction

" Repl: {{{2
function! ReplStart(module)
  " neoterm only starts a REPL through one of its TREPL commands, which always
  " send something straight to the REPL.  This function is ment to simply start
  " a REPL, with some settings and possibly some additional command.
  " - <space>t -> open REPL and import cWORD under cursor
  " - <space>r -> runs a command in the REPL
  " This replaces the manual:
  "   :T IEx.configure(default_prompt: "");clear
  "   :T recompile;clear;run
  "   :call g:neoterm.repl.exec(["IEx.configure(default_prompt\"\");clear;recompile;clear;run"])
  echom "starting iex> import >" . a:module . "<"
 if &filetype == 'elixir'
   let cmds = ["IEx.configure(default_prompt: \"\")", "clear"]
   if strlen(a:module)
     call add(cmds, "import " . a:module)
   endif
   call g:neoterm.repl.exec([join(cmds, ";")])
 else
   echom &filetype . " not (yet) supported by ReplStart()"
 endif
endfunction

function! ReplRun()
  " recompile and call main entry point run
 if &filetype == 'elixir'
   call g:neoterm.repl.exec(["recompile;clear;run"])
 else
   echom &filetype . " not (yet) supported by ReplRun()"
 endif
endfunction

" LUA for config: {{{1
lua <<EOF

  require"globals"
  require"plugins"
  require"setup.lsp"
  require"setup.symbols-outline"
  require"setup.lualine"
  require"keymappings"
  require"colors"
  require"options"

EOF
