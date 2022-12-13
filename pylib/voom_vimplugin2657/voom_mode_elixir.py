# voom_mode_elm.py
# VOoM (Vim Outliner of Markers): two-pane outliner and related utilities
# Website: http://www.vim.org/scripts/script.php?script_id=2657

"""
WIP: VOoM markup mode for elixir code
"""

L1WORDS = ['def', 'defp', 'defmodule', 'import', 'require', 'use']
IGNORE = ["@doc", "@moduledoc",  "@spec", "@typespec", "@typedoc",
          "@enforce_keys", "@compile"]
INDENT = 2

def till_char(str, c):
    n = str.find(c)
    if n == -1: return str
    return str[0:n]

def till_do(list):
    try:
        n = list.index('do')
    except ValueError:
        try:
            n = list.index('do:')
        except ValueError:
            n = len(list)

    return n

def till_when(list):
    try:
        n = list.index('when')
    except ValueError:
            n = len(list)

    return n

def hook_makeOutline(_, blines):
    """
    Return (tlines, bnodes, levels) for list of Body lines.
    blines can also be Vim buffer object.
    """
    tlines, bnodes, levels = [], [], []
    SEEN = {}

    for i, line in enumerate(blines):   # enum body lines
        level, tline = -1, ''           # level < 0, means ignore the line

        if len(line) < 1:               # skip empty lines
            continue
        if not line.lstrip('#'):        # skip pretty headers
            continue

        words = line.split()            # leading whitespace is removed
        if len(words) < 2:              # skip single word sentences
            continue

        if words[0] == '#' and words[1][0].isupper():
            level = 2
            tline = " ".join(words[:3])
        elif words[0] == 'def':
            name = till_char(words[1], '(')
            if not SEEN.get('def-'+name):
                level = 2
                SEEN['def-'+name] = 1
            else:
                continue
                # level = 3
            tline = 'f: ' + name
        elif words[0] == 'defp':
            name = till_char(words[1], '(')
            if not SEEN.get('defp-'+name):
                level = 2
                SEEN['defp-'+name] = 1
            else:
                continue
                # level = 3
            tline = 'p: ' + name
        elif words[0] == 'defimpl':
            SEEN = {}  # reset: assumes defimple is not inside another module
            level = 1
            tline = 'I: ' + till_char(words[1], ',')
        elif words[0] == 'defstruct':
            level = 2
            tline = 's: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == 'defguard':
            level = 2
            tline = 'g: ' + ' '.join(words[1:till_when(words)])
        elif words[0] == 'defguardp':
            level = 2
            tline = 'g: ' + ' '.join(words[1:till_when(words)])
        elif words[0] == 'defmodule':
            SEEN = {} # reset the names seen for this module
            level = 1
            tline = 'M: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == 'require':
            level = 2
            tline = 'r: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == 'use':
            level = 2
            tline = 'u: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == 'import':
            level = 2
            tline = 'i: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == 'alias':
            level = 2
            tline = 'a: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == '@type':
            level = 2
            tline = 't: ' + ' '.join(words[1:till_do(words)])
        elif words[0] == '@callback':
            level = 2
            tline = 'c: ' + till_char(words[1], '(')
        elif words[0] == 'describe':
            level = 1
            tline = " ".join(words[:-1])
        elif words[0] == 'test':
            level = 2
            tline = " ".join(words[:-1])
        elif words[0] in IGNORE:
            # ignore these
            continue
        elif words[0].startswith('@'):
            # attribute
            level = 3
            tline = '@: ' + ' '.join(words[:])[1:]
        elif words[0].lower() in L1WORDS:
            # keywords
            level = 2
            tline = '? ' + ' '.join(words[1:till_do(words)])

        if level < 0:
            continue

        # register treeline at certain level
        levels.append(level)
        # using . | xxx -> allows folding tree outline
        tlines.append('  {}| {}'.format('  '*(level-1), tline))
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
