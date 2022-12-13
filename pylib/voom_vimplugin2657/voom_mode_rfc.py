# voom_mode_rfc.py
# VOoM (Vim Outliner of Markers): two-pane outliner and related utilities
# Website: http://www.vim.org/scripts/script.php?script_id=2657

"""
WIP: VOoM markup mode for rfc text files
"""

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

    Header Examples:

        2.1.  High-Level Goals
        Appendix C.  DMARC XML Schema
        C.1. Sub appendix
    """
    tlines, bnodes, levels = [], [], []
    SEEN = {}

    for i, line in enumerate(blines):   # enum body lines
        level, tline = -1, ''           # level < 0, means ignore the line

        if len(line) < 1:               # skip empty lines
            continue

        if line[0] in " \t":            # skip lines with leading whitespace
            continue

        words = line.split()            # leading whitespace is removed
        if len(words) < 1:              # need at least one word
            continue

        dotted = words[0].split(".")
        if len(dotted) > 1 and dotted[0].upper() in "0123456789ABCDEFGH":
            level = 1
            tline = " ".join(words)

        elif words[0].lower() == "appendix":
            level = 1
            tline = " ".join(words[1:])

        elif words[0].lower() == "abstract":
            level = 1
            tline = "Abstract"

        elif len(words) == 3 and words[0].lower() == "table":
            level = 1
            tline = line

        elif len(words) == 2 and words[0].lower() == "copyright":
            level = 1
            tline = line

        elif len(words) == 4 and words[0].lower() == "status":
            level = 1
            tline = line

        if level < 0:
            continue

        # register treeline at certain level
        levels.append(level)
        # using . | xxx -> allows folding tree outline
        tlines.append('  {}| {}'.format('  '*(level-1), tline))
        bnodes.append(i+1)

    return (tlines, bnodes, levels)
