" Setup Bundle Support {
" The next two lines ensure that the ~/.vim/bundle/ system works
	filetype off
	runtime! autoload/pathogen.vim
	silent! call pathogen#runtime_append_all_bundles()
" }

" Basics {
	set nocompatible 		" must be first line
	set background=dark     " Assume a dark background
" }

" General {
	syntax on
	filetype plugin indent on

	" In many terminal emulators the mouse works just fine, thus enable it.
	if has('mouse')
	  set mouse=a
	endif

	scriptencoding utf-8
	set autowrite
	set shortmess+=filmnrxoOtT     	" abbrev. of messages (avoids 'hit enter')
	set viewoptions=folds,options,cursor,unix,slash " better unix / windows compatibility
	set virtualedit=onemore 	   	" allow for cursor beyond last character
	set history=1000  				" Store a ton of history (default is 20)
	" set spell 		 	     	" spell checking on

	" Setting up the directories {
		set backup 						" backups are nice ...
        " Moved to function at bottom of the file
		set backupdir=$HOME/.vimbackup//  " but not when they clog .
		set directory=$HOME/.vimswap// 	" Same for swap files
		set viewdir=$HOME/.vimviews// 	" same but for view files

		"" Creating directories if they don't exist
		silent execute '!mkdir -p $HOME/.vimbackup'
		silent execute '!mkdir -p $HOME/.vimswap'
		silent execute '!mkdir -p $HOME/.vimviews'
		au BufWinLeave * silent! mkview  "make vim save view (state) (folds, cursor, etc)
		au BufWinEnter * silent! loadview "make vim load view (state) (folds, cursor, etc)
	" }	

	" where to find ctags
	let Tlist_Ctags_Cmd='/usr/bin/ctags'

	" When editing a file, always jump to the last known cursor position.
	" Don't do it when the position is invalid or when inside an event handler
	" (happens when dropping a file on gvim).
	" Also don't do it when the mark is in the first line, that is the default
	" position when opening a file.
	autocmd BufReadPost *
	  \ if line("'\"") > 1 && line("'\"") <= line("$") |
	  \   exe "normal! g`\"" |
	  \ endif
" }

" Vim UI {
	colorscheme blackboard
	set tabpagemax=15 				" only show 15 tabs
	set showmode                   	" display the current mode

	set cursorline  				" highlight current line
	hi cursorline guibg=#333333 	" highlight bg color of current line
	hi CursorColumn guibg=#333333   " highlight cursor

	if has('cmdline_info')
		set ruler                  	" show the ruler
		set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " a ruler on steroids
		set showcmd                	" show partial commands in status line and
									" selected characters/lines in visual mode
	endif

	if has('statusline')
		set laststatus=1           	" show statusline only if there are > 1 windows
		" Use the commented line if fugitive isn't installed
		"set statusline=%<%f\ %=\:\b%n%y%m%r%w\ %l,%c%V\ %P " a statusline, also on steroids
		set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
	endif

	set backspace=indent,eol,start 	" backspace for dummys
	set linespace=0 				" No extra spaces between rows
	set nu 							" Line numbers on
	set showmatch                  	" show matching brackets/parenthesis
	set incsearch 					" find as you type search
	set hlsearch 					" highlight search terms
	set winminheight=0 				" windows can be 0 line high
	set ignorecase 					" case insensitive search
	set smartcase 					" case sensitive when uc present
	set wildmenu 					" show list instead of just completing
	set wildmode=list:longest,full 	" comand <Tab> completion, list matches, then longest common part, then all.
	set whichwrap=b,s,h,l,<,>,[,]	" backspace and cursor keys wrap to
	set scrolljump=5 				" lines to scroll when cursor leaves screen
	set scrolloff=3 				" minimum lines to keep above and below cursor
	set foldenable  				" auto fold code
	set gdefault					" the /g flag on :s substitutions by default

" }

" Formatting {
	set nowrap                     	" wrap long lines
	set autoindent                 	" indent at the same level of the previous line
	set shiftwidth=4               	" use indents of 4 spaces
	set noexpandtab 	       		" tabs are tabs, not spaces
	set tabstop=4 					" an indentation every four columns
	"set matchpairs+=<:>            	" match, to be used with %
	set pastetoggle=<F12>          	" pastetoggle (sane indentation on pastes)
	"set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks

	" Ruby source file indentation should be, by convention, two spaces per tab
	" level {
		if has("autocmd")
			autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
		endif
	" }
" }

" Key Mappings {

	" Open BufExplorer in a new tab
	map ,b :tabnew<CR>:BufExplorer<CR>

	" Open the FuzzyFinderFile pane
	map <leader>f :FufFile<CR>

	" Easier moving in tabs and windows
	map <C-J> <C-W>j<C-W>_
	map <C-K> <C-W>k<C-W>_
	map <C-L> <C-W>l<C-W>_
	map <C-H> <C-W>h<C-W>_
	map <C-K> <C-W>k<C-W>_
	map <S-H> gT
	map <S-L> gt

	" ,v brings up my .vimrc
	" ,V reloads it -- making all changes active (have to save first)
	map ,v :tabe ~/.vimrc<CR><C-W>_
	map <silent> ,V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

	" Stupid shift key fixes
	cmap W w
	cmap WQ wq
	cmap wQ wq
	cmap Q q
	cmap Tabe tabe

	" Yank from the cursor to the end of the line, to be consistent with C and D.
	nnoremap Y y$

	" Shortcuts
	" Change Working Directory to that of the current file
	cmap cwd lcd %:p:h

	" Convenience remapping for Taglist
	nnoremap <silent> <F8> :TlistToggle<CR>
	
	" Don't use Ex mode, use Q for formatting
	map Q gq
	
	" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
	" so that you can undo CTRL-U after inserting a line break.
	inoremap <C-U> <C-G>u<C-U>

	" Automatically align Cucumber tables as they're being written.  Requires
	" Tabular plugin {
	inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

	function! s:align()
	  let p = '^\s*|\s.*\s|\s*$'
	  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
		let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
		let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
		Tabularize/|/l1
		normal! 0
		call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
	  endif
	endfunction
	" }

	" Allows the pretty printing of JSON.  Requires CPAN package JSON::XS
	map <leader>jt  <Esc>:%!json_xs -f json -t json-pretty<CR>
" }

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif
