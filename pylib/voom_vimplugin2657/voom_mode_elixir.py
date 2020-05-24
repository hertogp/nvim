# voom_mode_elm.py
# VOoM (Vim Outliner of Markers): two-pane outliner and related utilities
# Website: http://www.vim.org/scripts/script.php?script_id=2657

"""
WIP: VOoM markup mode for elixir code
"""

L1WORDS = ['def', 'defp', 'defmodule', 'import', 'require', 'use']
INDENT = 2

def till_do(list):
    try:
        n = list.index('do')
    except ValueError:
        try:
            n = list.index('do:')
        except ValueError:
            n = len(list)

    return n

def hook_makeOutline(_, blines):
    """
    Return (tlines, bnodes, levels) for list of Body lines.
    blines can also be Vim buffer object.
    """
    tlines, bnodes, levels = [], [], []

    for i, line in enumerate(blines):    # enum body lines
        level, tline = -1, ''           # level < 0, means ignore the line

        if len(line) < 1:               # skip empty lines
            continue
        if not line.lstrip('#'):        # skip pretty headers
            continue

        words = line.split()            # leading whitespace is removed
        if len(words) < 2:              # skip single word sentences
            continue

        if words[0] == '#' and words[1][0].isupper():
            level = 1
            tline = " ".join(words[:3])
        elif words[0] == 'def':
            # function definition
            level = 1
            tline = 'f: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == 'defp':
            # private function definition
            level = 1
            tline = 'p: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == 'defmodule':
            # module definition
            level = 1
            tline = 'm: ' + ' '.join(words[1:till_do(words)])
        elif words[0].startswith('@'):
            # attribute
            level = 1
            tline = '@: ' + ' '.join(words[:])[1:]
        elif words[0].lower() in L1WORDS:
            # keywords
            level = 1
            tline = '? ' + ' '.join(words[1:till_do(words)])

        if level < 0:
            continue

        # register treeline at certain level
        levels.append(level)
        # using . | xxx -> allows folding tree outline
        tlines.append('  {}| {}'.format(' .'*(level-1), tline))
        bnodes.append(i+1)

    return (tlines, bnodes, levels)


# def hook_newHeadline(vo_, level, blnum, tlnum):
#     """Return (tree_head, bodyLines).
#     tree_head is new headline string in Tree buffer (text after |).
#     bodyLines is list of lines to insert in Body buffer.
#     # column is cursor position in new headline in Body buffer.
#     """
#     tree_head = 'NewHeadline'
#     bodyLines = ['! NewHeadline']
#     return (tree_head, bodyLines)
