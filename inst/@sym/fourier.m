%% Copyright (C) 2015 Colin B. Macdonald, Alexander Misel
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
%% @deftypefn  {Function File} {@var{FF} =} fourier (@var{f}, @var{x}, @var{w})
%% @deftypefnx {Function File} {@var{FF} =} fourier (@var{f})
%% @deftypefnx {Function File} {@var{FF} =} fourier (@var{f}, @var{w})
%% Symbolic Fourier transform.
%%
%% FIXME: doc
%%
%% Examples:
%% @example
%% syms x s
%% f = exp(-2*abs(x));
%% fourier(f)
%% @result{} ans = (sym)
%%
%%    4   
%%  ──────
%%   2    
%%  w  + 4
%%
%% fourier(f, s)
%% @result{} ans = (sym)
%%
%%    4   
%%  ──────
%%   2    
%%  s  + 4
%%
%% fourier(f, x, s)
%% @result{} ans = (sym)
%%
%%    4   
%%  ──────
%%   2    
%%  s  + 4
%%
%% @end example
%%
%% @seealso{ifourier,laplace}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function F = fourier(varargin)

  syms f x w;
  if (nargin == 1)
    f=varargin{1};
    x=symvar(f,1);

  elseif (nargin == 2)
    f=varargin{1};
    x=symvar(f,1);
    w=varargin{2};

  elseif (nargin == 3)
    f=varargin{1};
    x=varargin{2}; 
    w=varargin{3};

  else
    error('Wrong number of input arguments') 
 
  endif

  cmd = { 'from sympy.integrals.transforms import _fourier_transform'
          "F = _fourier_transform(*(_ins+[1,-1,'Fourier']))"
          'return F,'};
  F = python_cmd(cmd,f,x,w);

end


%!test
%! syms x k
%! f = exp(-x^2);
%! F = fourier(f,x,k);
%! g = ifourier(F,k,x);
%! assert(isequal(f,g))
