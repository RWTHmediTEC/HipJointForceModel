function activeFascicles = parseActiveMuscles(activeMuscles, muscleList)

% Workaround for some older models with additonal info (columns) in the active muscle variable
if size(activeMuscles,2) > 1
    activeFascicles = activeMuscles;
    return
end

if all(cellfun(@(x) isempty(regexp(x,'\d$','once')), activeMuscles))
    % If active muscles are not passed as fascicles (with a number at the end)
    
    % Find the muscles that contain the muscle name
    tempMuscleIdx = contains(muscleList(:,1),activeMuscles);
    % Copy the number of fascicles from the muscle list
    tempMuscles = muscleList(tempMuscleIdx,[1,4]);
    % Preallocate the active fascicles based on the number of fascicles
    activeFascicles = cell(sum(cell2mat(tempMuscles(:,2))),1);
    sIdx = 1+cumsum(cell2mat(tempMuscles(:,2)))-cell2mat(tempMuscles(:,2));
    eIdx = cumsum(cell2mat(tempMuscles(:,2)));
    % Create the active fascicles
    for m = 1:size(tempMuscles,1)
        activeFascicles(sIdx(m):eIdx(m)) = cellstr(num2str((1:tempMuscles{m,2})', [tempMuscles{m,1} '%d']));
    end
    
elseif any(cellfun(@(x) isempty(regexp(x,'\d$','once')), activeMuscles))
    % Other cases coud be implemented
    error(['Invalid format to specify the active muscles. Use either ' ...
        'muscle names or fascicles with a number at the end!'])
else
    activeFascicles = activeMuscles;
end

end