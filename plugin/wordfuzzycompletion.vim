" -*- coding: utf-8 -*-"
" author: jonatan alexis anauati (barakawins@gmail.com) "
" author: Andras Retzler (randras@sdr.hu) "
" version: 0.7. "

if !has('python')
    finish
endif

function! PythonWordFuzzyCompletion(base)
python << EOF
import sys, string, vim, math, time

MAX_RESULTS=vim.eval('g:fuzzywordcompletion_maxresults')
transtable = vim.eval('g:fuzzywordcompletion_completiontable')
if not transtable:
    nosplitchars=string.letters+'_'
    deletechars =''.join(
        (chr(c) for c in range(0,256) if chr(c) not in nosplitchars))
    transtable = string.maketrans(deletechars,' '*len(deletechars))

def completion(word):
    results=[]
    distances = None
    distances_1 = {}
    distances_2 = {}
    try:
        first_char=word[0].lower()
    except:
        first_char=''
    word_len=len(word)
    word_lower=word.lower()
    endwalk=False
    linenum = 0
    currentline = vim.current.range.start+1
    maxdist = 0
    #add filenames
    lines = [vim.current.buffer.name]
    lines.extend(vim.current.buffer[:])
    for line in lines:
        linenum += 1
        currentdist = math.fabs(linenum-currentline)
        maxdist = max(currentdist, maxdist)
        for w in line.translate(transtable).split():
            wl=w.lower()
            if wl.startswith(word_lower[0:len(word_lower)]):
                results.append([w, 1, currentdist])
            elif word_lower in wl:
                results.append([w, 0, currentdist])
    results.sort(key=lambda a: len(a[0]), reverse=True)
    results.sort(key=lambda a: a[1], reverse=True)
    results.sort(key=lambda a: a[2], reverse=False)
    #add words from all other buffers
    for buffer in vim.buffers:
        if vim.current.buffer.number == buffer.number: continue
        lines = [buffer.name]
        lines.extend(buffer[:])
        for line in lines:
            for w in line.translate(transtable).split():
                wl=w.lower()
                if wl.startswith(word_lower[0:len(word_lower)]):
                    results.append([w, 1, maxdist])
                elif word_lower in wl:
                    results.append([w, 0, maxdist])
    if len(results) >= MAX_RESULTS:
        results=results[0:MAX_RESULTS]
    #print results
    #time.sleep(5)
    return [x[0] for x in results]

base=vim.eval('a:base')
vim.command('let g:fuzzyret='+str(completion(base)))
EOF
    return g:fuzzyret
endfunction

function! FuzzyWordCompletion(findstart, base)
    if a:findstart
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '\a\|_'
            let start -= 1
        endwhile
        return start
    else
        return PythonWordFuzzyCompletion(a:base)
    endif
endfunction

if !exists("g:fuzzywordcompletion_maxresults")
    let g:fuzzywordcompletion_maxresults=10
endif

if !exists("g:fuzzywordcompletion_completiontable")
    let g:fuzzywordcompletion_completiontable=''
endif

set completefunc=FuzzyWordCompletion
if !exists("g:fuzzywordcompletion_disable_keybinding")
    let g:fuzzywordcompletion_disable_keybinding=0
endif

if !g:fuzzywordcompletion_disable_keybinding
    imap <C-k> <C-x><C-u>
endif
