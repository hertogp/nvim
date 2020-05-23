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
" auto install plug.vim
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')

" Plug 'HerringtonDarkholme/yats.vim'
" Plug 'ap/vim-css-color'
" Plug 'hail2u/vim-css3-syntax'
" Plug 'heavenshell/vim-jsdoc'
" Plug 'https://github.com/godlygeek/tabular.git' " |-tables
" Plug 'mxw/vim-jsx'
" Plug 'othree/html5.vim'
" Plug 'othree/yajs.vim'
" Plug 'posva/vim-vue'
" Plug 'skwp/vim-html-escape'
"Plug 'autozimu/LanguageClient-neovim', { \'rev': 'next', \'do': 'bash install.sh' \}
Plug 'ervandew/supertab'

Plug 'NLKNguyen/papercolor-theme'
Plug 'neoclide/coc.nvim', {'do': 'yarn -install --frozen-lockfile'}
Plug 'Quramy/vison'
Plug 'Shougo/denite.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'Shougo/deoplete.nvim'
Plug 'Shougo/echodoc.vim'
Plug 'Shougo/neco-vim'
Plug 'Shougo/neoinclude.vim'
Plug 'SirVer/ultisnips'
Plug 'ajh17/Spacegray.vim'     " color scheme
Plug 'andymass/vim-matchup'        " jump around
Plug 'chemzqm/unite-location'      " qfix & location list sources
Plug 'davidhalter/jedi-vim', {'on_ft': 'python'}
Plug 'elzr/vim-json'
Plug 'fatih/vim-go'
Plug 'hertogp/dialk'               " K for help
Plug 'honza/vim-snippets'
Plug 'majutsushi/tagbar'           " navigate source code
Plug 'mattn/emmet-vim'
Plug 'neomake/neomake'             " async run makers/linters
Plug 'othree/jspc.vim', {'on_ft': ['javascript', 'javascript.jsx']}
Plug 'rstacruz/vim-closer'         " autoclose code constructs
Plug 'sbdchd/neoformat'            " requires formatters
Plug 'tomtom/tgpg_vim'         " used in pw <vault>
Plug 'tpope/vim-commentary'        " gc to (un)comment code
Plug 'tpope/vim-endwise'           " auto-end structures
Plug 'tpope/vim-fugitive'      " for statusline
Plug 'tpope/vim-surround'          " change surrounds easily
Plug 'ujihisa/neco-look'
Plug 'valloric/MatchTagAlways', {'on_ft': 'html'}
Plug 'vim-voom/VOoM'               " 2-pane outliner
Plug 'wolfgangmehner/lua-support'
Plug 'posva/vim-vue'
Plug 'elmcast/elm-vim'
Plug 'elixir-editors/vim-elixir'
Plug 'mhinz/vim-mix-format'
call plug#end()

let g:VIMDIR = expand('<sfile>:p:h')  " this scripts directory

function! MyVoomFiletypes() abort
  let repos = globpath(g:VIMDIR, '/plugged/**/voom_mode_*.py', 0, 1)
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


" CODING: {{{2
" TODO: start additional paths with ,?
set path+=,./include,/usr/include/linux
set path+=,/usr/include/x86_64-linux-gnu,/usr/local/include


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

" let g:coc_snippet_next = '<c-j>'
" let g:coc_snippet_prev = '<c-k>'

" augroup COCNVIM
"   au!
"   autocmd User CocNvimInit('runCommand', 'tsserver.watchBuild')
" augroup END

set signcolumn=yes
set updatetime=300
set cmdheight=2


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
set shiftwidth=2             " indent by 2 spaces
set tabstop=2                " dito
set softtabstop=2            " dito
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
"set completeopt+=longest

" Clipboard: sudo apt install xsel -> enables copy/paste from system clipboard
set clipboard=unnamed        " register * for yanking
set clipboard+=unnamedplus   " register + for all y,d,c & p ops
set list                     " show listchars for more visibility of stuff
set listchars=tab:·\ ,trail:-,precedes:<,extends:>  "show tabs, U+00B7 
nnoremap <F6> :set list!<CR>
set splitright               " new vsplit window to the right of curr window
" set fillchars=vert:|        " vertical window-split character (doesnt work?)

" softtabstop, shiftwidth and tabstop
au FileType vim set sts=2 sw=2 tabstop=2
au FileType javascript set sts=2 sw=2 tabstop=2
au FileType javascript.jsx set sts=2 sw=2 tabstop=2
au FileType go set sts=2 sw=2 tabstop=2

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
" -- I seem to loose buffer when switching with :Denite buffer?
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
" navigate errors TODO: prefers location list over quickfix (for now)
nnoremap <expr> <C-]> len(getloclist(0))==0 ? ':cnext<CR>z.' : ':lnext<CR>z.'
nnoremap <expr> <C-[> len(getloclist(0))==0 ? ':cprevious<CR>z.' : ':lprevious<CR>z.'
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
" R redo (u is undo)
nnoremap R <c-r>
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
" I never use macros
" nnoremap q <nop>

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
let g:netrw_browsex_viewer= "xdg-open"

" PLUGINS CONFIG: {{{1
filetype plugin indent on
syntax enable

" SYSTEM: {{{2
" PythonLib: {{{3
python <<EOF
#py3 <<EOF
# add (n)vim's pylib to sys.path
# no import sys -> it's already available
from os.path import expanduser, abspath
PYLIB = abspath(expanduser('~/.config/nvim/pylib'))
# sys.path.append(PYLIB)
sys.path.insert(0, PYLIB)
del expanduser, abspath
EOF

" TagBar: {{{3
let g:tagbar_left=1
nnoremap <space>t :TagbarToggle<cr>
let g:tagbar_type_elixir = {
    \ 'ctagstype' : 'elixir',
    \ 'kinds' : [
        \ 'p:protocols',
        \ 'm:modules',
        \ 'e:exceptions',
        \ 'y:types',
        \ 'd:delegates',
        \ 'f:functions',
        \ 'c:callbacks',
        \ 'a:macros',
        \ 't:tests',
        \ 'i:implementations',
        \ 'o:operators',
        \ 'r:records'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 'p' : 'protocol',
        \ 'm' : 'module'
    \ },
    \ 'scope2kind' : {
        \ 'protocol' : 'p',
        \ 'module' : 'm'
    \ },
    \ 'sort' : 0
\ }
" TgpgVim: {{{3
" the --no-use-agent is now an obsolete option, replacing it with --batch seems
" to stop de double confirmation pop-up's I was getting.
let g:tgpgOptions = '-q --batch --force-mdc --no-secmem-warning'


" CODING: {{{2

" Neomake: {{{3
" for async linting of code
" - F3 to run neomake manually for current filetype
" - neomake translates pylint msgs to Error, Warnings or Information
"    so Convention => Warning; does that for other filetypes as well

" Neomake Debugging (enable when/as needed)
" let g:neomake_logfile = expand('~/log/neomake.log')
" let g:neomake_verbose = 3

" auto-open the qf/ll list, but donot enter (2)
let g:neomake_open_list = 2                        " use :lw or :cw to open
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

" Neoformat: {{{3
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

" DialK: {{{3
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
" SuperTab: {{{3
autocmd FileType javascript let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:SuperTabClosePreviewOnPopupClose = 1
let g:SuperTabCrMapping=1
let g:SuperTabLongestHighlight=1
let g:SuperTabCompleteCase='ignore'  " not case sensitive completion
let g:SuperTabMappingForward = '<nul>'      " make <tab> do <c-n>
"let g:SuperTabMappingBackward = '<s-nul>'  " won't make <s-tab> do <c-p> ?
inoremap <expr><Esc> pumvisible() ? "\<C-e>" : "\<Esc>"



" CoC: {{{3
" Run :CocConfig to add language servers for specific languages
set hidden
set updatetime=300   " Smaller updatetime for CursorHold & CursorHoldI
set shortmess+=c     " don't give |ins-completion-menu| messages.
set signcolumn=yes   " always show signcolumns
let g:go_doc_url = 'https://pkg.go.dev'
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use `[g` and `]g` to navigate diagnostics
" nmap <silent> < <Plug>(coc-diagnostic-prev)
" nmap <silent> > <Plug>(coc-diagnostic-next)
" nnoremap > :call CocAction('diagnosticNext')<CR>z.
" nnoremap < :call CocAction('diagnosticPrevious')<CR>z.

" Remap keys for gotos
" dont touch gf for go-file
" :map g   to see all g-maps
" nnoremap gi <Plug>(coc-diagnostic-info)
" nnoremap gt <Plug>(coc-type-definition)
" nnoremap gi <Plug>(coc-implementation)
" nnoremap gh :call CocAction('doHover')<cr>
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)
nnoremap <silent> gl <Plug>(coc-diagnostic-prev)
nnoremap <silent> gh <Plug>(coc-diagnostic-next)
" Use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>
nnoremap <silent> B :GoDocBrowser<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" disable vim-go :GoDef short cut (gd) this is handled by LanguageClient
let g:go_def_mapping_enabled = 0
let g:LanguageClient_serverCommand = {
      \'vue': ['vls']
      \}

" UltiSnips: {{{3
let g:UltiSnipsExpandTrigger="<c-j>"

" EchoDoc: {{{3
let g:echodoc_enable_at_startup=1

" clean preview window
function! Preview_func()
  if &pvw
    setlocal nonumber norelativenumber
   endif
endfunction
autocmd WinEnter * call Preview_func()

" EDITING: {{{2
function! s:my_cursorline()
    " hilight cursorline when in 'denite' buffer, otherwise disable it.
    " call this function using autocmd events for entering/leaving windows
    " and buffers
    if &ft == "denite"
        hi CursorLine ctermbg=23
        setlocal cursorline
    else
        hi clear CursorLine
        setlocal nocursorline
    endif
endfunction
augroup CursorLine
    au!
    " always enable cursorline on entering a window, alsways disable it on
    " leaving the window -> cursorline is only active in 1 window
    au VimEnter,WinEnter,BufWinEnter * call s:my_cursorline()
    " we toggle on entering, so no (au WinLeave * setlocal nocursorline)
augroup END

" Denite: {{{3
" use ag for grepping files
augroup Denite
    au!
    autocmd FileType denite call s:denite_my_settings()

    function! s:denite_my_settings() abort
        nnoremap <silent><buffer><expr> <CR>
                    \ denite#do_map('do_action')
        " nnoremap <silent><buffer><expr> d
        "             \ denite#do_map('do_action', 'delete')
        nnoremap <silent><buffer><expr> p
                    \ denite#do_map('do_action', 'preview')
        nnoremap <silent><buffer><expr> q
                     \ denite#do_map('quit')
        nnoremap <silent><buffer><expr> i
                    \ denite#do_map('open_filter_buffer')
        " nnoremap <silent><buffer><expr> <Space>
        "             \ denite#do_map('toggle_select').'j'
        " setlocal cursorline
        " highlight CursorLine ctermbg=23
    endfunction

    autocmd FileType denite-filter call s:denite_filter_my_settings()

    function! s:denite_filter_my_settings() abort
        imap <silent><buffer> <C-o> <Plug>(denite_filter_quit)
        imap <silent><buffer> jj <Plug>(denite_filter_quit)
        inoremap <silent><buffer> <esc> <Plug>(denite_filter_quit)
        highlight clear CursorLine
    endfunction

augroup end

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

" set prompt from # to >
call denite#custom#option('default', 'prompt', '>')

" use jj to escape to normal mode & navigate candidates with jk up/down, eg:
" - jjq to go normal and quit
" - jjj to go normal and select next candidate
" call denite#custom#map('insert', 'jj', '<denite:enter_mode:normal>', 'noremap')
" call denite#custom#map('insert', 'jj', '<denite_filter_update>', 'noremap')

" Notes:
" - C-O to enter normal mode: hjkl to move between candidates
" - use <enter> to enter a directory, use q to go back (up)

" Nagivation: {{{2
" q (w/o space) returns to previous unite buffer (e.g. prev directory)
" <space><space> -> resume last unite buffer
nnoremap <space><space> :Denite -resume<cr>
nnoremap ,q :Denite -auto-resize quickfix<cr>
nnoremap ,l :Denite -auto-resize location_list<cr>

" Open Or Find Files:
" f browse to open a file, from current buffer dir
" F browse to Open a file, from project root dir.
nnoremap <space>f :DeniteBufferDir -start-filter file/rec<cr>
nnoremap <space>F :DeniteProjectDir -start-filter file/rec<cr>

" Grep Files:
" g grep for <pattern> in files under dir
" G grep for <pattern> in files under project dir
" # grep for word under cursor in files under dir
nnoremap <space>g :Denite -start-filter grep<cr>
nnoremap <space>G :DeniteProjectDir -start-filter grep<cr>
nnoremap <space># :DeniteCursorWord -start-filter grep<cr>

" search vim's help files
nnoremap <space>h :Denite help<cr>
nnoremap <space>H :DeniteCursorWord help<cr>

" Find In Buffers:
" the option -split='no' has a bug and makes windows showing a buffer disappear
nnoremap <space>l :Denite -start-filter line<cr>
nnoremap <space>o :Denite -input='FIXME\\|TODO\\|XXX\\|pdh:' line<cr>
nnoremap <space>w :DeniteCursorWord -start-filter line<cr>
nnoremap <space>c :Denite change<cr>
nnoremap <space>d :Denite -input='##' line<cr>

" Find Buffers:
" b - to list buffers
" B - to list ALL buffers
" nnoremap <space>b :Denite -split='no' buffer<cr>
nnoremap <space>b :Denite buffer<cr>
noremap <space>B :Denite buffer:!<cr>

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


" Exlixir {{{2
let g:neomake_elixir_enabled_makers = ['credo']
augroup Elixir
  au!
  autocmd BufWritePost *.exs silent :MixFormat
  autocmd BufWritePost *.ex silent :MixFormat
  autocmd BufWritePost * Neomake
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

