function TFM = medicalCoordinateSystemTFM(origin, target)

TFM=convertRAS(target)*convertRAS(origin)';

end

function TFM=convertRAS(target)

switch target
%% R
    case 'RAS'
        % Convert 'RAS' to 'RAS'
        TFM = eye(4);
    case 'RSP'
        % Convert 'RAS' to 'RSP'
        TFM = createRotationOx(-pi/2);
    case 'RPI'
        % Convert 'RAS' to 'RPI'
        TFM = createRotationOx(   pi);
    case 'RIA'
        % Convert 'RAS' to 'RIA'
        TFM = createRotationOx( pi/2);
%% A
    case 'ALS'
        % Convert 'RAS' to 'ALS'
        TFM =                         createRotationOz(-pi/2);
    case 'ASR'
        % Convert 'RAS' to 'ASR'
        TFM = createRotationOx(-pi/2)*createRotationOz(-pi/2);
    case 'ARI'
        % Convert 'RAS' to 'ARI'
        TFM = createRotationOx(   pi)*createRotationOz(-pi/2);
    case 'AIL'
        % Convert 'RAS' to 'AIL'
        TFM = createRotationOx( pi/2)*createRotationOz(-pi/2);
%% L
    case 'LPS'
        % Convert 'RAS' to 'LPS'
        TFM =                         createRotationOz(pi);
    case 'LSA'
        % Convert 'RAS' to 'LSA'
        TFM = createRotationOx(-pi/2)*createRotationOz(pi);
    case 'LAI'
        % Convert 'RAS' to 'LAI'
        TFM = createRotationOx(   pi)*createRotationOz(pi);
    case 'LIP'
        % Convert 'RAS' to 'LIP'
        TFM = createRotationOx( pi/2)*createRotationOz(pi);
%% P
    case 'PRS'
        % Convert 'RAS' to 'PRS'
        TFM =                         createRotationOz(pi/2);
    case 'PSL'
        % Convert 'RAS' to 'PSL'
        TFM = createRotationOx(-pi/2)*createRotationOz(pi/2);
    case 'PLI'
        % Convert 'RAS' to 'PLI'
        TFM = createRotationOx(   pi)*createRotationOz(pi/2);
    case 'PIR'
        % Convert 'RAS' to 'PIR'
        TFM = createRotationOx( pi/2)*createRotationOz(pi/2);
%% I
    case 'IAR'
        % Convert 'RAS' to 'IAR'
        TFM =                         createRotationOy(-pi/2);
    case 'IRP'
        % Convert 'RAS' to 'IRP'
        TFM = createRotationOx(-pi/2)*createRotationOy(-pi/2);
    case 'IPL'
        % Convert 'RAS' to 'IPL'
        TFM = createRotationOx(   pi)*createRotationOy(-pi/2);
    case 'ILS'
        % Convert 'RAS' to 'ILS'
        TFM = createRotationOx( pi/2)*createRotationOy(-pi/2);
%% S
    case 'SAL'
        % Convert 'RAS' to 'SAL'
        TFM =                         createRotationOy( pi/2);
    case 'SLP'
        % Convert 'RAS' to 'SLP'
        TFM = createRotationOx(-pi/2)*createRotationOy( pi/2);
    case 'SPR'
        % Convert 'RAS' to 'SPR'
        TFM = createRotationOx(   pi)*createRotationOy( pi/2);
    case 'SRA'
        % Convert 'RAS' to 'SRA'
        TFM = createRotationOx( pi/2)*createRotationOy( pi/2);
end

end