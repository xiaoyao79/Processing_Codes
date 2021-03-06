function openimx(filename)
%OPENIMX  Import an IMX file from the Current Directory browser
%   Click on a IMX file in the Current Directory browser to import the
%   data. A variable named 'im' is created (or overwrited) in the workspace.
%
%   See also LOADVEC


%   F. Moisy, moisy_at_fast.u-psud.fr
%   Revision: 1.00,  Date: 2009/08/26
%   This function is part of the PIVMat Toolbox


% History:
% 2009/08/26: v1.00, first version.


if evalin('base','exist(''im'',''var'')')
    p = load('pivmat_settings');
    if ~p.allow_overwrite
        button = questdlg(['Variable ''im'' already exists!'],'Import VEC file','Overwrite','Cancel','Overwrite');
        if strncmpi(button,'Cancel',2)
            return
        end
    end
end

assignin('base','im',loadvec(filename));
