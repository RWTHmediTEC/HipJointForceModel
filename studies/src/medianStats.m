function statsCell = medianStats(data, varargin)
p = inputParser;
addRequired(p,'data',@(x) validateattributes(x,{'numeric'},{'ncols', 1}))
addOptional(p,'fSpec', '% 1.1f');
addParameter(p,'format', 'long',@(x) any(validatestring(x,{'long','short'})));
parse(p,data,varargin{:});
fSpec = p.Results.fSpec;
format = p.Results.format;

PRCT=prctile(data,[0,25,50,75,100]);
IQR=iqr(data);
RNG=range(data);

switch format
    case 'long'
        statsCell = {...
            num2str(PRCT(3),fSpec),... % median
            [num2str(IQR,fSpec), ' (' num2str(PRCT(2),fSpec) ' to ' num2str(PRCT(4),fSpec) ')'], ... % IQR
            [num2str(RNG,fSpec), ' (' num2str(PRCT(1),fSpec) ' to ' num2str(PRCT(5),fSpec) ')'], ... % Range
            };
    case 'short'
        statsCell = {[num2str(PRCT(3),fSpec) ' (' num2str(IQR,fSpec) ')']};
end

end

