%%Packs all variables in workspace into one structure.  Structure name must
%%be set before this script is run, and must be set as string with name
%%structname.  This script uses/overwrites the variable temp_var, and then clears
%%it.  Variables which the user does not want included in the struct need
%%to be added as strings to a cell array with the name 'ignore'.


varnames = who;

if exist('ignore','var')
    varnames = varnames(~strcmp(varnames,'ignore'));
    for temp_var = 1:length(ignore)
       varnames = varnames(~strcmp(varnames,ignore{temp_var})); 
    end    
end
varnames = varnames(~strcmp(varnames,'structname'));
varnames = varnames(~strcmp(varnames,structname));
varnames = varnames(~strcmp(varnames,'varnames'));

for temp_var = 1:length(varnames)
    eval([structname,'.',varnames{temp_var},'=',varnames{temp_var},';']);
end
clear temp_var;


