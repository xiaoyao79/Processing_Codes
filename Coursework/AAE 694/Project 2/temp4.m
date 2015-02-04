function [] = temp4(dx,dt,Mx,My)
    tic;
    dy = dx;
    X = -100:dx:100;
    Y = -100:dy:100;
    [x, y] = meshgrid(X,Y);
    time_itr_max = 0.05*2000; 
    foldername = [num2str(length(X)),' x ',num2str(length(Y)), ' Mx', strrep(num2str(Mx),'.','_'), ' My',strrep(num2str(My),'.','_')];
    shift = [0 0 -1];
    
    %Boundary condition coefficients
    r = sqrt(x.^2+y.^2);
    V = Mx*(x./r)+My*(y./r)+sqrt(1-(Mx*(y./r)-My*(x./r)).^2);
    A = V.*(x./r);
    B = V.*(y./r);
    C = V./(2*r); 
    
    %3rd order optimized time discretization coefficients (b0, b1, b2, b3)
    b = [2.3025580883830 -2.4910075998482 1.5743409331815 -0.38589142217162];
    plot_times = 0.05*[1 100:100:1200 1600 2000 12000];

    %itialize variables
    rho = zeros(length(y),length(x),4);
    u = rho; v = rho; p = rho;    
    Drho = rho;
    Du = u;
    Dv = v;
    Dp = p;
    
    %initial conditions
    rho(:,:,4) = 0.01*exp(-log(2)*(x.^2+y.^2)/9)+0.001*exp(-log(2)*((x-67).^2+y.^2)/25);
    u(:,:,4) = 0.0004*y.*exp(-log(2)*((x-67).^2+y.^2)/25);
    v(:,:,4) = -0.0004*(x-67).*exp(-log(2)*((x-67).^2+y.^2)/25);
    p(:,:,4) = 0.01*exp(-log(2)*(x.^2+y.^2)/9);
    
    g = figure;
%     if exist(foldername,'file') ~= 7
%         mkdir(pwd,foldername);
%     end
%     cd(foldername);
    h = waitbar(0,'Calculating...');
    imax = length(0:dt:time_itr_max)-1;
    for i = 1:imax %time step loop
        waitbar(i/imax,h,['i = ',num2str(i)]);

        %time shift spatial derivative matrices
        Drho = circshift(Drho,shift);
        Du = circshift(Du,shift);
        Dv = circshift(Dv,shift);
        Dp = circshift(Dp,shift);
        
        %interior nodes
        Drhoi = NumericalDerivative(1,6,dx,-(Mx*rho(:,:,4)+u(:,:,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*rho(:,:,4)+v(:,:,4))','-DRP')'; 
        Dui = NumericalDerivative(1,6,dx,-(Mx*u(:,:,4)+p(:,:,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*u(:,:,4))','-DRP')';
        Dvi = NumericalDerivative(1,6,dx,-(Mx*v(:,:,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*v(:,:,4)+p(:,:,4))','-DRP')';
        Dpi = NumericalDerivative(1,6,dx,-(Mx*p(:,:,4)+u(:,:,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*p(:,:,4)+v(:,:,4))','-DRP')';
        
        %left boundary (radiation)
        Drhol = A(:,1:7).*NumericalDerivative(1,6,dx,-(rho(:,1:7,4)),'-DRP')+B(:,1:7).*NumericalDerivative(1,6,dy,-(rho(:,1:7,4))','-DRP')'-C(:,1:7).*rho(:,1:7,4); 
        Dul = A(:,1:7).*NumericalDerivative(1,6,dx,-(u(:,1:7,4)),'-DRP')+B(:,1:7).*NumericalDerivative(1,6,dy,-(u(:,1:7,4))','-DRP')'-C(:,1:7).*u(:,1:7,4);
        Dvl = A(:,1:7).*NumericalDerivative(1,6,dx,-(v(:,1:7,4)),'-DRP')+B(:,1:7).*NumericalDerivative(1,6,dy,-(v(:,1:7,4))','-DRP')'-C(:,1:7).*v(:,1:7,4);
        Dpl = A(:,1:7).*NumericalDerivative(1,6,dx,-(p(:,1:7,4)),'-DRP')+B(:,1:7).*NumericalDerivative(1,6,dy,-(p(:,1:7,4))','-DRP')'-C(:,1:7).*p(:,1:7,4);
        
        %right boundary
        if Mx == 0 %radiation boundary conditions            
            Drhor = A(:,end-6:end).*NumericalDerivative(1,6,dx,-(rho(:,end-6:end,4)),'-DRP')+B(:,end-6:end).*NumericalDerivative(1,6,dy,-(rho(:,end-6:end,4))','-DRP')'-C(:,end-6:end).*rho(:,end-6:end,4);           
            Dur = A(:,end-6:end).*NumericalDerivative(1,6,dx,-(u(:,end-6:end,4)),'-DRP')+B(:,end-6:end).*NumericalDerivative(1,6,dy,-(u(:,end-6:end,4))','-DRP')'-C(:,end-6:end).*u(:,end-6:end,4);
            Dvr = A(:,end-6:end).*NumericalDerivative(1,6,dx,-(v(:,end-6:end,4)),'-DRP')+B(:,end-6:end).*NumericalDerivative(1,6,dy,-(v(:,end-6:end,4))','-DRP')'-C(:,end-6:end).*v(:,end-6:end,4);
            Dpr = A(:,end-6:end).*NumericalDerivative(1,6,dx,-(p(:,end-6:end,4)),'-DRP')+B(:,end-6:end).*NumericalDerivative(1,6,dy,-(p(:,end-6:end,4))','-DRP')'-C(:,end-6:end).*p(:,end-6:end,4);
        else %outflow boundary conditions
            Drhor = NumericalDerivative(1,6,dx,-Mx*rho(:,end-6:end,4)+Mx*p(:,end-6:end,4),'-DRP')+A(:,end-6:end).*NumericalDerivative(1,6,dx,-p(:,end-6:end,4),'-DRP')+NumericalDerivative(1,6,dy,(-My*rho(:,end-6:end,4)+My*p(:,end-6:end,4))','-DRP')'+B(:,end-6:end).*NumericalDerivative(1,6,dy,-p(:,end-6:end,4)','-DRP')'-C(:,end-6:end).*p(:,end-6:end,4);
            Dur = NumericalDerivative(1,6,dx,-(Mx*u(:,end-6:end,4)+p(:,end-6:end,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*u(:,end-6:end,4))','-DRP')';
            Dvr = NumericalDerivative(1,6,dx,-(Mx*v(:,end-6:end,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*v(:,end-6:end,4)+p(:,end-6:end,4))','-DRP')';
            Dpr = A(:,end-6:end).*NumericalDerivative(1,6,dx,-(p(:,end-6:end,4)),'-DRP')+B(:,end-6:end).*NumericalDerivative(1,6,dy,-(p(:,end-6:end,4))','-DRP')'-C(:,end-6:end).*p(:,end-6:end,4);
        end  
        
        %bottom boundary (radiation)
        Drhob = A(end-6:end,:).*NumericalDerivative(1,6,dx,-(rho(end-6:end,:,4)),'-DRP')+B(end-6:end,:).*NumericalDerivative(1,6,dy,-(rho(end-6:end,:,4))','-DRP')'-C(end-6:end,:).*rho(end-6:end,:,4);      
        Dub = A(end-6:end,:).*NumericalDerivative(1,6,dx,-(u(end-6:end,:,4)),'-DRP')+B(end-6:end,:).*NumericalDerivative(1,6,dy,-(u(end-6:end,:,4))','-DRP')'-C(end-6:end,:).*u(end-6:end,:,4);
        Dvb = A(end-6:end,:).*NumericalDerivative(1,6,dx,-(v(end-6:end,:,4)),'-DRP')+B(end-6:end,:).*NumericalDerivative(1,6,dy,-(v(end-6:end,:,4))','-DRP')'-C(end-6:end,:).*v(end-6:end,:,4);
        Dpb = A(end-6:end,:).*NumericalDerivative(1,6,dx,-(p(end-6:end,:,4)),'-DRP')+B(end-6:end,:).*NumericalDerivative(1,6,dy,-(p(end-6:end,:,4))','-DRP')'-C(end-6:end,:).*p(end-6:end,:,4);
        
        %top boundary
        if My == 0 %radiation boundary conditions
            Drhot = A(1:7,:).*NumericalDerivative(1,6,dx,-(rho(1:7,:,4)),'-DRP')+B(1:7,:).*NumericalDerivative(1,6,dy,-(rho(1:7,:,4))','-DRP')'-C(1:7,:).*rho(1:7,:,4);
            Dut = A(1:7,:).*NumericalDerivative(1,6,dx,-(u(1:7,:,4)),'-DRP')+B(1:7,:).*NumericalDerivative(1,6,dy,-(u(1:7,:,4))','-DRP')'-C(1:7,:).*u(1:7,:,4);
            Dvt = A(1:7,:).*NumericalDerivative(1,6,dx,-(v(1:7,:,4)),'-DRP')+B(1:7,:).*NumericalDerivative(1,6,dy,-(v(1:7,:,4))','-DRP')'-C(1:7,:).*v(1:7,:,4);
            Dpt = A(1:7,:).*NumericalDerivative(1,6,dx,-(p(1:7,:,4)),'-DRP')+B(1:7,:).*NumericalDerivative(1,6,dy,-(p(1:7,:,4))','-DRP')'-C(1:7,:).*p(1:7,:,4);
        else %outflow boundary conditions          
            Drhot = NumericalDerivative(1,6,dx,-Mx*rho(1:7,:,4)+Mx*p(1:7,:,4),'-DRP')+A(1:7,:).*NumericalDerivative(1,6,dx,-p(1:7,:,4),'-DRP')+NumericalDerivative(1,6,dy,(-My*rho(1:7,:,4)+My*p(1:7,:,4))','-DRP')'+B(1:7,:).*NumericalDerivative(1,6,dy,-p(1:7,:,4)','-DRP')'-C(1:7,:).*p(1:7,:,4);
            Dut = NumericalDerivative(1,6,dx,-(Mx*u(1:7,:,4)+p(1:7,:,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*u(1:7,:,4))','-DRP')';
            Dvt = NumericalDerivative(1,6,dx,-(Mx*v(1:7,:,4)),'-DRP')+NumericalDerivative(1,6,dy,-(My*v(1:7,:,4)+p(1:7,:,4))','-DRP')';
            Dpt = A(1:7,:).*NumericalDerivative(1,6,dx,-(p(1:7,:,4)),'-DRP')+B(1:7,:).*NumericalDerivative(1,6,dy,-(p(1:7,:,4))','-DRP')'-C(1:7,:).*p(1:7,:,4);
        end
        
        Drho(:,:,4) = [Drhol(:,1:3) [Drhot(1:3,4:end-3); Drhoi(4:end-3,4:end-3); Drhob(5:7,4:end-3)] Drhor(:,5:end)];
        Du(:,:,4) = [Dul(:,1:3) [Dut(1:3,4:end-3); Dui(4:end-3,4:end-3); Dub(5:7,4:end-3)] Dur(:,5:end)];
        Dv(:,:,4) = [Dvl(:,1:3) [Dvt(1:3,4:end-3); Dvi(4:end-3,4:end-3); Dvb(5:7,4:end-3)] Dvr(:,5:end)];
        Dp(:,:,4) = [Dpl(:,1:3) [Dpt(1:3,4:end-3); Dpi(4:end-3,4:end-3); Dpb(5:7,4:end-3)] Dpr(:,5:end)];        
 
        rhoswitch = rho(:,:,4)+dt*(b(1)*Drho(:,:,4)+b(2)*Drho(:,:,3)+b(3)*Drho(:,:,2)+b(4)*Drho(:,:,1));
        uswitch = u(:,:,4)+dt*(b(1)*Du(:,:,4)+b(2)*Du(:,:,3)+b(3)*Du(:,:,2)+b(4)*Du(:,:,1));
        vswitch = v(:,:,4)+dt*(b(1)*Dv(:,:,4)+b(2)*Dv(:,:,3)+b(3)*Dv(:,:,2)+b(4)*Dv(:,:,1));
        pswitch = p(:,:,4)+dt*(b(1)*Dp(:,:,4)+b(2)*Dp(:,:,3)+b(3)*Dp(:,:,2)+b(4)*Dp(:,:,1));  
                                      
   
        %%shift physical variable matrices
        rho = circshift(rho,shift); 
        u = circshift(u,shift);
        v = circshift(v,shift);
        p = circshift(p,shift);
        rho(:,:,4) = rhoswitch;        
        u(:,:,4) = uswitch;        
        v(:,:,4) = vswitch;        
        p(:,:,4) = pswitch;        
        
        figure(g);
        surf(X,Y,rho(:,:,4)); shading interp; view([45 45]);drawnow;title(['Density profile, i = ',num2str(i) ', sum(p^2_{bottom}) = ' num2str(sum(rho(end,:,4).^2))]);
%         saveas(g,['densitysurf_i' num2str(i)]);

%         if any(abs(dt*i - plot_times) <= eps)
%             pcolor(X,Y,rho(:,:,end)); colorbar; shading interp; colormap(flipud(gray)); xlabel('x'); ylabel('y'); title(['Density contour for t = ',num2str(dt*i),', dx = ', num2str(dx),', dt = ', num2str(dt)]);
%             saveas(gcf,['density_i',num2str(i)],'fig');
%             
%             pcolor(X,Y,u(:,:,end)); colorbar; shading interp; colormap(flipud(gray)); xlabel('x'); ylabel('y'); title(['U velocity contour for t = ',num2str(dt*i),', dx = ', num2str(dx),', dt = ', num2str(dt)]);
%             saveas(gcf,['u_i',num2str(i)],'fig');
%             
%             pcolor(X,Y,v(:,:,end)); colorbar; shading interp; colormap(flipud(gray)); xlabel('x'); ylabel('y'); title(['V velocity contour for t = ',num2str(dt*i),', dx = ', num2str(dx),', dt = ', num2str(dt)]);
%             saveas(gcf,['v_i',num2str(i)],'fig');
%             
%             pcolor(X,Y,p(:,:,end)); colorbar; shading interp; colormap(flipud(gray)); xlabel('x'); ylabel('y'); title(['Pressure contour for t = ',num2str(i),', dx = ', num2str(dx),', dt = ', num2str(dt)]);
%             saveas(gcf,['p_i',num2str(i)],'fig');
%             close all;
%         end
    end
%     cd ..
    close(h); close(g);
    compute_time = toc
end