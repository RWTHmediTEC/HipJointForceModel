classdef Cache < handle
    % CACHE   Simple in-memory and on-disk cache class
    %
    %    cache = Cache(...)
    %
    %    This class allows storing data in the form of (key, value) pairs.
    %    The underlying associative array has a limited space thus
    %    discarding older entries (in terms of read and write access) if
    %    new entries are stored. It can be specified, if the data is stored
    %    in memory and/or on disk.
    %
    %    The behavior of this class can be controled using optional
    %    arguments which can be passed in the form of keyword-value pairs 
    %    ('<OptionName>', <value>) with the following meanings: 
    %
    %       'CacheDirectory'    -   Folder in which the cache data is
    %                               stored. Defaults to the system's
    %                               temporary folder.
    %
    %       'HashFunction'      -   Function internally used to transform
    %                               the key values into character strings.
    %                               Defaults to '@md5'.
    %
    %       'InMemoryCacheSize' -   Maximum number of items that are stored
    %                               in memory. The specified value must be
    %                               at least 1. Defaults to a value of 10.
    %
    %       'StoreOnDisk'       -   If this flag is set to 'true', the
    %                               cache data is also stored on disk. The
    %                               default value is 'true'.
    %
    %    Class methods:
    %
    %       clear                   - Clear the in-memory cache
    %       get                     - Restore a datum from the cache
    %       isCached                - Check if a datum is cached
    %       setCacheDirectory    	- Set the cache directory
    %       setInMemoryCacheSize    - Set the the in-memory cache size
    %       store                   - Store a datum in the cache
    %
    %    Type 'help Cache/<method name>' to obtain additional help.
    %
    %
    %    Example:
    %
    %       % Cache a single value
    %
    %       cache = Cache('StoreOnDisk', false);
    %       for i = 1:5 % simulate reuse in a program
    %          key = 'test';
    %          value = cache.get(key);
    %          if isempty(value)
    %             disp('Computing value...')
    %             pause(1);
    %             value = 1
    %             cache.store(key, value);
    %          end
    %          disp(value)
    %       end
    %
    %
    %    Example:
    %
    %       % Cache multiple values
    %
    %       key = [meshHash(source_mesh) meshHash(target_mesh) md5(alpha)];
    %       if cache.isCached(key)
    %          [transformed_mesh, inlier_mask] = unpack(cache.get(key));
    %       else
    %          [transformed_mesh, inlier_mask] = ...
    %                nonRigidICP(source_mesh, target_mesh, 'alpha', alpha);
    %          cache.store(key, {transformed_mesh, inlier_mask})
    %       end
    %
    %
    %    See also md5 and unpack (tools library).

    % Written by Christoph Hänisch (haenisch@hia.rwth-aachen.de)
    % Version 1.2.1
    % Last changed on 2016-08-10
    % Licence: Modified BSD License (BSD license with non-military-use clause)


    properties (Access = private)
        cache_size % in memory cache size
        cache_directory
        data % cache data stored in memory; data is an array of structures with the fields 'key', 'datum', and 'time'
        hash_function
        store_on_disk
    end


    methods

        function obj = Cache(varargin)
            path_backup = path();
            prefix = fileparts(mfilename('fullpath')); % path to current m-file
            if exist([prefix '/libs/md5'],'dir')
                addpath([prefix '/libs/md5']);
            end

            isInteger = @(value) ~mod(value, 1);
            isIntegerGreaterThanZero = @(value) isInteger(value) && value > 0;

            parser = inputParser;

            addParameter(parser, 'CacheDirectory', tempdir, @ischar);
            addParameter(parser, 'HashFunction', @md5, @(x) isa(x, 'function_handle'));
            addParameter(parser, 'InMemoryCacheSize', 10, isIntegerGreaterThanZero);
            addParameter(parser, 'StoreOnDisk', true, @islogical);

            parse(parser, varargin{:});
            
            obj.data = [];
            obj.cache_size = parser.Results.InMemoryCacheSize;
            obj.cache_directory = parser.Results.CacheDirectory;
            obj.hash_function = parser.Results.HashFunction;
            obj.store_on_disk = parser.Results.StoreOnDisk;
            
            path(path_backup);
        end


        function datum = get(obj, key, fallback_function)
            % Request a value from the cache.
            %
            % datum = get(key)
            %
            %    Returns the datum associated with 'key'. An empty array is
            %    returned if the associated datum is not available.
            %
            %    A call to this method also updates the 'accessed' property
            %    related to the key and datum, if applicable.
            %
            % datum = get(key, fallback_function)
            %
            %    Returns the datum associated with 'key'. If the associated
            %    datum is not available, the fallback function is called
            %    and its return value is returned; this return value is
            %    also stored in the cache.
            %
            %    A call to this method updates the 'accessed' property
            %    related to the key and datum, if applicable.
            %
            % Example:
            %
            %    function result = f(value)
            %       % do something computationally expensive...
            %    end
            %
            %    cache = Cache();
            %    datum = cache.get(value, @() f(value))

            if nargin < 3
                fallback_function = [];
            end

            user_key = key;
            key = obj.hash_function(key);

            for i = 1:length(obj.data)
                if isequal(obj.data(i).key, key)
                    datum = obj.data(i).datum;
                    obj.data(i).time = datenum(datetime('now')); % update access time
                    return
                end
            end

            if obj.store_on_disk
                datum = obj.loadFromDisk(key);
                if ~isempty(datum) % anything found on disk?
                    % Store the datum in memory; avoid storing it on disk again
                    obj.store_on_disk = false;
                    obj.store(user_key, datum)
                    obj.store_on_disk = true;
                    return
                end
            end

            if ~isempty(fallback_function)
                datum = fallback_function();
                obj.store(user_key, datum)
                return
            end

            datum = [];
        end


        function clear(obj, clear_on_disk_cache)
            % Clear the entire cache.
            %
            % clear()
            % clear(clear_on_disk_cache)
            %
            % If no arguments are given or if 'clear_on_disk_cache' is set
            % to 'false',  only the in-memory cache is cleared. In this
            % case, files stored on the hard drive are not affected.
            %
            % If 'clear_on_disk_cache' is set to 'true', all files residing
            % in 'CacheDirectory' that match the pattern 'cache_*.mat' are
            % deleted.
            
            obj.data = [];
            
            if nargin < 2
                clear_on_disk_cache = false;
            end
            
            assert(islogical(clear_on_disk_cache), 'Input argument must be of type logical.')
            
            if clear_on_disk_cache
                delete([obj.cache_directory, '/cache_*.mat'])
            end
        end


        function bool = isCached(obj, key)
            % Check if a value associated with the given key is stored.
            %
            % value = isCached(key)
            %
            % Returns 'true' if the associated datum is available;
            % otherwise 'false' is returned.

            key = obj.hash_function(key);
            bool = false;

            for i = 1:length(obj.data)
                if isequal(obj.data(i).key, key)
                    bool = true;
                    return
                end
            end
            
            if obj.store_on_disk
                bool = obj.isOnDisk(key);
            end
        end


        function setCacheDirectory(obj, folder)
            % Specify the storage folder for cache values.
            %
            % setCacheDirectory(folder)
            %
            % Set the cache directory, i.e. the folder in which the cache
            % data is stored. If no folder is given, the cache directory is
            % set to the system's temporary folder.
            
            if nargin > 1
                assert(ischar(folder), 'Folder must be a valid character string.')
                assert(exist(folder, 'dir') > 0, 'Folder does not exist.')
                obj.cache_directory = folder;
            else
                obj.cache_directory = tempdir;
            end
        end


        function setInMemoryCacheSize(obj, cache_size)
            % Specify the in memory chace size.
            %
            % setInMemoryCacheSize(cache_size)
            %
            % Set the maximum number of items that are stored in memory. If
            % the current cache size is greater than 'cache_size', it is
            % adapted accordingly deleting older data (in terms of the
            % 'accessed' property) first.
            
            obj.cache_size = cache_size;

            % Clear old entries such that the cache size conforms to the
            % specified size.

            if length(obj.data) > cache_size
                % preallocate memory
                data_shortened(cache_size).key = [];
                data_shortened(cache_size).datum = [];
                data_shortened(cache_size).time = [];

                [~, sorted_by_time] = sort([obj.data.time]);

                for i = 1:cache_size
                    data_shortened(i) = obj.data(sorted_by_time(end-cache_size+i));
                end

                obj.data = data_shortened;
            end
        end


        function store(obj, key, datum)
            % Store a value associated with a key in the cache.
            %
            % store(key, datum)
            %
            % Stores the given 'datum' associated with 'key' in the cache.
            % If the cache is already full, the item that was not accessed
            % longest is replaced.

            oldest_entry = [];
            time = inf;

            % Overwrite an entry with the same key if present...

            key = obj.hash_function(key);

            for i = 1:length(obj.data)
                if isequal(obj.data(i).key, key)
                    obj.data(i).datum = datum;
                    obj.data(i).time = datenum(datetime('now')); % update access time
                    if obj.store_on_disk
                        obj.storeOnDisk(key, datum)
                    end
                    return
                end

                if obj.data(i).time < time
                    time = obj.data(i).time;
                    oldest_entry = i;
                end
            end

            % ... otherwise store a new entry. The entry is appended if the
            % cache is not yet full, otherwise the oldest entry (in terms of
            % storage date or access date) is overwritten.

            if length(obj.data) < obj.cache_size
                i = length(obj.data) + 1;
                obj.data(i).key = key;
                obj.data(i).datum = datum;
                obj.data(i).time = datenum(datetime('now')); % update access time
            else
                assert(~isempty(oldest_entry), 'Logical error...')
                obj.data(oldest_entry).key = key;
                obj.data(oldest_entry).datum = datum;
                obj.data(oldest_entry).time = datenum(datetime('now')); % update access time
            end

            if obj.store_on_disk
                obj.storeOnDisk(key, datum)
            end
        end
        
    end % methods


    methods (Access = private)

        function bool = isOnDisk(obj, key)
            bool = exist([obj.cache_directory, '/cache_', key, '.mat'], 'file') == 2;
        end


        function datum = loadFromDisk(obj, key)
            % Returns an empty array [] if the file cannot be loaded.
            try
                vars = load([obj.cache_directory, '/cache_', key, '.mat']);
                datum = vars.datum;
            catch ME
                if strcmp(ME.identifier, 'MATLAB:load:couldNotReadFile')
                    datum = [];
                else
                    rethrow(ME)
                end
            end
        end


        function storeOnDisk(obj, key, datum)  %#ok<INUSD>
            save([obj.cache_directory, '/cache_', key, '.mat'], 'datum', '-v7.3')
        end

    end % private methods


end % class Cache
