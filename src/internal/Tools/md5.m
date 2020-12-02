function digest = md5(message, already_byte_stream)

% MD5   Compute the MD5 digest of a message (byte stream)
%
%    digest = md5(message)
%    digest = md5(message, already_byte_stream)
%
%    This function computes the MD5 digest (md5sum) of a given message and
%    returns the digest as a hexadecimal output string. If called with only
%    one input argument, the argument is converted into a byte stream using
%    the typecast function. This behavior can be altered by passing true as
%    a second input argument.
%
%    Example:
%
%       md5('This is an example.')
%
%       ans =
%
%       263FB1AA85489991A2EF832EF10308A0
%
%    Example:
%
%       md5([1 2 3 4])          % interpreted as doubles (4*8 bytes)
%       md5([1 2 3 4], false)   % same result as above
%       md5([1 2 3 4], true)    % different; interpreted as bytes (4 bytes)
%
%    Example:
%
%       % If the input message is considered to be a byte stream, floating
%       % point numbers are truncated and/or clipped. As a result,
%       % different messages may yield the same digest.
%
%       md5([1.0 2.0 100.0], true)
%       md5([1.1 2.0 100.0], true)      % same result as above
%       md5([1 2 1e8], true)
%       md5([1 2 1e9], true)            % same result as above
%
%       % Different results in all four cases (as interpreted as doubles)
%
%       md5([1.0 2.0 100.0])
%       md5([1.1 2.0 100.0])
%       md5([1 2 1e8])
%       md5([1 2 1e9])
%
%    Example:
%
%       % Same result in all four cases
%
%       A = [1.2 3.14; -5 20];
%       md5(A)
%       md5(A(:))
%       md5(typecast(A(:), 'int8'), true)
%       md5(typecast(A(:), 'uint8'), true)
%
%    See also typecast.

% Copyright 2016 Chair of Medical Engineering, RWTH Aachen University
% Written by Christoph Hänisch (haenisch@hia.rwth-aachen.de)
% Version 1.0
% Last changed on 2016-08-05.
% License: Modified BSD License (BSD license with non-military-use clause)


    %% Check input arguments

    if nargin < 2
        already_byte_stream = false;
    end

    message = message(:);

    % Handle text input as a special case.

    if ischar(message)
        message = int8(message);
        already_byte_stream = true;
    end

    if ~already_byte_stream
        message = typecast(double(message), 'int8');
    end

    %% Compute the digest
    
    md = java.security.MessageDigest.getInstance('MD5');
    digest_byte = md.digest(message);
 
    digest = reshape(dec2hex(typecast(digest_byte, 'uint8'))', 1, []);
end