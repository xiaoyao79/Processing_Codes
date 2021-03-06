function PullNumericalValues2(NumGrid,DesGrid,phys,src_dir,flist,save_name)

    %Find Desired Sample Times
    lt = NumGrid.dt*length(flist);
    td = (0:1/DesGrid.FS:lt) + NumGrid.t0;
    Nd = length(td);
    
    %Find file sample pairs
    Nf = length(flist);
    tn = zeros(1,Nf);
    h = waitbar(0,'Loading Time Values...');
    for n = 1:Nf
        tmp = load([src_dir filesep flist{n}],'t');
        tn(n) = tmp.t;
        waitbar(n/Nf,h);
    end 
    close(h);drawnow;
    pairs = cell(1,Nd);
    for n = 1:Nd
        [~,I] = sort(abs(td(n)-tn));
        pairs{n}(1) = sort(I(1));
        chk = sign(td(n)-tn(I(1)));
        if chk >= 0 && (pairs{n}(1)+1 <= Nf)
            pairs{n}(2) = pairs{n}(1)+1;
        else
            pairs{n}(2) = pairs{n}(1)-1;
        end
        pairs{n} = sort(pairs{n});
    end    

    %Initialize Outputs & Container Variables
    containers = cell(length(phys),1);
    for q = 1:length(phys)
        containers{q} = zeros([size(NumGrid.x) 2]);
        output.(phys{q}) = ones([size(DesGrid.x) Nd])*0;
    end
    X = repmat(NumGrid.x,[1 1 2]);
    Y = repmat(NumGrid.r,[1 1 2]);
    T = zeros(size(X));   
    
    %Pull Desired Numerical Data and Interpolate
    for n = 1:Nd
        tic;
        disp(['Processing timestep: ',num2str(n),' of ',num2str(Nd)]);
        
        %Pull data
        for nn = 1:2
            data = load([src_dir filesep flist{pairs{n}(nn)}]);
            T(:,:,nn) = repmat(data.t,size(data.x));
            for q = 1:length(phys)
                containers{q}(:,:,nn) = data.(phys{q});
            end 
        end
        
        %Interpolate onto Desired Grid
        Ti = repmat(td(n),size(DesGrid.x));
        for q = 1:length(phys)
            output.(phys{q})(:,:,n) = N3Interpolate(Y,X,T,containers{q},DesGrid.y,DesGrid.x,Ti);
        end 
        disp(['Compute time: ',num2str(toc/60,'%5.1f'),' min']);
    end
    
    %Save output .mat file
    output.x = DesGrid.x;
    output.y = DesGrid.y;
    output.t = td;
    if strcmpi(save_name(end-4:end),'.mat'), save_name = [save_name '.mat']; end
    save(save_name,'-struct','output');
end