%% Copyright (C) 2014-2016 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @defmethod  @@sym diff (@var{f})
%% @defmethodx @@sym diff (@var{f}, @var{x})
%% @defmethodx @@sym diff (@var{f}, @var{x}, @dots{})
%% @defmethodx @@sym diff (@var{f}, @dots{})
%% Symbolic differentiation.
%%
%% Examples:
%% @example
%% @group
%% syms x
%% f = sin (cos (x));
%% diff (f)
%%   @result{} (sym) -sin(x)⋅cos(cos(x))
%% diff (f, x)
%%   @result{} (sym) -sin(x)⋅cos(cos(x))
%% simplify (diff (f, x, x))
%%   @result{} (sym)
%%            2
%%       - sin (x)⋅sin(cos(x)) - cos(x)⋅cos(cos(x))
%% @end group
%% @end example
%%
%% Partial differentiation:
%% @example
%% @group
%% syms x y
%% f = cos(2*x + 3*y);
%% diff(f, x, y, x)
%%   @result{} (sym) 12⋅sin(2⋅x + 3⋅y)
%% diff(f, x, 2, y, 3)
%%   @result{} (sym) -108⋅sin(2⋅x + 3⋅y)
%% @end group
%% @end example
%%
%% Other examples:
%% @example
%% @group
%% diff(sym(1))
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% @seealso{@@sym/int}
%% @end defmethod


function z = diff(f, varargin)

  cmd = { 'f = _ins[0]'
          'args = _ins[1:]'
          'd = list(f.free_symbols)'
          'if len(d) == 0:'
          '    return sympy.S(0),'
          'if len(args) == 0:'
          '    d = [d[0]]'
          'else:'
          '    if args[0].is_integer:'
          '        d = d*args[0]'
          '    else:'
          '        d = [args[0]]'
          '    for i in xrange(1, len(args)):'
          '        if args[i].is_integer:'
          '            if args[i] >= 1:'
          '                d = d + [d[-1]]*(args[i]-1)'
          '        else:'
          '            d = d + [args[i]]'
          'return f.diff(*d),' };

  varargin = sym(varargin);
  z = python_cmd (cmd, sym(f), varargin{:});

end


%!shared x,y,z
%! syms x y z

%!test
%! % basic
%! assert(logical( diff(sin(x)) - cos(x) == 0 ))
%! assert(logical( diff(sin(x),x) - cos(x) == 0 ))
%! assert(logical( diff(sin(x),x,x) + sin(x) == 0 ))

%!test
%! % these fail when doubles are not converted to sym
%! assert(logical( diff(sin(x),x,2) + sin(x) == 0 ))
%! assert(logical( diff(sym(1),x) == 0 ))
%! assert(logical( diff(1,x) == 0 ))
%! assert(logical( diff(pi,x) == 0 ))

%!test
%! % symbolic diff of const (w/o variable) fails in sympy, but we work around
%! assert (isequal (diff(sym(1)), sym(0)))

%!test
%! % nth symbolic diff of const
%! assert (isequal (diff(sym(1), 2), sym(0)))
%! assert (isequal (diff(sym(1), sym(1)), sym(0)))

%!test
%! % octave's vector difference still works
%! assert(isempty(diff(1)))
%! assert((diff([2 6]) == 4))

%!test
%! % other forms
%! f = sin(x);
%! g = diff(f,x,2);
%! assert (isequal (diff(f,2), g))
%! assert (isequal (diff(f,2,x), g))
%! assert (isequal (diff(f,sym(2)), g))
%! assert (isequal (diff(f,sym(2),x), g))
%! g = diff(f,x);
%! assert (isequal (diff(f), g))
%! assert (isequal (diff(f,1), g))
%! assert (isequal (diff(f,1,x), g))

%!test
%! % matrix
%! A = [x sin(x); x*y 10];
%! B = [1 cos(x); y 0];
%! assert(isequal(diff(A,x),B))

%!test
%! % bug: use symvar
%! a = x*y;
%! b = diff(a);
%! assert (isequal (b, y))

%!test
%! % bug: symvar should be used on the matrix, not comp-by-comp
%! a = [x y x*x];
%! b = diff(a);
%! assert (~isequal (b(2), 1))
%! assert (isequal (b, [1 0 2*x]))
%! b = diff(a,1);
%! assert (~isequal (b(2), 1))
%! assert (isequal (b, [1 0 2*x]))
