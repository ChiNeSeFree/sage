#*****************************************************************************
#       Copyright (C) 2017 Erik M. Bray <erik.bray@lri.fr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

from __future__ import absolute_import

from cpython.version cimport PY_MAJOR_VERSION


cdef extern from "string_impl.h":
    str _cstr_to_str(const char* c, encoding, errors)
    bytes _str_to_bytes(s, encoding, errors)


cdef inline str char_to_str(const char* c, encoding=None, errors=None):
    r"""
    Convert a C string to a Python ``str``.
    """
    # Implemented in C to avoid relying on PY_MAJOR_VERSION
    # compile-time variable. We keep the Cython wrapper to deal with
    # the default arguments.
    return _cstr_to_str(c, encoding, errors)


cpdef inline str bytes_to_str(b, encoding=None, errors=None):
    r"""
    Convert ``bytes`` to ``str``.

    On Python 2 this is a no-op since ``bytes is str``.  On Python 3
    this decodes the given ``bytes`` to a Python 3 unicode ``str`` using
    the specified encoding.

    EXAMPLES::

        sage: import six
        sage: from sage.cpython.string import bytes_to_str
        sage: s = bytes_to_str(b'\xcf\x80')
        sage: if six.PY2:
        ....:     s == b'\xcf\x80'
        ....: else:
        ....:     s == u'π'
        True
        sage: bytes_to_str([])
        Traceback (most recent call last):
        ...
        TypeError: expected bytes, list found
    """
    if type(b) is not bytes:
        raise TypeError(f"expected bytes, {type(b).__name__} found")

    if PY_MAJOR_VERSION <= 2:
        return <str>b
    else:
        return _cstr_to_str(<bytes>b, encoding, errors)


cpdef inline bytes str_to_bytes(s, encoding=None, errors=None):
    r"""
    Convert ``str`` or ``unicode`` to ``bytes``.

    On Python 3 this encodes the given ``str`` to a Python 3 ``bytes``
    using the specified encoding.

    On Python 2 this is a no-op on ``str`` input since ``str is bytes``.
    However, this function also accepts Python 2 ``unicode`` objects and
    treats them the same as Python 3 unicode ``str`` objects.

    EXAMPLES::

        sage: import six
        sage: from sage.cpython.string import str_to_bytes
        sage: if six.PY2:
        ....:     bs = [str_to_bytes('\xcf\x80'), str_to_bytes(u'π')]
        ....: else:
        ....:     bs = [str_to_bytes(u'π')]
        sage: all(b == b'\xcf\x80' for b in bs)
        True
        sage: str_to_bytes([])
        Traceback (most recent call last):
        ...
        TypeError: expected str... list found
    """
    # Implemented in C to avoid relying on PY_MAJOR_VERSION
    # compile-time variable. We keep the Cython wrapper to deal with
    # the default arguments.
    return _str_to_bytes(s, encoding, errors)
