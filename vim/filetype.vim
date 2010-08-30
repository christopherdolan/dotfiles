if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	au! BufRead,BufNewFile Gemfile	setfiletype ruby
augroup END
