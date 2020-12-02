function result = isValidMesh(input, throw_error)

% ISVALIDMESH   Check input parameter for being a triangle mesh.
%
%    result = isValidMesh(input)
%    result = isValidMesh(input, throw_error)
%
%    If the given input is a valid triangle mesh this functions returns
%    true; otherwise false. In addition, an error is thrown. This behavior
%    can be altered by setting the second parameter to false.
%
%    A valid triangle mesh must be given as an indexed face-set data
%    structure with the following fields:
%
%       mesh.vertices           The vertices are given as vertically
%                               stacked rows (i.e. an n-by-3 matrix) where
%                               each row denotes a vertex location [x y z]
%                               in space.
%
%       mesh.faces              The faces are also given in the form of
%                               vertically stacked rows. Each row contains
%                               three integer indeces [id1 id2 id3]
%                               referencing the respective vertices in
%                               'mesh.vertices'.
%
%       mesh.normals            Face normals are given as an m-by-3 matrix
%                               of type double. This field is optionally.
%
%       mesh.vertex_normals     Vertex normals are given as an n-by-3
%                               matrix of type double. This field is
%                               optionally.

% Copyright 2016 Chair of Medical Engineering, RWTH Aachen University
% Written by Christoph Hänisch (haenisch@hia.rwth-aachen.de)
% Version 1.1
% Last changed on 2016-01-21.
% License: Modified BSD License (BSD license with non-military-use clause)

    %% Check input arguments
    
    if nargin < 2
        throw_error = true;
    end

    if throw_error
        errorFunction = @error;
    else
        errorFunction = @(str) nop;
    end

    %% Check for a valid mesh

    if ~isstruct(input)
        errorFunction('Invalid triangle mesh.')
        result = false;
        return
    end

    if ~isfield(input, 'vertices')
        errorFunction('Input mesh does not provide field variable ''vertices''.');
        result = false;
        return
    end

    if ~(size(input.vertices, 2) == 3)
        errorFunction('The vertices must be given as a n-by-3 matrix.')
        result = false;
        return
    end

    if ~isfield(input, 'faces')
        errorFunction('Input mesh does not provide field variable ''faces''.');
        result = false;
        return
    end

    if ~(size(input.faces, 2) == 3)
        errorFunction('The vertices must be given as a m-by-3 matrix.')
        result = false;
        return
    end

    if isfield(input, 'normals')
        if ~(size(input.normals, 2) == 3)
            errorFunction('Normals must be given as a m-by-3 matrix.');
            result = false;
            return
        end
        if ~all(size(input.normals) == size(input.faces))
            errorFunction('Number of normals do not correspond to number of faces.');
            result = false;
            return
        end
    end

    if isfield(input, 'vertex_normals')
        if ~(size(input.vertex_normals, 2) == 3)
            errorFunction('Vertex normals must be given as a n-by-3 matrix.');
            result = false;
            return
        end
        if ~all(size(input.vertex_normals) == size(input.vertices))
            errorFunction('Number of vertex normals do not correspond to number of vertices.');
            result = false;
            return
        end
    end

    result = true;

end


function nop()
    % This function intentionally does nothing.
end