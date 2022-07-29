%__________________________________________________________________________
% Author: Luca Modenese, September 2014
% email: l.modenese@griffith.edu.au
%
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
% Function to check if the specified folder exists.
% If it does not, the folder is created.

function checkFolder(folder)

if ~isdir(folder)
    warning(['Folder ', folder, ' does not exist. It will be created.'])
    mkdir(folder);
end

end
