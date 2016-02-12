%% Copyright (C) 2014--2016 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {[@var{A}, @var{info}] =} python_ipc_sysoneline (@dots{})
%% Private helper function for Python IPC.
%%
%% @var{A} is the resulting object, which might be an error code.
%%
%% @var{info} usually contains diagnostics to help with debugging
%% or error reporting.
%%
%% @code{@var{info}.prelines}: the number of lines of header code
%% before the command starts.
%%
%% @code{@var{info}.raw}: the raw output, for debugging.
%% @end deftypefn

function [A, info] = python_ipc_sysoneline(what, cmd, mktmpfile, varargin)

  persistent show_msg

  info = [];

  if (strcmp(what, 'reset'))
    show_msg = [];
    A = true;
    return
  end

  if ~(strcmp(what, 'run'))
    error('unsupported command')
  end

  verbose = ~sympref('quiet');

  if (verbose && isempty(show_msg))
    fprintf('OctSymPy v%s: this is free software without warranty, see source.\n', ...
            sympref('version'))
    disp('Using system()-based communication with Python [sysoneline].')
    disp('Warning: this will be *SLOW*.  Every round-trip involves executing a')
    disp('new Python process and many operations involve several round-trips.')
    disp('Warning: "sysoneline" will fail when using very long expressions.')
    show_msg = true;
  end

  newl = sprintf('\n');

  %% Headers
  % embedding the headers in the -c command is too long for
  % Windows.  We have a 8000 char budget, and the header uses all
  % of it.
  mydir = fileparts (mfilename ('fullpath'));
  % execfile() only works on python 2
  headers = ['exec(open(\"' mydir filesep() 'python_header.py\").read()); '];
  %s = python_header_embed2();
  %headers = ['exec(\"' s '\"); '];


  %% load all the inputs into python as pickles
  s = python_copy_vars_to('_ins', true, varargin{:});
  % extra escaping
  s = myesc(s);
  % join all the cell arrays with escaped newline
  s = strjoin(s, '\\n');
  s1 = ['exec(\"' s '\"); '];

  % The number of lines of code before the command itself (IIRC, all
  % newlines must be escaped so this should always be zero).
  assert(numel(strfind(s1, newl)) == 0);
  info.prelines = 0;

  %% The actual command
  % cmd will be a snippet of python code that does something
  % with _ins and produce _outs.
  s = python_format_cmd(cmd);
  s = myesc(s);
  s = strjoin(s, '\\n');
  s2 = ['exec(\"' s '\"); '];


  %% output, or perhaps a thrown error
  s = python_copy_vars_from('_outs');
  s = myesc(s);
  s = strjoin(s, '\\n');
  s3 = ['exec(\"' s '\");'];

  pyexec = sympref('python');
  if (isempty(pyexec))
    pyexec = 'python';
  end

  bigs = [headers s1 s2 s3];

  if (~mktmpfile)
    %% paste all the commands into the system() command line
    % python -c
    [status,out] = system([pyexec ' -c "' bigs '"']);
  else
    %% Generate a temp shell script then execute it with system()
    % This is for debugging ipc; not intended for general use
    fname = 'tmp_python_cmd.sh';
    fd = fopen(fname, 'w');
    fprintf(fd, '#!/bin/sh\n\n');
    fprintf(fd, '# temporary autogenerated code\n\n');
    fputs(fd, [pyexec ' -c "']);
    fputs(fd, bigs);
    fputs(fd, '"');
    fclose(fd);
    [status,out] = system(['sh ' fname]);
  end

  if status ~= 0
    status
    out
    error('system() call failed!');
  end

  % there should be two blocks
  ind = strfind(out, '<output_block>');
  assert(length(ind) == 2)
  out1 = out(ind(1):(ind(2)-1));
  % could extractblock here, but just search for keyword instead
  if (isempty(strfind(out1, 'successful')))
    error('failed to import variables to python?')
  end
  A = extractblock(out(ind(2):end));
  info.raw = out;
end


function s = myesc(s)

  for i = 1:length(s)
    % order is important here

    % escape quotes twice
    s{i} = strrep(s{i}, '\', '\\\\');

    % dbl-quote is rather special here
    % /" -> ///////" -> ///" -> /" -> "
    s{i} = strrep(s{i}, '"', '\\\"');

  end
end
