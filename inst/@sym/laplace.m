%% Copyright (C) 2014, 2015 Andrés Prieto, Colin Macdonald
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
%% @deftypefn {Function File} {@var{F} =} laplace (@var{f}, @var{t}, @var{s})
%% @deftypefnx {Function File} {@var{F} =} laplace (@var{f})
%% @deftypefnx {Function File} {@var{F} =} laplace (@var{f}, @var{s})
%% Laplace transform.
%%
%% Example:
%% @example
%% @group
%% >> syms t
%% >> f = t^2;
%% >> laplace(f)
%%    @result{} (sym)
%%        2
%%        ──
%%         3
%%        s
%% @end group
%% @end example
%%
%% @seealso{ilaplace}
%% @end deftypefn

%% Author: Andrés Prieto
%% Keywords: symbolic, integral transforms

function F = laplace(varargin)

  % FIXME: it only works for scalar functions
  % FIXME: it doesn't handle diff call (see SMT transform of diff calls)

  % If the physical variable of f is equal to "s",
  % "t" is the frequency domain variable (analogously to SMT)
  if (nargin == 1)
    f=varargin{1};
    t=symvar(f,1);
    cmd = { 'f=_ins[0]; t=_ins[1]; s=sp.Symbol("s")'
            'if t==s:'
            '    s=sp.Symbol("t")'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd, f, t);

  elseif (nargin == 2)
    f=varargin{1};
    s=varargin{2}; 
    t=symvar(f,1);
    cmd = { 'f=_ins[0]; t=_ins[1]; s=_ins[2]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd, f, t, s);

  elseif (nargin == 3)
    f=varargin{1};
    t=varargin{2}; 
    s=varargin{3};
    cmd = { 'f=_ins[0]; t=_ins[1]; s=_ins[2]'
            'F=sp.laplace_transform(f, t, s)'
            'if isinstance(F, sp.LaplaceTransform):'
            '    return F,'
            'else:'
            '    return F[0],'};

    F = python_cmd(cmd, f, t, s);

  else
    print_usage ();

  end

end


%!test
%! % basic
%! syms t s u w
%! assert(logical( laplace(exp(2*t)) == 1/(s-2) ))
%! assert(logical( laplace(exp(2*s)) == 1/(t-2) ))
%! assert(logical( laplace(exp(2*u),w) == 1/(w-2) ))
%! assert(logical( laplace(exp(2*u),u,w) == 1/(w-2) ))
%! assert(logical( laplace(cos(3*t)) == s/(s^2+9) ))
%! assert(logical( laplace(t^3) == 6/s^4 ))

%!xtest
%! % Differential operator to algebraic
%! % SymPy cannot evaluate? (Issue #170)
%! syms s f(t)
%! assert(logical( laplace(diff(f(t),t),t,s) == s*laplace(f(t),t,s)-f(0) ))
