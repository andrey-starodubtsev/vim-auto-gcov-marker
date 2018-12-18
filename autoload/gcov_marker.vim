if exists('g:autoloaded_gcov_marker') || &cp || version < 700
    finish
else
    if !exists("g:gcov_marker_line_covered")
        let g:gcov_marker_line_covered = '✓'
    endif
    if !exists("g:gcov_marker_line_uncovered")
        let g:gcov_marker_line_uncovered = '✘'
    endif
    if !exists("g:gcov_marker_branch_covered")
        let g:gcov_marker_branch_covered = '✓✓'
    endif
    if !exists("g:gcov_marker_branch_partly_covered")
        let g:gcov_marker_branch_partly_covered = '✓✘'
    endif
    if !exists("g:gcov_marker_branch_uncovered")
        let g:gcov_marker_branch_uncovered = '✘✘'
    endif
    if !exists("g:gcov_marker_path")
        let g:gcov_marker_path = '.'
    endif
    if !exists("g:gcov_gcno_path")
        let g:gcov_gcno_path = '.'
    endif

    if !hlexists('GcovLineCovered')
        highlight GCovLineCovered ctermfg=green guifg=green
    endif
    if !hlexists('GcovLineUncovered')
        highlight GCovLineUncovered ctermfg=red guifg=red
    endif
    if !hlexists('GcovBranchCovered')
        highlight GCovBranchCovered ctermfg=green guifg=green
    endif
    if !hlexists('GcovBranchPartlyCovered')
        highlight GCovBranchPartlyCovered ctermfg=yellow guifg=yellow
    endif
    if !hlexists('GcovBranchUncovered')
        highlight GCovBranchUncovered ctermfg=red guifg=red
    endif
endif

function gcov_marker#BuildCov(...)
    let filename = expand('%:t:r')
    let gcno = globpath(g:gcov_gcno_path, '/**/' . filename . '.gcno', 1, 1)
    if len(gcno) == '0'
        echo "gcno file not found"
        return
    elseif len(gcno) != '1'
        echo "too many gcno files"
        return
    endif
    let gcno = fnamemodify(gcno[0], ':p')

    silent exe '!pushd ' . g:gcov_marker_path . '; gcov -i -b -m ' . gcno . ' > /dev/null; popd'

    let gcov = g:gcov_marker_path . '/' . expand('%:t') . '.gcov'

    call gcov_marker#SetCov(gcov)
    redraw!
endfunction

function gcov_marker#ClearCov(...)
    exe ":sign unplace *"
endfunction

function gcov_marker#SetCov(...)
    if(a:0 == 1)
        let filename = a:1
    else
        return
    endif

    " Clear previous markers.
    call gcov_marker#ClearCov()

    " Prepare signs
    exe ":sign define gcov_line_covered texthl=GcovLineCovered text=" . g:gcov_marker_line_covered
    exe ":sign define gcov_line_uncovered texthl=GcovLineUncovered text=" . g:gcov_marker_line_uncovered
    exe ":sign define gcov_branch_covered texthl=GcovBranchCovered text=" . g:gcov_marker_branch_covered
    exe ":sign define gcov_branch_partly_covered texthl=GcovBranchPartlyCovered text=" . g:gcov_marker_branch_partly_covered
    exe ":sign define gcov_branch_uncovered texthl=GcovBranchUncovered text=" . g:gcov_marker_branch_uncovered

    " Read files and fillin marks dictionary
    let marks = {}
    for line in readfile(filename)
        let type = split(line, ':')[0]
        let linenum = split(line, '[:,]')[1]

        if type == 'lcount'
            let execcount = split(line, '[:,]')[2]
            if execcount == '0'
                let marks[linenum] = 'linenotexec'
            else
                let marks[linenum] = 'lineexec'
            endif
        endif

        if type == 'branch'
            let branchcoverage = split(line, '[:,]')[2]
            if branchcoverage == 'notexec'
                let marks[linenum] = 'branchnotexec'
            elseif branchcoverage == 'taken' && (!has_key(marks, linenum) || marks[linenum] != 'branchnottaken')
                let marks[linenum] = 'branchtaken'
            elseif branchcoverage == 'nottaken'
                let marks[linenum] = 'branchnottaken'
            endif
        endif
    endfor

    " Iterate over marks dictionary and place signs
    for [line, marktype] in items(marks)
        if marktype == 'lineexec'
            exe ":sign place " . line. " line=" . line . " name=gcov_line_covered file=" . expand("%:p")
        elseif marktype == 'linenotexec'
            exe ":sign place " . line . " line=" . line . " name=gcov_line_uncovered file=" . expand("%:p")
        elseif marktype == 'branchtaken'
            exe ":sign place " . line . " line=" . line . " name=gcov_branch_covered file=" . expand("%:p")
        elseif marktype == 'branchnottaken'
            exe ":sign place " . line . " line=" . line . " name=gcov_branch_partly_covered file=" . expand("%:p")
        elseif marktype == 'branchnotexec'
            exe ":sign place " . line . " line=" . line . " name=gcov_branch_uncovered file=" . expand("%:p")
        endif
    endfor

    " Set the coverage file for the current buffer
    let b:coveragefile = fnamemodify(filename, ':p')
endfunction

let g:autoloaded_gcov_marker = 1
