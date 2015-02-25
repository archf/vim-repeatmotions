" File: repeatmotions.vim
" Author: Felix Archambault <fel.archambault at gmail dot com>
" Description: Overload the semicolon ';' so it works with other motions

if exists('g:loaded_repeatmotions') || !has('eval') || &cp
    finish
endif
let g:loaded_repeatmotions = 1

" contains movement keys we want to make repeatable
let g:active_keys = {}
" dict containing mapping as expected in the 'map' output
let g:mapping_dict = {}
let g:last_motion = ''

function! s:repeat()
  if g:last_motion ==? 't' || g:last_motion ==? 'f'
    call  sendkeys(";", v:count)
  else
    call  sendkeys(a:last_motion, v:count)
  endif
endfunction

function! s:reverserepeat()
  if g:last_motion ==? 't' || g:last_motion ==? 'f'
    call  sendkeys(",", v:count)
  else
    " look in the active_keys dict for the reverse motion
    let s:keyseq = get(g:active_keys,g:last_motion)
    if !empty(keyseq)
      call  sendkeys(s:keyseq, v:count)
    endif
  endif
endfunction

function! s:sendkeys(sequence)
  " echo 'test'
  " echo 'aa' . a:sequence . 'bb'
  " add the motion to the most recent motion variable local to buffer
  " set verbose=20
  " set verbose=0
  echo  'this is the current motion: ' . a:sequence
  " echo  ' this was the previous motion: ' . g:last_motion
  let g:last_motion = a:sequence
  " echo v:count g:last_motion

  call feedkeys((v:count ? v:count : '') . a:sequence, 'n')

  " exe 'normal! ' a:sequence
  " send keys to the typeahead buffer
  " call feedkeys(v:count . a:sequence, 'm')
  " call feedkeys(v:count . a:sequence, 'm')
endfunction

" backwards: {lhs} of the mapping to move the cursor backwards
" forwards: {lhs} of the mapping to move the cursor forwards
function! Addkeys(bwd,fwd)
  let defaultMaparg = { 'mode': '', 'noremap': 1, 'buffer': 0, 'silent': 0, 'expr': 0, 'nowait': 0 }

  " mapping command
  " let mapstring = 'noremap <expr>'

  " init
  " let maparg = maparg(a:bwd, '', 0, 1)
  " let maparg = maparg(a:fwd, '', 0, 1)
  "       let mapstring .= ' <buffer>'
  "         let mapstring .= ' <silent>'

  " make sure we do not add each key par twice
  if has_key(g:active_keys,a:bwd) || has_key(g:active_keys,a:fwd)
    echoerr a:bwd 'and' a:fwd ' key pair already added to repeatable key list'
    return
  else
    " let g:active_keys[a:bwd] = a:fwd
    " let g:active_keys[a:fwd] = a:bwd
  endif

  " echo a:fwd
  " echo a:bwd
  " map the keys
  " exe mapstring mapcheck(a:bwd) '<SID>sendkeys('''.a:bwd.''')'
  " exe mapstring mapcheck(a:bwd) '<SID>sendkeys('''.a:bwd.''')'
  " noremap <expr> mapcheck(a:fwd) <SID>sendkeys(a:fwd, v:count)
  " noremap <expr> mapcheck(a:bwd) <SID>sendkeys(a:bwd, v:count)
  " set verbose=20
  " if (strlen(mapcheck(a:fwd)) > 0)
  "   echo strlen(mapcheck(a:fwd))
  "   exe "noremap <expr>" mapcheck(a:fwd) "<SID>"sendkeys(a:fwd,v:count)
  "   let g:active_keys[a:fwd] = a:bwd . ' remapped to ' . mapcheck(a:fwd)
  " else
  "   exe "noremap <expr>" a:fwd "<SID>"sendkeys(a:fwd,v:count)
  "   let g:active_keys[a:fwd] = a:bwd
  " endif

  " if (strlen(mapcheck(a:bwd)) > 0)
  "   echo strlen(mapcheck(a:bwd))
  "   exe "noremap <expr>" mapcheck(a:bwd) "<SID>"sendkeys(eval(a:bwd),v:count)
  "   let g:active_keys[a:bwd] = a:fwd . ' remapped to ' . mapcheck(a:bwd)
  " else
  "   exe "noremap <expr>" a:bwd "<SID>"sendkeys(a:bwd,v:count)
  "   let g:active_keys[a:bwd] = a:fwd
  " endif

  let lhs = ""
  let rhs = ""

  " reverse motion mapping
  "debug let rhs = '<SID>sendkeys('''.a:bwd.''')'
"  echo rhs
  let rhs = '<SID>sendkeys('''.a:bwd.''')'
  " let lhs = mapcheck(a:bwd)


  " check  if the user has remap the key
  if (strlen(mapcheck(a:bwd)) > 0)
    " echo strlen(mapcheck(a:bwd)) a:bwd
    echo 'aaa'
    let lhs = mapcheck(a:bwd)
    let g:active_keys[a:bwd] = a:fwd. ' is remapped to ' .mapcheck(a:bwd)
  else
    let lhs = a:bwd
    let g:active_keys[a:bwd] = a:fwd
  endif


"   echo lhs
"   echo rhs
"   echo 'bbb'
  execute 'nnoremap <expr> ' . lhs . ' ' . rhs
  " noremap <silent> exe '.lhs.' . ':<C-U>exe call <SID>sendkeys('.a:bwd.')<CR>'
  " execute 'noremap <silent> '.lhs.' . ':<C-U>exe call <SID>sendkeys('.a:bwd.')<CR>'

  " populate a mapping dict for the reverse motion

  " forward motion mapping
  " let rhs = '<SID>sendkeys('.a:fwd.')'
  " let rhs = ':<C-U>exe <SID>sendkeys('.a:bwd.')<CR>'


  " let lhs = mapcheck(a:fwd)
  let rhs = '<SID>sendkeys('''.a:fwd.''')'

  " check  if the user has remap the key
  if (strlen(mapcheck(a:fwd)) > 0)
    " echo strlen(mapcheck(a:fwd)) a:fwd
    let lhs = mapcheck(a:fwd)
    let g:active_keys[a:fwd] = a:bwd . ' remapped to ' . mapcheck(a:fwd)
  else
    let lhs = a:fwd
    let g:active_keys[a:fwd] = a:bwd
  endif

  execute 'nnoremap <expr> ' . lhs . ' ' . rhs
  " noremap <silent> lhs :call <SID>sendkeys(a:fwd)<CR>
  " execute 'noremap <silent> '. lhs . ':call <SID>sendkeys('.a:bwd.')<CR>'

  " populate a mapping dict...useful for debugging
  let g:mapping_dict[a:fwd] = mapcheck(a:fwd) . ' ' . a:fwd
  let g:mapping_dict[a:bwd] = mapcheck(a:bwd) . ' ' . a:bwd
    " noremap <expr> (strlen(mapcheck(a:fwd)) ? mapcheck(a:fwd) : a:fwd) <SID>sendkeys(a:fwd, v:count)
  " noremap <expr> eval(lhs) <SID>sendkeys(a:fwd, v:count)
  "set verbose=0
  " noremap <expr> (strlen(mapcheck(a:bwd)) ? mapcheck(a:bwd) : a:bwd) <SID>sendkeys(a:bwd, v:count)
  " noremap <expr> eval(lhs) <SID>sendkeys(a:bwd, v:count)
endfunction

function! s:getmappings()
  "display all the active mappings
  echo "Here's the list of active mappings. Each item appears in"
  echo "forward and reverse order"

  for [key, value] in items(g:mapping_dict)
    echo key . ' : ' . value
  endfor
endfunction

function! s:getkeys()
  "display all the active mappings
  " :Breakadd here
  echo "Here's the list of active mappings. Each item appears in"
  echo "forward and reverse order"

  for [key, value] in items(g:active_keys)
    echo key . ' : ' . value
  endfor
endfunction

" key = bwd motion
" value = fwd motion
let b:default_mappings = {
            \ '{'   : '}',
            \ '[['  : ']]',
            \ '[c'  : ']c',
            \ '[m'  : ']m',
            \ '[M'  : ']M',
            \ '[*'  : ']*',
            \ '[/'  : ']/',
            \ '[]'  : '][',
            \ '[''' : ']''',
            \ '[`'  : ']`',
            \ '[('  : '])',
            \ '[{'  : ']}',
            \ '[#'  : ']#',
            \ '[z'  : ']z',
            \ 'zk'  : 'zj',
            \ '('   : ')',
            \ '[s'  : ']s',
            \ 'T'   : 't',
            \ 'F'   : 'f',
            \ }

" load all default mappings
for k in keys(b:default_mappings)
  "could also be done with the 'items()' method wich generates a list
  " let text = k
  " let text .= b:default_mappings[k]
  call Addkeys(k, b:default_mappings[k])
endfor

" command to list all motion keys
command ListRepeatableMotions call <SID>getkeys()
command ListMappings call <SID>getmappings()

" exposing functions for key mapping
noremap <script> <expr> <silent> <Plug>repeatmotionsRepeat :call <SID>repeat()
noremap <script> <expr> <silent> <Plug>repeatmotionsReverseRepeat :call <SID>reverserepeat()

" autocmd BufReadPost *
"             \ let b:repeatable_motions = [] |
"             \ for m in s:repeatable_motions |
"             \   let bmapargs = maparg(m.backwards.lhs, '', 0, 1) |
"             \   let fmapargs = maparg(m.forwards.lhs, '', 0, 1) |
"             \   if bmapargs.buffer || fmapargs.buffer |
"             \      call AddRepeatableMotion(m.backwards.lhs, m.forwards.lhs) |
"             \   endif |
"             \ endfor |
