function varargout = unpack(varargin)

% UNPACK   Assign input to multiple outputs
%
%    [var1, var2, ...] = unpack(arg)                                (1)
%    [var1, var2, ...] = unpack(arg1, arg2, ...)                    (2)
%
%    [struct.fieldname] = unpack(arg)                               (3)
%    [struct.fieldname] = unpack(arg1m arg2, ...)                   (4)
%
%    Calling 'unpack' as shown in (1) it assigns the list of elements of
%    arg(:) to the output variables; the number of elements must match. If
%    called as shown in (2) 'unpack' matches up the input and output lists.
%    The invocations shown in (3) and (4) work similarly and allow for
%    populating data into structure arrays; the size of the structure array
%    and the number of elements must match.
%
%    Example:
%
%       A = [1 3; 2 4];
%       [a, b, c, d] = unpack(A);  % yields a=1, b=2, c=3, d=4
%
%    Example:
%
%       A = [1 2];
%       B = 2;
%       [a, b] = unpack(A, B)  % yields a=[1 2], b=2
%
%    Example:
%
%       s(4) = struct('a', [], 'b', []);
%       [s.a] = unpack([1, 2, 3, 4])  % note the sinlge argument
%       [s.b] = unpack('1', '2', '3', '4')  % multiple arguments
%
%   See also deal.

% Written by Christoph Hänisch
% Version 0.4 (2017-02-16)
% Licence: Modified BSD License (BSD license with non-military-use clause)

if nargin==1
    % Make sure the given argument is a cell array.
    if iscell(varargin{1})
        arg = varargin{1};
    else
        arg = num2cell(varargin{1});
    end
    if nargout ~= numel(arg)
        error('unpack:narginNargoutMismatch',...
              'The number of outputs must match the number of inputs.')
    end
    varargout = arg;
else
    if nargout ~= nargin
        error('unpack:narginNargoutMismatch',...
              'The number of outputs must match the number of inputs.')
    end
    varargout = varargin;
end
