function idisct = inc_disc_thickness(u,y,Uinfty)
%When given a vector of the velocities and vertical locations of the
%velocities (with y=0 being the surface) and the freestream velocity 
%this function calculates the incompressible displacement
%thickness of the boundary layer for which the data is provided.

idisct=0;
for i=2:1:length(u)
    idisct=idisct+(1-u(i)/Uinfty)*(y(i)-y(i-1));
end