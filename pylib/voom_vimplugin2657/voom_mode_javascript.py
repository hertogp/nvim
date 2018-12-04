# voom_mode_javascript.py
# VOoM (Vim Outliner of Markers): two-pane outliner and related utilities
# Website: http://www.vim.org/scripts/script.php?script_id=2657

"""
WIP: VOoM markup mode for javascript code
"""

L1WORDS = ['var', 'let', 'const', 'function']

def hook_makeOutline(VO, blines):
    """Return (tlines, bnodes, levels) for list of Body lines.
    blines can also be Vim buffer object.
    """
    tlines, bnodes, levels = [], [], []

    for i,line in enumerate(blines):    # enum body lines
        level, tline = -1, ''

        if not len(line):               # skip empty lines
            continue
        if not line.lstrip('/ -=*'):    # skip pretty headers
            continue

        words = line.split()            # leading whitespace is removed
        if len(words) < 2:              # skip single word sentences
            continue

        if words[0] == '//':
            level = len(words[1])
            tline = '// ' + (words[2] if len(words) > 2 else words[1])
        elif words[0] in L1WORDS:
            level = 1
            tline = ' '.join(words[0:2])

        if level < 0:
            continue

        # register treeline at certain level
        levels.append(level)
        tlines.append('  {}| {}'.format(' .'*(level-1), tline))
        bnodes.append(i+1)

    return (tlines, bnodes, levels)

def hook_newHeadline(VO, level, blnum, tlnum):
    """Return (tree_head, bodyLines).
    tree_head is new headline string in Tree buffer (text after |).
    bodyLines is list of lines to insert in Body buffer.
    # column is cursor position in new headline in Body buffer.
    """
    tree_head = 'NewHeadline'
    bodyLines = ['! NewHeadline']
    return (tree_head, bodyLines)
