" ~/.config/nvim/init.vim  -- NVIM config (separate from vim)
" set runtimepath^=~/.vim runtimepath+=~/.vim/after
" Show script -> see order in which scripts are loaded

" -----------------------------------------------------------------
" TODO
" VOom -> add my own outline modes.py in ~/.config/nvim/pylib/voom
"  - for lua
"  - for html
"  - for css / sass
" -----------------------------------------------------------------


let &packpath = &runtimepath
set guicursor=

" PLUGINS INSTALL: {{{1
" Notes:
" - :Denite dein -> list of plugins & their branch + hash
" - Run "dein#recache_runtimepath()" if a plugin is disabled or modified
"   p> 

" DEIN START: {{{2
" dein.vim plugin manager
if(!isdirectory(expand("$HOME/.config/nvim/repos/github.com/Shougo/dein.vim")))
call system(expand("mkdir -p $HOME/.config/nvim/repos/github.com"))
call system(expand("git clone https://github.com/Shougo/dein.vim $HOME/.config/nvim/repos/github.com/Shougo/dein.vim"))
endif

set runtimepath+=~/.config/nvim/repos/github.com/Shougo/dein.vim/
call dein#begin(expand('~/.config/nvim'))
" DEIN: {{{3
call dein#add('Shougo/dein.vim')
call dein#add('haya14busa/dein-command.vim')

" SYSTEM: {{{2
" call dein#add('scrooloose/syntastic.git')    " syntax checker(s)
call dein#add('tpope/vim-fugitive.git')      " for statusline
call dein#add('tpope/vim-surround')          " change surrounds easily
call dein#add('tpope/vim-commentary')        " gc to (un)comment code

" VOoM: {{{3
call dein#add('vim-voom/VOoM')               " 2-pane outliner

" - :Voom mmode will import voom_mode_<mmode>.py from voom_vimplugin2657
"   package which creates the outline in Voom's treebuffer.
" - :Voom (no mmode aka markupmode) will lookup the mmode using the filetype
"   as key into the dict g:voom_ft_modes, which is empty by default (you have
"   to fill it yourself, mapping filetypes to desired markupmodes).
" - ./pylib subdir (also) contains a voom_vimplugin2657 subdir and it's
"   __init__.py turns voom_vimplugin2657 into a namespace, so private
"   markupmodes (voom_mode_<mymode>.py) in that dir are available to Voom.
" - if g:voom_ft_modes[&filetype] comes up empty, Voom uses g:voom_mode_default
"   as its default markupmode (usually fmr, unless you change it here).
" So:
" - we fill g:voom_ft_modes by scouring Voom's namespace and our own additions
"   by globbing for voom_mode_<mmode>.py files and adding mmode -> mmode
"   mappings to g:voom_ft_modes. Following this, we override some of the
"   automatic settings (rst -> wiki) or add aliases (cfg -> confg)
" - NB: using python to search voom_vimplugin2657's namespace will only find
"   our user/private module since voom's package is not on sys.path (yet).
" TODO:
" o add  a Voom outline mode for HLP files (eg for pydoc csv)
"
" Note: g:VIMDIR needs to be set inside init.vim, NOT inside the function!
" See https://superuser.com/questions/119991/how-do-i-get-vim-home-directory
" We'll pick up any voom_mode_<mmode>.py under repos, of any plugin therein.
let g:VIMDIR = expand('<sfile>:p:h')  " this scripts directory
function! MyVoomFiletypes() abort
let repos = globpath(g:VIMDIR, '/repos/**/voom_mode_*.py', 0, 1)
call map(repos, {k,v -> fnamemodify(v,':t')})  " keep tail (filename)
call map(repos, {k,v -> split(v, '[._]')[2]})  " keep mod's markupmode (*)
let pylib = globpath(g:VIMDIR, '/pylib/**/voom_mode_*.py', 0, 1)
call map(pylib, {k,v -> fnamemodify(v,':t')})
call map(pylib, {k,v -> split(v, '[._]')[2]})
let ft2modes = {}
" make sure private pylib comes last so it overrides any repos/markupmodes
for mode in extend(repos, pylib)
  let ft2modes[mode] = mode
endfor
return ft2modes
endfunction

let g:voom_ft_modes = MyVoomFiletypes()
" override some entries
" mypython so comments like # -- start a headline
" cfg/confg is for cisco config files (from tftpboot)
for [k,v] in items({
    \'python': 'mypython',
    \'rest': 'wiki',
    \'rst': 'wiki',
    \'txt': 'pandoc',
    \'markdown': 'pandoc',
    \'cfg': 'confg',
    \})
let g:voom_ft_modes[k] = v
endfor

" with g:voom_ft_modes properly filled, we can now do simple :Voom[Toggle]
nnoremap <silent> <space>v :VoomToggle<cr>
" JK move down/up w/ select by (re)mapping onto <down>/<up>
au FileType voomtree nmap <silent><buffer>J <down>
au FileType voomtree nmap <silent><buffer>K <up>
" confg filetype for Voom's confg outline mode
augroup filetypedetect
au BufNewFile,BufRead *confg set ft=confg
au BufNewFile,BufRead *confg.txt set ft=confg
au BufNewFile,BufRead *.asy set ft=asy
au BufNewFile,BufRead *.csv set ft=csv
augroup END

call dein#add('majutsushi/tagbar')           " navigate source code
call dein#add('tomtom/tgpg_vim.git')         " used in pw <vault>

" CODING: {{{2
call dein#add('neomake/neomake')             " async run makers/linters
call dein#add('sbdchd/neoformat')            " requires formatters
call dein#add('tpope/vim-endwise')           " auto-end structures
call dein#add('rstacruz/vim-closer')         " autoclose code constructs
call dein#add('andymass/vim-matchup')        " jump around
call dein#add('hertogp/dialk')               " K for help

" COMPLETTION: {{{2
call dein#add('Shougo/deoplete.nvim')  " gonna try coc.nvim

" COC NVIM: {{{3
" https://github.com/neoclide/coc.nvim
" ----------------------------------------------------------------------
" Install node and yarn. To install yarn on cli:
" % curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
" % echo "deb https://dl.yarnpkg.com/debian/ stable main" \
"   | sudo tee /etc/apt/sources.list.d/yarn.list
" % sudo apt-get update && sudo apt-get install yarn
" NB:
"  - yarn doesnt like npm's package-lock.json (delete it)
"  - run 'yarn' in your project -> yarn.lock
" ----------------------------------------------------------------------
" COC:
" {'build': 'yarn install'} -> only runs on Install, not update
" ~/.config/coc holds extensions installed by CocInstall <extension>
" CocInstalled: coc-html coc-css coc-json coc-tsserver coc-pyls

" call dein#add('neoclide/coc.nvim', {
"       \'build': 'yarn install'
"       \})
" let g:coc_snippet_next = '<c-j>'
" let g:coc_snippet_prev = '<c-k>'

" augroup COCNVIM
"   au!
"   autocmd User CocNvimInit('runCommand', 'tsserver.watchBuild')
" augroup END

set signcolumn=yes
set updatetime=300
set cmdheight=2

" goto keys
" dont touch gf for go-file
" :map g   to see all g-maps
" nnoremap gi <Plug>(coc-diagnostic-info)
" nnoremap gd <Plug>(coc-definition)
" nnoremap gr <Plug>(coc-references)
" nnoremap gt <Plug>(coc-type-definition)
" nnoremap gi <Plug>(coc-implementation)
" nnoremap [c <Plug>(coc-diagnostics-prev)
" nnoremap ]c <Plug>(coc-diagnostics-next)
" nnoremap gh :call CocAction('doHover')<cr>
" nnoremap gR <Plug>(coc-rename)



call dein#add('ervandew/supertab')
call dein#add('SirVer/ultisnips')
call dein#add('honza/vim-snippets')
call dein#add('autozimu/LanguageClient-neovim', {
      \'rev': 'next',
      \'do': 'bash install.sh'
      \})

let js_opts = {'on_ft': ['javascript', 'javascript.jsx']}
call dein#add('othree/jspc.vim', js_opts)
let js_opts = {
      \'on_ft': ['javascript', 'javascript.jsx'],
      \'build': 'npm install'}

" jedi     -> https://github.com/davidhalter/jedi
" jedi-vim -> https://github.com/davidhalter/jedi-vim
call dein#add('davidhalter/jedi-vim', {'on_ft': 'python'}) " python

call dein#add('Shougo/neco-vim')
call dein#add('Shougo/neoinclude.vim')
call dein#add('ujihisa/neco-look')
call dein#add('Shougo/echodoc.vim')



" EDITING: {{{2
call dein#add('Shougo/denite.nvim')          " the new unite
call dein#add('chemzqm/unite-location')      " qfix & location list sources
call dein#add('https://github.com/godlygeek/tabular.git') " |-tables

" LUA {{{2
call dein#add('wolfgangmehner/lua-support')

" JAVASCRIPT: {{{2
call dein#add('othree/yajs.vim')
call dein#add('mxw/vim-jsx')
call dein#add('heavenshell/vim-jsdoc')
call dein#add('elzr/vim-json')
call dein#add('HerringtonDarkholme/yats.vim')
call dein#add('Quramy/vison')

" PYTHON: {{{2
" Preparation:
" % sudo -H pip3 install jedi python-language-server

" HTML: {{{2
call dein#add('othree/html5.vim')
call dein#add('mattn/emmet-vim')
call dein#add('valloric/MatchTagAlways', {'on_ft': 'html'})
call dein#add('posva/vim-vue')
call dein#add('skwp/vim-html-escape')

" CSS: {{{2
call dein#add('hail2u/vim-css3-syntax')
call dein#add('ap/vim-css-color')

" SASS: {{{2

" COLORS: {{{2
call dein#add('ajh17/Spacegray.vim.git')     " color scheme

" Dein AutoInstall: {{{2
if dein#check_install()
  call dein#install()
  let pluginsExist=1
endif

" DEIN END: {{{2
call dein#end()
" call dein#recache_runtimepath()  " if a plugin is disabled or modified
call dein#save_state()


" PLUGINS CONFIG: {{{1
filetype plugin indent on
syntax enable

" SYSTEM: {{{2
" PythonLib: {{{3
py3 <<EOF
# add (n)vim's pylib to sys.path
# no import sys -> it's already available
from os.path import expanduser, abspath
PYLIB = abspath(expanduser('~/.config/nvim/pylib'))
sys.path.append(PYLIB)
del expanduser, abspath
EOF

" VimFugitive:
" VimSurround:
" VimCommentary:

" VOoM: {{{3

" TagBar: {{{3
let g:tagbar_left=1
nnoremap <space>t :TagbarToggle<cr>

" TgpgVim:


" CODING: {{{2
" Dein:
nnoremap <space><F8> :call dein#recache_runtimepath()<cr>


" Neomake: for async linting of code
" - F3 to run neomake manually for current filetype
" - neomake translates pylint msgs to Error, Warnings or Information
"    so Convention => Warning; does that for other filetypes as well

" Neomake Debugging (enable when/as needed)
" let g:neomake_logfile = expand('~/log/neomake.log')
" let g:neomake_verbose = 3

let g:neomake_open_list = 1                        " use :lw or :cw to open
let g:neomake_list_height = 20                     " lines in location window
" default makers for <filetypes>
let g:neomake_javascript_enabled_makers = ['eslint']
" eslint: a javascript linter
" - setup eslint externally
" - eslint --init                                  # in project root dir
" - will install extra devDependencies ...         # bah
" - creates .eslintrc.json                         # or js or yaml
"   { "extends": "airbnb-base",
"                                                  # add some rule:
"     "rules": [ "error", "double", {              # - dumb default
"                 "avoidEscape": true,             # - play nice w/ prettier
"                 "allowTemplateLiterals": true    #   dito
"                 }
"              ]
"   }
let g:neomake_scss_enabled_makers = ['stylelint']
" stylelint: css,scss,sass,less,sugarSS linter
" - setup stylelint externally:
" - npm -g i stylelint                             # global stylelint
" - npm i stylelint-config-recommended --save-dev  # dev install config
" - add .stylelintrc in your project dir:          # project specific
"   { "extends": "stylelint-config-recommended" }
" - npm -g i styleling-config-recommend #=> provide abs path in .stylelintrc

" use pylint3 rather than pylint, use flake8 as well (file-mode)
let g:neomake_python_pylint_exe = 'pylint3'
let g:neomake_python_enabled_makers = ['pylint', 'flake8']

" Neomake picks up on filetype & runs an assigned maker for you
nnoremap <space>? :call MyNeomakeVar('current_errors')<cr>
nnoremap <f2> :Neomake<cr>
nnoremap <space><f2> :NeomakeClean<cr>
nnoremap <f3> :Neomake! makeprg<cr>
nnoremap <space><f3> :NeomakeClean!<cr>
" nicer qf/ll-window contents
call neomake#quickfix#enable()



" Neoformat:
" Requires external formatters, e.g.
" - npm -g install prettier # for js, html, css etc..
" - sudo -H pip3 install yapf  # for python
" - run eslint --init in your project dir (prefer JSON as format):
"   - add some rules to .eslint.json, like:
"     "no-console": 0;

" prettier:
" - npm -g install prettier                       # global install
" - .prettierrc                                   # in project dir
"   { "singleQoute": true }                       # if you want all 's
" - prettier prefers "s, eslint prefers 's
let g:standard_prettier_settings = {
            \ 'exe': 'prettier',
            \ 'args': ['--stdin', '--stdin-filepath', '%:p'],
            \ 'stdin': 1,
            \ }
let g:neoformat_javascript_prettier = g:standard_prettier_settings
let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_scss_prettier = g:standard_prettier_settings
let g:neoformat_enabled_scss = ['prettier']
let g:neoformat_json_prettier = g:standard_prettier_settings
let g:neoformat_enabled_json = ['prettier']

let g:jsx_ext_required = 0
let g:jsx_ext_required = 1
let g:jsdoc_allow_input_prompt = 1
let g:jsdoc_input_description = 1
let g:jsdoc_return=0
let g:jsdoc_return_type=0

let g:vim_json_syntax_conceal = 0

" if syntactically incorrect, prettier won't run (ie fails)
nnoremap ,f :Neoformat<cr>

" Vim Matchup:
" DialK:
" TODO
" o restore <s-k> mapping to dialk, for now go with <space>k
"   since vim-jedi insists on using <s-k>.
" o Neovim itself is setting python's keywordprg to pydoc
"   - https://github.com/neovim/neovim/blob/master/runtime/ftplugin/python.vim
"   - so we'll set it here to pydoc3, but should actually use a func
"     that falls back to pydoc?
"   see he:VimEnter:
nnoremap <space>k :<c-u>call DialK(mode())<cr>
augroup DialKGroup
au!
au FileType python set keywordprg=pydoc3
augroup end


" COMPLETION {{{2
" SuperTab:
autocmd FileType javascript let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:SuperTabClosePreviewOnPopupClose = 1

" LanguageClient:
" for denite users, some sources are available:
" - codeAction      list ?
" - contextMenu     list menu entries
" - documentSymbol  list of symbols to goto
" - references      list of references
" - workspaceSymbol list of project symbols
let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
    \'javascript': ['javascript-typescript-stdio'],
    \'javascript.jsx': ['javascript-typescript-stdio'],
    \'typescript': ['javascript-typescript-stdio']
    \}

nnoremap <silent> ,h :call LanguageClient#textDocument_hover()<cr>
nnoremap <silent> ,d :call LanguageClient#textDocument_definition()<cr>
nnoremap <silent> ,i :call LanguageClient#textDocument_implementation()<cr>
nnoremap <silent> ,F :call LanguageClient#textDocument_formatting()<cr>
nnoremap <silent> ,s :Denite documentSymbol<cr>
nnoremap <silent> ,S :Denite workspaceSymbol<cr>
nnoremap <silent> ,r :Denite refecences<cr>



" UltiSnips
let g:UltiSnipsExpandTrigger="<c-j>"
inoremap <esc><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" EchoDoc:
let g:echodoc_enable_at_startup=1


" clean preview window
function! Preview_func()
  if &pvw
    setlocal nonumber norelativenumber
   endif
endfunction
autocmd WinEnter * call Preview_func()

" NecoVim:
" NeoInclude:
" NecoLook:
" EchoDoc:



" EDITING: {{{2
" Denite: {{{3
" use ag for grepping files
call denite#custom#var('grep', 'command', ['ag'])
call denite#custom#var('grep', 'default_opts', ['-i', '--vimgrep'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])
" see also .gitignore files for more inspiration
call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
    \ ['.git', '__pycache__', 'venv', 'img', '*.min.*', 'node_modules',
    \  'dist', 'build', '*.swp', '.cache*'])
" narrow grep'd source also by path
call denite#custom#source('grep', 'converters', ['converter/abbr_word'])

" set prompt from # to >, doesn't seem to work?
call denite#custom#option('default', 'prompt', '%')

" use jj to escape to normal mode & navigate candidates with jk up/down, eg:
" - jjq to go normal and quit
" - jjj to go normal and select next candidate
call denite#custom#map('insert', 'jj', '<denite:enter_mode:normal>', 'noremap')


" Notes:
" - C-O to enter normal mode: hjkl to move between candidates
" - use <enter> to enter a directory, use q to go back (up)
" - lowercase = withbufferdir, uppercase = currentworkingdir

" Nagivation:
" q (w/o space) returns to previous unite buffer (e.g. prev directory)
" <space><space> -> resume last unite buffer
nnoremap <space><space> :Denite -resume<cr>
nnoremap ,q :Denite -mode=normal -auto-resize quickfix<cr>
nnoremap ,l :Denite -mode=normal -auto-resize location_list<cr>

" Open Or Find Files:
" f browse to open a file, from current buffer dir
" F browse to Open a file, from project root dir.
nnoremap <space>f :DeniteBufferDir -mode=insert file/rec<cr>
nnoremap <space>F :DeniteProjectDir -mode=insert file/rec<cr>

" Grep Files:
" g grep for <pattern> in files under dir
" G grep for <pattern> in files under project dir
" # grep for word under cursor in files under dir
nnoremap <space>g :Denite grep<cr>
nnoremap <space>G :DeniteProjectDir grep<cr>
nnoremap <space># :DeniteCursorWord -mode=normal grep<cr>

" search vim's help files
nnoremap <space>h :Denite help<cr>
nnoremap <space>H :DeniteCursorWord help<cr>

" Find In Buffers:
" <space><letter>
" l filter lines in buffer, type filter yourself
nnoremap <space>l :Denite -split='no' -mode=insert line<cr>
" o filter lines for open issues in source
nnoremap <space>o :Denite -split='no' -input='FIXME\|TODO\|XXX\|pdh:' -mode=normal line<cr>
" w filter lines in buffer using word under cursor
nnoremap <space>w :DeniteCursorWord -mode=normal line<cr>
" c show lines that have been changed
nnoremap <space>c :Denite change<cr>

" Find Buffers:
" b - to list buffers
" B - to list ALL buffers
nnoremap <space>b :Denite -mode=normal buffer<cr>
nnoremap <space>B :Denite -mode=normal buffer:!<cr>


" Tabular:
" From https://gist.github.com/tpope/287147
" aligns table using Tabular on ' | '-character (need the spaces!)
" - | symbols should be separated from text with 1+ spaces!
nnoremap <leader>t  :call TabularAlign()<cr>
inoremap <silent> <Bar>   <Bar><Esc>:call TabularAlign()<CR>a

function! TabularAlign()
let p = '^\s*|\s.*\s|\s*$'
if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
  let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
  let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
  Tabularize/|/l1
  normal! 0
  call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
endif
endfunction

" LUA {{{2
" https://github.com/WolfgangMehner/lua-support
augroup Lua
au!
au FileType lua
      \ set tw=79 sw=2 ts=2 fo-=cro |
      \ let b:closer = 1 |
      \ let b:closer_flags = '([{'
augroup end

" JAVASCRIPT: {{{2
augroup JS
au!
au FileType javascript set tw=79 sw=2 ts=2
augroup end

" VimJSX:
" VimJSDoc:
" VimJSON:

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

" JediVim:
" disable jedi-vim completion in favor of deoplete-jedi
" let g:jedi#completions_enabled = 0


" HTML: {{{2

" Html5:
" Emmet:
" use tab to complete Emmet expandable stuff
function! s:expand_html_tab()
" Remapping <C-y>, just doesn't cut it.
" try to determine if we're within quotes or tags.
" if so, assume we're in an emmet fill area.
 let line = getline('.')
 if col('.') < len(line)
   let line = matchstr(line, '[">][^<"]*\%'.col('.').'c[^>"]*[<"]')
   if len(line) >= 2
      return "\<C-n>"
   endif
 endif
" expand anything emmet thinks is expandable.
if emmet#isExpandable()
  return emmet#expandAbbrIntelligent("\<tab>")
  " return "\<C-y>,"
endif
" return a regular tab character
return "\<tab>"
endfunction
" let g:user_emmet_expandabbr_key='<Tab>'
" imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

autocmd FileType html,css,scss,typescript.tsx imap <silent><buffer><expr><tab> <sid>expand_html_tab()
let g:user_emmet_mode='a'
let g:user_emmet_complete_tag = 0
let g:user_emmet_install_global = 0
autocmd FileType html,css,scss EmmetInstall

" MatchTagAlways:
" VimVue:
" VimHtmlEscape:


" CSS: {{{2
" VimCss3Syntax:
" VimCssColor:


" SASS: {{{2

" COLORS: {{{2
" TODO

" VIM CONFIG: {{{1
" Generic: {{{2
" new candidates:
set hlsearch                " highlight search results
set autoindent              " indent a new line the same amount as the line just typed
set wildmode=longest,list   " get bash-like tab completions
set cc=80                   " set an 80 column border for good coding style
set complete=.,w,b,u,t,k

" trusted settings
let mapleader='\'            " its the default, use it as map <leader> ...
set nocompatible             " no vi compatible, this first! for side-effects
" set nowrap                   " don't wrap long lines to fit screen
set whichwrap=b,s,<,>,[,]    " [back]space, <left>,<right> all wrap
set sidescroll=10            " ensure some context when scrolling
set backspace=indent,eol,start  " backspace over these in insert mode
set smartindent              " autoindent new lines, for c-like programs 
set shiftwidth=4             " the python pep8 standard
set tabstop=4                " dito
set softtabstop=4            " dito
set expandtab                " use spaces, for tab press ctl-V<tab>
set history=50               " prevent large viminfo files
set textwidth=79             " will be overriden for specific file types
set formatoptions=tcrqn2j
set mouse=a                  " enable mouse in most modes
set history=50               " keep 50 lines of command line history
set number                   " show line numbers
set numberwidth=4            " line number column width
set ruler                    " show the cursor position all the time
set showcmd                  " display incomplete commands
set noshowmode               " current mode already display in statusline
set incsearch                " do incremental searching
set laststatus=2             " last window always has a status line
set showmatch                " Show matching brackets.
set ignorecase               " case insensitive matching
set smartcase                " unless if there's a Capital letter
set autowrite                " autosave before commands like :next and :make
set hidden                   " hide buffers when they are abandoned
set wildmenu                 " show cmd autocompletion in statusline
set lazyredraw               " don't redraw during macro execution

" Clipboard: sudo apt install xsel -> enables copy/paste from system clipboard
set clipboard=unnamed        " register * for yanking
set clipboard+=unnamedplus   " register + for all y,d,c & p ops

set list                     " show listchars for more visibility of stuff
set listchars=tab:>~,trail:-,precedes:<,extends:>  "show tabs and stuff.
set splitright               " new vsplit window to the right of curr window

au FileType vim set sts=2 sw=2 tabstop=2
au FileType javascript set sts=2 sw=2 tabstop=2
au FileType javascript.jsx set sts=2 sw=2 tabstop=2

" Colors: {{{2
if &t_Co > 2 || has("gui_running")
set hlsearch               " highlight search
set background=dark
set t_Co=256
colorscheme spacegray
syntax on                  " syntax highlighting
set cursorline             " highlight current line
highlight CursorLine  ctermbg=234
highlight ColorColumn ctermbg=DarkGrey ctermfg=white
call matchadd('ColorColumn','\%81v', 100) " only color 81st column
hi Pmenu    term=None cterm=italic ctermfg=lightgrey ctermbg=darkgrey "250 ctermbg=10
hi PmenuSel term=None cterm=italic ctermfg=lightgrey ctermbg=darkblue
hi LineNr ctermfg=239 ctermbg=234
endif

augroup OnColorScheme
au!
autocmd ColorScheme * hi Comment cterm=italic
augroup END

if has("gui_running")
  " gui seems slow, turn some stuff off
  "set nowrap
  colorscheme spacegray
  set scrolljump=5
  set noshowcmd
endif


" Statusline: {{{2
" - define custom colors, so this goes after call to colorscheme
" See http://www.vim.org/scripts/script.php?script_id=3412
" Dld'd to ~/Downloads/vim/xterm-color-table
hi User1 ctermfg=15   ctermbg=88              " white/red:modified/RO flags
hi User2 ctermfg=190  ctermbg=65              " yellow/green: [filetype]
hi User3 ctermfg=190  ctermbg=65 cterm=italic " (fugitive#head)
hi User4 ctermfg=190  ctermbg=65              " [MODE]
hi StatusLine  ctermfg=251 ctermbg=241        " The current window
hi StatusLineNC ctermbg=242 ctermfg=249       " inactive window greyed out
au InsertEnter * hi User3 ctermbg=65 ctermfg=190 cterm=italic
au InsertEnter * hi User4 ctermbg=190 ctermfg=65
au InsertLeave * hi User3 ctermbg=65 ctermfg=190 cterm=none
au InsertLeave * hi User4 ctermbg=65 ctermfg=190 cterm=none


"# echo fugitive#extract_git_dir('.') -> full path to root .git dir
"# echo fnamemodify(fugitive#extract_git-dir('.'),":p:h") -> relative to cur dir
"use expand('%:p') to make it relative to current buffer's filename
function! SL_git_info() abort
  if !exists('b:git_dir')
      return ''
  endif
  let info= fnamemodify(b:git_dir,':h:t')
  let info.= "(" . fugitive#head() . ")"
  "return fnamemodify(b:git_dir,':h:t') . " (" . fugitive#head() . ")"
  return info
endfunction

function! SL_neomake() abort
" give a proper count of issues in location/quickfix lists
let larr = []
for item in sort(items(neomake#statusline#LoclistCounts()))
  call add(larr, join(item, ":"))
endfor
let qarr = []
for item in sort(items(neomake#statusline#QflistCounts()))
  call add(qarr, join(item, ":"))
endfor
let sl = ""
if len(larr)
  let sl .= "l[".join(larr, ",")."]"
endif
if len(qarr)
  let sl .= " q[".join(qarr, ",")."]"
endif

" TODO just use these to build a Neomake StatusLine fragment?
let a = neomake#statusline#LoclistStatus()
let b = neomake#statusline#QflistStatus()
let c = [ len(a) ? 'll[' . a .']' : a, len(b) ? 'qf['.b.']' : '' ]
return tolower(join(filter(c, 'len(v:val)'), ' '))



let c = len(a) ? ' l[' . a .'] ' : ''
let c = len(b) ? c . 'q[' . b . '] ' : c
return c

if (len(a))
  let c = ' l[' . a . ']'
endif
if len(b)
  let c = c . ' q[' . b . ']'
endif
return len(c) ? c .' ' : c

let sl = sl . ' | ' . neomake#statusline#LoclistStatus() . ' | '
let sl = sl . neomake#statusline#QflistStatus() . ' |'
return len(sl) ? " " . sl . " " : sl
endfunction

set statusline=""                              " start out blank
set statusline+=%2*                            " normal color for opening [
set statusline+=%4*\                           " MODE color (changes on insert) 
set statusline+=%{mode()==?'n'?'NORMAL':''}    " mode
set statusline+=%{mode()==?'i'?'INSERT':''}
set statusline+=%{mode()==?'v'?'VISUAL':''}
set statusline+=%2*\                            " normal color ] [
set statusline+=\[%{toupper(&ft)}]              " * file type
set statusline+=\ %1*%{SL_neomake()}
set statusline+=\%2*%{SL_git_info()}             " current git repo name
set statusline+=%2*\                           " - switch to User1 (see :hi)
set statusline+=%1*%{&modified?'+':''}         " * +  flag (no leading ,)
set statusline+=%{&readonly?'!!':''}           " * !! flag (not 'RO')
set statusline+=%*                             " - switch back to default colors
set statusline+=\ #%n                          " * buffer number
set statusline+=\ %F                           " * full filename
set statusline+=%=                             " right align
set statusline+=%l:%c                          " line(Lines):column
set statusline+=\ \ %02p%%                     " at approx. perc through the file
set statusline+=\ \ %{&encoding}               " * file encoding
set statusline+=\ [%{&fileformat}]

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
augroup QuitNoFile
au!
" Notes:
" - sometimes buftype gets set after the bufenter event
" au bufenter * if &buftype=='nofile'|nnoremap <buffer> q <esc>:q<cr>|endif
"" -- I seem to loose buffer when switch with denite via <space>b ...???
"au FileType nofile, qf nnoremap <buffer> q <esc>:q<cr><c-w>p
"au syntax * if &buftype=='nofile'|nnoremap <buffer> q <esc>:q<cr>|endif
"au syntax * if &buftype=='quickfix'|nnoremap <buffer> q <esc>:q<cr>|endif
"au syntax * if &buftype=='help'|nnoremap <buffer> q <esc>:q<cr>|endif
"au syntax * if &syntax == 'man'|nnoremap <buffer> q <esc>:q<cr>|endif
au syntax * if bufname('%')=='__doc__'|nnoremap <buffer> q <esc>:q<cr>|endif
au syntax * if bufname('%')=='[Scratch]'|nnoremap <buffer> q <esc>:q<cr>|endif
augroup end

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

" KEYMAPS: {{{1
" Generic: {{{2
" TODO
nnoremap <f5> :redraw!<cr>
nnoremap <f8> :echom 'pos:(' . line(".") . "," . col(".") . ")"
    \. ' -> hi:<'
    \. synIDattr(synID(line("."),col("."),1),"name")
    \. '>, transparent:<'
    \. synIDattr(synID(line("."),col("."),0),"name")
    \. '>, local:<'
    \. synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
    \. '>'<CR>

" Move: {{{2
" Shift-H/L move tabs left/right
" Ctl-jhklp move up/left/down/right/previous window
nnoremap H :<c-u>tabprevious<cr>
nnoremap L :<c-u>tabnext<cr>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-h> <c-w>h
nnoremap <c-p> <c-w>p
" Keep stuff centered while navigating
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap <c-o> <c-o>zz
nnoremap <c-i> <c-i>zz
nnoremap <c-u> <c-u>zz
nnoremap <c-d> <c-d>zz
nnoremap g, g,zz
nnoremap g: g;zz

" Edit: {{{2
" <c-s> to write buffer if it's been modified (ie :update instead of :write)
" Requires the terminal to give up its claim on <c-s> via stty -ixon
" Or use a .bashrc function to call vim which toggles this, see
" http://vim.wikia.com/wiki/Map_Ctrl-S_to_save_current_or_new_files

" easy access to ex cmd line, ; doesn't have a normal mode mapping anyway
nnoremap ; :
" <c-S> is seen as <c-s>? Dunno how this happens ..
inoremap <c-s> <esc>:update<CR>
nnoremap <c-s> <esc>:update<CR>
" turnoff highlighted search
nnoremap <c-n> :nohl<CR>
" U redo (u is undo)
nnoremap U <c-r>
nnoremap <leader>ev :edit $HOME/.config/nvim/init.vim<cr>
nnoremap <leader>sv :source $HOME/.config/nvim/init.vim<cr>
nnoremap <leader>n  :cn<cr>
" escape to normal mode
inoremap jj <ESC>
" Use :W to write a file you opened with sudo (you'll need sudo rights)
command! W  execute 'silent w !sudo tee % % > /dev/null' | :edit!
" yank till end-of-line (like D deletes to eol)
nnoremap Y y$
" reformat paragraph, start at cursor. {Q to reformat whole paragraph
nnoremap Q gq}
nnoremap q <nop> |" never use macros

" Alt-j as opposite of Shift-J (ie split lines instead of join lines)
" Alt key actually maps to \033 (type sed -n l, then Alt-j -> \033j
" so an alternate mapping could be nnoremap <esc>[033j i
" nnoremap j i<esc>
nnoremap <M-j> i<esc>

" Completion:
" -----------
" Use generic completion such that we can continue typing to refine the list
" Trick comes from Practical Vim
" Note the noremap!
inoremap <c-p> <c-p><c-n>|" invoke keyword completion & reverto current word
inoremap <c-n> <c-n><c-p>

" open url even if quouted 'http://www.google.nl'
" nnoremap ww <plug>NetrwBrowseX("<cfile>")


" MyFunctions: {{{1
" Show: {{{2
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

