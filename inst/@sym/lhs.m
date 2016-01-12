%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{L} =} lhs (@var{f})
%% Left-hand side of symbolic expression.
%%
%% Gives an error if any of the symbolic objects have no left-hand side.
%%
%% @seealso{rhs, children}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function L = lhs(f)

  cmd = {
    'f, = _ins'
    'try:'
    '    if f.is_Matrix:'
    '        return (0, f.applyfunc(lambda a: a.lhs))'
    '    else:'
    '        return (0, f.lhs)'
    'except Exception as e:'
    '    return (1, type(e).__name__ + ": " + str(e))'
    };

  [flag, L] = python_cmd (cmd, f);

  if (flag)
    error(L)
  end

end


%!test
%! syms x y
%! f = x + 1 == 2*y;
%! assert (isequal (lhs(f), x + 1))
%! assert (isequal (rhs(f), 2*y))

%!test
%! syms x y
%! f = x + 1 < 2*y;
%! assert (isequal (lhs(f), x + 1))
%! assert (isequal (rhs(f), 2*y))

%!test
%! syms x y
%! f = x + 1 >= 2*y;
%! assert (isequal (lhs(f), x + 1))
%! assert (isequal (rhs(f), 2*y))

%!test
%! syms x y
%! A = [x == y  2*x < 2*y;  3*x > 3*y  4*x <= 4*y;  5*x >= 5*y  x < 0];
%! L = [x 2*x; 3*x 4*x; 5*x x];
%! R = [y 2*y; 3*y 4*y; 5*y 0];
%! assert (isequal( lhs(A), L))
%! assert (isequal( rhs(A), R))

%!error <AttributeError>
%! syms x
%! lhs(x)

%!error <AttributeError>
%! lhs(sym(true))

%!error <AttributeError>
%! syms x
%! A = [1 + x == 2*x  sym(6)];
%! lhs(A)
