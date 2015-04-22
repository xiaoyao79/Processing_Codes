function [nneFun, MSE, weights] = FFN_PSO(xt,d,arch,varargin)
%This code constructs a static, fully-connected feed-forward neural
%network. Learning is accomplished solely using particle swarm
%optimization. The user must open a worker pool prior to calling this
%function if parallelization is desired.
%Last updated on 2015-04-21 by Michael Crawley.
%Inputs:
%           xt:         [M,N] matrix of training sets, where M is the
%                       number of training examples and N is the number of 
%                       input neurons.
%           d:          [M,P] matrix of desired outputs for training, where
%                       M is the number of training sets and P is the
%                       number of output neurons.
%           arch:       [1,L] array describing network architecture, where
%                       L is the number of layers (excluding input and
%                       output). For a network with three inputs, one output,
%                       and two hidden layers with two neurons, the network
%                       architecture would be [2,2].
%           options:
%               's':            Slope for the default activation function. 
%                               Default is 1.0.                 
%               'A':            Amplitude for the default activation function.
%                               Default is 1.0.
%               'maxepoch':     Maximum number of epochs for training. Default
%                               is 1e3.
%               'wrange':       Range for random assignent for initial weights.
%                               Default is +/- 2.4/N * 10.
%               'etotal':       MSE error for convergence. Default is eps^1/2.
%               'phi':          Activation function. Default is hyperbolic tangent.
%               'weights':      Initial weights, default is random within 
%                               [-wrange,wrange].
%               'particles':    Number of particles in swarm. Default is 1e3
%               'velocities':   Velocity update parameters - See
%                               constructor function.
%Outputs:
%           nneFun:     Function that performs neural network computations
%                       provided a single input set.
%           MSE:        Mean squared error over epochs.
%           weights:    Final neural network weights.
%           phi:        Activation function used by neural network.
%           params:     Struct containing all network parameters

    %Get matrix information
    [N,a1] = size(xt); %get number of training sets
    [N2,a2] = size(d);
    if N ~= N2
        error('Input Matrix Mismatch');
    end
    arch = [a1;arch(:);a2]; %append input and output neurons
    
    %Initialize Parameters
    [maxepoch,econv_total,phi,swarm,np,chi,alpha,c] = get_options(arch,varargin);
    MSE = zeros(maxepoch,1); %Container for Mean-Squared-Error over epochs
    L = length(arch);    
    
    %Build Output Function
    str = 'phi([x,-ones(N,1)]*weights{1})';
    for n = 2:L-1
        str = ['phi([' str ',-ones(N,1)]*weights{',num2str(n),'})'];
    end
    nneFun = eval(['@(x,weights,d) ' str, ' -d']);

    %Initialize local and global best values and positions
    parfor n = 1:np
        swarm(n).value = mean(mean(nneFun(xt,swarm(n).position,d).^2,2),1);
        swarm(n).best_value = swarm(n).value;
        swarm(n).best_position = swarm(n).position;
    end
    [global_best.value,I] = min([swarm.best_value]);
    global_best.position = swarm(I).best_position;
    
    %Set up progress bar
    cpb = ConsoleProgressBar();
    cpb.setLeftMargin(4);   % progress bar left margin
    cpb.setTopMargin(1);    % rows margin
    cpb.setLength(40);      % progress bar length: [.....]
    cpb.setMinimum(0);      % minimum value of progress range [min max]
    cpb.setMaximum(100);    % maximum value of progress range [min max]
    cpb.setPercentPosition('left');
    cpb.setTextPosition('right');
    cpb.setMinimum(0);
    cpb.setMaximum(maxepoch);
    cpb.start();
    
    for n = 1:maxepoch %epoch counter 
        
        %%FeedForward Computations
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        parfor q = 1:np
            %Update Position and Velocity
            for k = 1:L-1
                swarm(q).velocity{k} = chi*(alpha*swarm(q).velocity{k} + c(1)*rand(1)*(swarm(q).best_position{k}-swarm(q).position{k}) + c(2)*rand(1)*(global_best.position{k}-swarm(q).position{k}));
                swarm(q).position{k} = swarm(q).position{k} + swarm(q).velocity{k};
            end
            
            %Update error and local best value & position
            swarm(q).value = mean(mean(nneFun(xt,swarm(q).position,d).^2,2),1);
            if swarm(q).value < swarm(q).best_value
                swarm(q).best_value = swarm(q).value;
                swarm(q).best_position = swarm(q).position;
            end
        end
                
        %%Update MSE and Global bests        
        [itr_best_value,I] = min([swarm.best_value]);
        if itr_best_value < global_best.value
            global_best.value = itr_best_value;
            global_best.position = swarm(I).position;
        end
        MSE(n) = itr_best_value;
        
        %%Convergence Computations
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        if (MSE(n) < econv_total)
            MSE = MSE(1:n); %truncate
                                
            text = sprintf('Iteration: %d/%d [Converged]', n, maxepoch);  
            cpb.setValue(n);  	% update progress value
            cpb.setText(text);  % update user text
            fprintf('\n');
            break;
        end
        
        %Update user if not converged
        if n > 1
            dmse = MSE(n)-MSE(n-1);
        else
            dmse = 0;
        end
        text = sprintf('Iteration: %d/%d [MSE:%.3g,change:%.3g]', n, maxepoch,MSE(n),dmse);
        cpb.setValue(n);  	% update progress value
        cpb.setText(text);  % update user text
    end
    fprintf('\n');  

    %Build Final Function
    weights = global_best.position;
    str = 'phi([x,-ones(size(x,1),1)]*weights{1})';
    for n = 2:L-1
        str = ['phi([' str ',-ones(size(x,1),1)]*weights{',num2str(n),'})'];
    end
    nneFun = eval(['@(x) ' str]);    
end

function [maxepoch,econv_total,phi,swarm,np,chi,alpha,c] = get_options(arch,commands)
    %Determine inputs
    options = {'slope','amplitude','maxepoch','wrange','etotal','phi','particles','weights','velocity'};
    cmd = zeros(1,length(commands));
    for n = 1:length(commands)
        if ischar(commands{n})
            cmd(n) = find(ismember(options,commands{n}));
        end
    end
    
    %slope for activation function
    if any(cmd == 1)
        loc = find(cmd == 1) + 1;
        s = commands{loc};
    else
        s = 1.0;
    end
    
    %amplitude for activation function
    if any(cmd == 2)
        loc = find(cmd == 2)+1;
        A = commands{loc};
    else
        A = 1.0;
    end
    
    %maximum number of epochs for training
    if any(cmd == 3)
        loc = find(cmd == 3)+1;
        maxepoch = commands{loc};
    else
        maxepoch = 1e3; 
    end
    
    %range for random weight initialization
    if any(cmd == 4)
        loc = find(cmd == 4)+1;
        wrange = commands{loc};
    else
        wrange = 4.8/max(arch(1),1)*10; %fix in case no hidden layers exist
    end
    
    %Error limit for convergence based off of MSE
    if any(cmd == 5)
        loc = find(cmd == 5)+1;
        econv_total = commands{loc};
    else
        econv_total = sqrt(eps);
    end
    
    %Activation function
    if any(cmd == 6)
        loc = find(cmd == 6);
        phi = commands{loc+1};
    else
        phi = @(v) A*tanh(s*v); %scales between -A and A
    end
    
    %Number of particles in swarm
    if any(cmd == 7)
        loc = find(cmd == 7)+1;
        np = commands{loc};
    else
        np = 1e3;
    end
    
    %Initial weights
    if any(cmd == 8)
        loc = find(cmd == 8)+1;
        swarm = commands{loc};
    else
        L = length(arch);
        swarm(np) = struct('position',[],'velocity',[],'value',[],'best_position',[],'best_value',[]); %initialize
        for q = 1:np
            swarm(q).position = cell(L-1,1); %use different cell for each layer
            swarm(q).velocity = cell(L-1,1); %use different cell for each layer 
            for n = 1:L-1
                %weights are randomly initialized to be between (-wrange,wrange)
                %velocities are initialized as being double this
                %column length is incremented by one for bias term 
                swarm(q).position{n} = wrange*rand(arch(n)+1,arch(n+1))-wrange/2; 
                swarm(q).velocity{n} = 2*wrange*rand(arch(n)+1,arch(n+1))-wrange; 
            end
        end
    end
    
    %Swarm velocity parameters
    if any(cmd == 9)
        loc = find(cmd == 8)+1;
        chi = commands{loc}(1);
        alpha  = commands{loc}(2);
        c = commands{loc}(3:4);
    else
        chi = 0.5;
        alpha = 0.5;
        c = [0.5 0.5];
    end

end