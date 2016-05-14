"=============================================================================
" FILE: autoload/dein/command.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:ArgumentParser = vital#vital#import('ArgumentParser')
let s:String = vital#vital#import('Data.String')

let g:dein#command#debug = get(g:, 'dein#command#debug', 1)

let g:dein#command#subcommands = {
\   'install': {
\     'description': '[dein#install] install a plugin',
\   },
\   'direct-install': {
\     'description': '[dein#direct_install] install a plugin directly',
\   },
\ }

function! s:parser() abort
  if exists('s:parser') && !g:dein#command#debug
    return s:parser
  endif

  let s:parser = s:ArgumentParser.new({
  \   'name': 'Dein',
  \   'description': 'utility comamnds of dein.vim',
  \ })

  let max_sub_len = max(map(keys(g:dein#command#subcommands), 'len(v:val)'))
  let sub_description = values(map(copy(g:dein#command#subcommands),
  \ "s:String.pad_right(v:key, max_sub_len + 1) . v:val.description"))
  call s:parser.add_argument(
  \   'subcommand',
  \     ['A name of subcommand', ''] +
  \     sub_description +
  \     ['', 'Note that each sub-commands also have -h/--help option'],
  \   {
  \     'required': 1,
  \     'terminal': 1,
  \     'complete': function('dein#command#complete_subcommand'),
  \   }
  \ )

  return s:parser
endfunction

function! dein#command#command(bang, range, args) abort
  let parser = s:parser()
  let options = parser.parse(a:bang, a:range, a:args)
  if empty(options) || !has_key(options, 'subcommand')
    return
  endif
  let args = join(options.__unknown__)
  let subcommand = substitute(options.subcommand, '-', '_', 'g')
  try
    let r = dein#command#{subcommand}#command(a:bang, a:range, args)
    return r
  catch /^Vim\%((\a\+)\)\=:E117/
    " E117: Unknown function:
  endtry
endfunction

function! dein#command#complete(arglead, cmdline, cursorpos) abort
  let bang = a:cmdline =~# '^[^ ]\+!' ? '!' : ''
  let cmdline = substitute(a:cmdline, '^\s*[^ ]\+!\?\s', '', '')
  let cmdline = substitute(cmdline, '[^ ]\+$', '', '')

  let parser = s:parser()
  let options = parser.parse(bang, [0, 0], cmdline)
  if empty(options)
    return parser.complete(a:arglead, a:cmdline, a:cursorpos)
  endif
  if !has_key(options, 'subcommand')
    return []
  endif
  let subcommand = substitute(options.subcommand, '-', '_', 'g')
  try
    let r = dein#command#{subcommand}#complete(a:arglead, cmdline, a:cursorpos)
    return r
  catch /^Vim\%((\a\+)\)\=:E117/
    " E117: Unknown function:
  endtry
  return []
endfunction

function! dein#command#complete_subcommand(arglead, cmdline, cursorpos, ...) abort
  return filter(keys(g:dein#command#subcommands), 'v:val =~# ''^'' . a:arglead')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker