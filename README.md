CSS Omni Complete Function for CSS3
===================================

Update the bult-in CSS complete function to latest CSS standard.

The latest stable file already in [vim repo][1], this repo will keep update for beta test.

[1]:https://github.com/vim/vim/blob/master/runtime/autoload/csscomplete.vim

Installation
------------

Use pathogen or vundle is recommended. Vundle:

    Plugin 'othree/csscomplete.vim'

### Configure

Set `omnifunc` to `csscomplete#CompleteCSS`

    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS noci

License
-------

Same as VIM
