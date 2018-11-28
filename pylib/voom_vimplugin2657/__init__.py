import pkgutil
__path__ = pkgutil.extend_path(__path__, __name__)

# Note:
# Turn this package into a namespace 'voom_vimplugin2657', old style.
# - required as of VOoM v5.2, where voom_vimplugin2657 has an __init__.py
# - in init.vim, sys.path.insert(0,<dotvimdir>/pylib), pylib being the
#   parent for our user version of voom_vimplugin2657.
