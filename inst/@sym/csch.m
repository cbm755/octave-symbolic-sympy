%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod @@sym csch (@var{x})
%% Symbolic csch function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% y = csch (x)
%%   @result{} y = (sym) csch(x)
%% @end group
%% @end example
%%
%% Note: this file is autogenerated: if you want to edit it, you might
%% want to make changes to 'generate_functions.py' instead.
%%
%% @end defmethod


function y = csch(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('csch', x);
end


%!error <Invalid> csch (sym(1), 2)
%!assert (isequaln (csch (sym(nan)), sym(nan)))

%!shared x, d
%! d = 1;
%! x = sym('1');

%!test
%! f1 = csch(x);
%! f2 = csch(d);
%! assert( abs(double(f1) - f2) < 1e-15 )

%!test
%! D = [d d; d d];
%! A = [x x; x x];
%! f1 = csch(A);
%! f2 = csch(D);
%! assert( all(all( abs(double(f1) - f2) < 1e-15 )))

%!test
%! % round trip
%! if (python_cmd ('return Version(spver) > Version("1.0")'))
%! y = sym('y');
%! A = csch (d);
%! f = csch (y);
%! h = function_handle (f);
%! B = h (d);
%! assert (A, B, -eps)
%! end
