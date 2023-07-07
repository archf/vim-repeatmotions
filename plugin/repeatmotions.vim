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

function! s:sendkeys(key)
  "send a given key sequence to vim

  " echo shellescape(a:key)
  " echo match(a:key,'<')
  " if match(a:key,'<') == 1
  "   echo '"\<lt>' . strpart(a:key,1,strlen(a:key)) . '"')
  " endif
  " if match(a:key,'<') > 1
  "   echo a:key
  "  let a:key = '"\<lt>' . strpart(a:key,1,strlen(a:key)) . '"')
  "  echo 'new keyseq is: ' . a:key
 " endif

  " update the g:prev_motion only if a motion key sequence is receive
  if a:key!= "," && a:key!= ";"
    " echo 'why ' . a:key. " " . g:prev_motion
    let g:prev_motion = a:key
  endif
  " echo 'you just sent: ' . a:key
  " echo 'updated g:prev_motion = ' . a:key
  call feedkeys((v:count ? v:count : '') . a:key, 'n')

endfunction

" backwards: {lhs} of the mapping to move the cursor backwards
" forwards: {lhs} of the mapping to move the cursor forwards
function! Addkeys(bwd,fwd)

  " echo a:bwd . ' ' . a:fwd
  " echo ''.a:bwd.''' . ' ' . '''.a:fwd.'''
  " make sure we do not add each key par twice
  if has_key(g:active_keys,a:bwd) || has_key(g:active_keys,a:fwd)
    echoerr a:bwd 'and' a:fwd ' key pair already added to repeatable key list'
    return
  else
    " let g:active_keys[a:bwd] = a:fwd
    " let g:active_keys[a:fwd] = a:bwd
  endif

  let lhs = ''
  let rhs = ''

  " reverse motion mapping
  " if match(a:bwd,'<') == 0
    " this is a special key that must be sent literally
    " echo shellescape('"\<lt>' . strpart(a:bwd,1,strlen(a:bwd)) . '"')
    " echo 'aestarsttttttttttttttttttttttttttttt'
    " " let rhs = ' :call <SID>sendkeys('. '"\<lt>' . strpart(a:bwd,1,strlen(a:bwd)) . '"' .')<CR>'
    " let rhs = ' :call <SID>sendkeys('. '"<' . strpart(a:bwd,1,strlen(a:bwd)) . '"' .')<CR>'
    " echo rhs
    " echo 'with shellescape '
    " echo shellescape(' :call <SID>sendkeys('. '"\<lt>' . strpart(a:bwd,1,strlen(a:bwd)) . '"' .')<CR>')
    " echo 'with shellescape 1 '
    " echo shellescape(' :call <SID>sendkeys('. '"\<lt>' . strpart(a:bwd,1,strlen(a:bwd)) . '"' .')<CR>',1)
  " else
  " endif
  " let lhs = mapcheck(a:bwd)

  let rhs = ' :call <SID>sendkeys('''.a:bwd.''')<CR>'

  " check  if the user has remap the key
  if (strlen(mapcheck(a:bwd)) > 0)
    " echo strlen(mapcheck(a:bwd)) a:bwd
    let lhs = mapcheck(a:bwd)
    let g:active_keys[a:bwd] = a:fwd. ' is remapped to ' .mapcheck(a:bwd)
  else
    let lhs = a:bwd
    let g:active_keys[a:bwd] = a:fwd
  endif

  " echo 'nnoremap <silent> ' . lhs . rhs
  execute 'nnoremap <silent> ' . lhs . rhs

  let rhs = ' :call <SID>sendkeys('''.a:fwd.''')<CR>'

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
            \ '[['  : ']]',
            \ '[]'  : '][',
            \ '{'   : '}',
            \ '[c'  : ']c',
            \ '[m'  : ']m',
            \ '[M'  : ']M',
            \ '[*'  : ']*',
            \ '[/'  : ']/',
            \ '[''' : ']''',
            \ '[`'  : ']`',
            \ '[('  : '])',
            \ '[{'  : ']}',
            \ '[#'  : ']#',
            \ '[z'  : ']z',
            \ 'zk'  : 'zj',
            \ '('   : ')',
            \ '[s'  : ']s'
            \ }

" This is already mapped for vim filetypes and errors. Perhpas a better
" workaround could be used to properly fixed the mapping command.
" Ommiting them for now.
if &filetype == "vim"
  unlet b:default_mappings['[[']
  unlet b:default_mappings['[]']
endif
            " \ '<PageUP>' : '<PageDown>'
            " \ "\<C-D>"  : "\<lt>C-U>"
" \ 'T'   : 't',
" \ 'F'   : 'f',

" load all default mappings
for k in keys(b:default_mappings)
  "could also be done with the 'items()' method which generates a list
  " let text = k
  " let text .= b:default_mappings[k]
  call Addkeys(k, b:default_mappings[k])

  " special case for f,F and t,T because i swapped them in my layout
  " and it would recursely get remapped otherwise.
  nnoremap t :call <SID>sendkeys('f')<CR>
  nnoremap T :call <SID>sendkeys('F')<CR>
  nnoremap f :call <SID>sendkeys('t')<CR>
  nnoremap F :call <SID>sendkeys('T')<CR>

  " other special mappings
  nnoremap <PageDown> :call <SID>sendkeys("\<C-D>")<CR>
  nnoremap <PageUp> :call <SID>sendkeys("\<lt>C-U>")<CR>
  " nnoremap <PageUP> :call <SID>sendkeys("\<lt>PageUP>")<CR>
  " nnoremap <PageDown> :call <SID>sendkeys("\<lt>PageDown>")<CR>
endfor

" command to list all motion keys
command ListRepeatableMotions call <SID>getkeys()
command ListMappings call <SID>getmappings()

nnoremap  <silent> <Space> :call <SID>repeat()<CR>
nnoremap <silent> <BS> :call <SID>reverserepeat()<CR>

" for some unknown reason this doesn't work
" noremap <Plug>repeatmoeineonsRepeat :call <SID>repeat()<CR>
" noremap <Plug>repeatmotionsReverseRepeat :call <SID>reverserepeat()<CR>
" nnoremap <Space> <Plug>repeatmotionsRepeat
" nnoremap , <Plug>repeatmotionsReverseRepeat
