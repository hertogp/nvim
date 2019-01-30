# voom_mode_javascript.py
# VOoM (Vim Outliner of Markers): two-pane outliner and related utilities
# Website: http://www.vim.org/scripts/script.php?script_id=2657

"""
WIP: VOoM markup mode for lua code
"""

L1WORDS = ['local', 'function']
INDENT = 2

def hook_makeOutline(VO, blines):
    """
    Return (tlines, bnodes, levels) for list of Body lines.
    blines can also be Vim buffer object.
    """
    tlines, bnodes, levels = [], [], []

    for i, line in enumerate(blines):    # enum body lines
        level, tline = -1, ''

        if not len(line):               # skip empty lines
            continue
        if not line.lstrip('-'):        # skip pretty headers
            continue

        words = line.split()            # leading whitespace is removed
        if len(words) < 2:              # skip single word sentences
            continue

        if words[0] == '--[[':
            level = 1
            tline = '[[ ' + " ".join(words[1:3])
        elif words[0].lower() in L1WORDS:
            # assumes spaces are used to indent, not tabs
            indent = int((len(line) - len(line.lstrip(" ")))/INDENT)
            if indent == 0:  # try tabs perhaps?
                indent = int(len(line) - len(line.lstrip("\t")))

            level = 1 + indent
            if words[1].lower() == 'function':
                tline = ' '.join(words[1:3])
            else:
                tline = ' '.join(words[0:2])

        if level < 0:
            continue

        # register treeline at certain level
        levels.append(level)
        # using . | xxx -> allows folding tree outline
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
