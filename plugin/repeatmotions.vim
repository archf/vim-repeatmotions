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
let g:prev_motion = ''
let g:last_keyseq = ''

function! s:repeat()
  " overload the ';' key
  if g:prev_motion ==? 't' || g:prev_motion ==? 'f'
    call <SID>sendkeys(';')
  else
    call <SID>sendkeys(g:prev_motion)
  endif
endfunction

function! s:reverserepeat()
  " overload the ',' key
  if g:prev_motion ==? 't' || g:prev_motion ==? 'f' || g:prev_motion == ''

    " this is
    call <SID>sendkeys(',')
    " if g:motion_direction_toggle
    "   if g:prev_motion

  else
    " reverse direction if there is a difference in between the g:prev_motion
    " if g:prev_motion != g:rev_last_motion
      " look in the active_keys dict for the reverse motion
      let keyseq = get(g:active_keys,g:prev_motion)
      if !empty(keyseq)
        " g:prev_motion is updated so
        let g:prev_motion = keyseq
        " echo 'keyseq : ' . keyseq
        call <SID>sendkeys(keyseq)
      endif
  endif
endfunction

function! s:sendkeys(sequence)
  "send a given key sequence to vim

  " echo a:sequence
  " update the g:prev_motion only if a motion key sequence is receive
  if a:sequence != "," && a:sequence != ";"
    " echo 'why ' . a:sequence . " " . g:prev_motion
    let g:prev_motion = a:sequence
  endif

  " echo 'updated g:prev_motion = ' . a:sequence
  call feedkeys((v:count ? v:count : '') . a:sequence, 'n')

endfunction

" backwards: {lhs} of the mapping to move the cursor backwards
" forwards: {lhs} of the mapping to move the cursor forwards
function! Addkeys(bwd,fwd)

  " make sure we do not add each key par twice
  if has_key(g:active_keys,a:bwd) || has_key(g:active_keys,a:fwd)
    echoerr a:bwd 'and' a:fwd ' key pair already added to repeatable key list'
    return
  else
    " let g:active_keys[a:bwd] = a:fwd
    " let g:active_keys[a:fwd] = a:bwd
  endif

  let lhs = ""
  let rhs = ""

  " reverse motion mapping
  let rhs = ' :call <SID>sendkeys('''.a:bwd.''')<CR>'
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

  execute 'nnoremap <silent> ' . lhs . rhs

  let rhs = ' :call <SID>sendkeys('''.a:fwd.''')<CR>'

  " check  if the user has remap the key
  if (strlen(mapcheck(a:fwd)) > 0)
    " echo strlen(mapcheck(a:fwd)) a:fwd
    let lhs = mapcheck(a:fwd)
    let g:active_keys[a:fwd] = a:bwd . ' remapped to ' . mapcheck(a:fwd)
  else
    let lhs = a:fwd
    let g:active_keys[a:fwd] = a:bwd
  endif

  execute 'nnoremap <silent> ' . lhs . rhs

  " populate a mapping dict...useful for debugging
  let g:mapping_dict[a:fwd] = mapcheck(a:fwd)
  let g:mapping_dict[a:fwd] = mapcheck(a:fwd)
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
            \ }

" \ 'T'   : 't',
" \ 'F'   : 'f',

" load all default mappings
for k in keys(b:default_mappings)
  "could also be done with the 'items()' method wich generates a list
  " let text = k
  " let text .= b:default_mappings[k]
  call Addkeys(k, b:default_mappings[k])

  " special case for f,F and t,T because i swapped them in my layout
  " and it recursely remapped
  nnoremap t :call <SID>sendkeys('f')<CR>
  nnoremap T :call <SID>sendkeys('F')<CR>
  nnoremap f :call <SID>sendkeys('t')<CR>
  nnoremap F :call <SID>sendkeys('T')<CR>
endfor

" command to list all motion keys
command ListRepeatableMotions call <SID>getkeys()
command ListMappings call <SID>getmappings()

nnoremap  <silent> <Space> :call <SID>repeat()<CR>
nnoremap <silent> , :call <SID>reverserepeat()<CR>

" for some unknown reason this doesn't work
" noremap <Plug>repeatmoeineonsRepeat :call <SID>repeat()<CR>
" noremap <Plug>repeatmotionsReverseRepeat :call <SID>reverserepeat()<CR>
" nnoremap <Space> <Plug>repeatmotionsRepeat
" nnoremap , <Plug>repeatmotionsReverseRepeat
