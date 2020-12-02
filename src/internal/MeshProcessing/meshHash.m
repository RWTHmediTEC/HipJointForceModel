function hash = meshHash(mesh, precision)

% MESHHASH   Computes an MD5 hash value for a given mesh
%
%    hash = meshHash(mesh)
%    hash = meshHash(mesh, precision)
%
%    This function computes an MD5 hash value for a given mesh. The hash
%    value is constructed from the vertex and face information. If the
%    second parameter is specified, the vertices are rounded to 'precision'
%    digits to the right of the decimal point. If not specified,
%    'precision' defaults to 5.
%
%    Example:
%
%       mesh = loadSTL('demos/femur.stl');
%       hash = meshHash(mesh)
%
%       hash =
%
%       B7B71583F1F21E65FE0AF8D57B140FF2
%
%    See also Cache, isValidMesh, and md5.

% Last changed on 2016-08-25, Version 1.1
% Written by Christoph Hänisch
% Copyright 2016 Chair of Medical Engineering
% License: Modified BSD License (BSD license with non-military-use clause)

    %% Check the input arguments

    if nargin < 2
        precision = 5;
    end

    isInteger = @(value) ~mod(value, 1);

    assert(isValidMesh(mesh), 'Invalid mesh.')
    assert(isInteger(precision) && precision >= 0, 'Precision must be a positive integer value.')

    %% Compute the hash value

    hash1 = md5(round(mesh.vertices, precision));
    hash2 = md5(mesh.faces);
    hash = md5([hash1, hash2]);

end


function digest = md5(message)
    if ischar(message)
        message = int8(message(:));
    else
        message = typecast(double(message(:)), 'int8');
    end
    md = java.security.MessageDigest.getInstance('MD5');
    digest_byte = md.digest(message);
    digest = reshape(dec2hex(typecast(digest_byte, 'uint8'))', 1, []);
end