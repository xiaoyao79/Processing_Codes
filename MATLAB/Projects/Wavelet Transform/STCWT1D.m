function [wave,scales,omegaks] = STCWT1D(sig,dt,dj,whan,ca,mother,param,varargin)
%Computes (1+1)-Dimensional Spatio-Temporal Continuous Wavelet Transform 
%using Fourier method. Based off of Kikuchi 2010.
%Inputs:
%           sig:        signal (M,N), where DIM1 is time
%           dt:         period between samples (2,1)
%           dj:         scales spacings (2,1)
%           J:          number of scaless to use (2,1)
%           mother:     mother wavelet (Default is Morlet)
%           param:      parameter for mother wavelet (2,1)
%           optional:   add '-real' to force the output coefficients to be
%                       the real part only of the transform coefficients
%                       (useful if only reconstructing signal & have very
%                       large matrices). Add '-mod' to get modulus output
%                       instead of complex.
%Outputs:
%           wave:       wavelet coefficients (J(1),J(2),M,N)
%           s:          scales index used
%           omegaks:    normalized FFT axis
%Last Updated: 2014-05-02 by Michael Crawley

    %Grab Mother Wavelet info
    if ~exist('dj','var')||isempty(dj), dj = [0.125 0.125]; end
    if ~exist('mother','var')||isempty(mother), mother = 'morlet'; end
    if ~exist('param','var')||isempty(param), param = [6 6]; end
    if ~exist('whan','var')||isempty(whan), whan = @rectwin; end
    if ~exist('ca','var')||isempty(ca), flag = false; else flag = true; end
    if any(strcmpi('-real',varargin)), real_flag = true; else real_flag = false; end
    [~,fcoef] = MotherWavelets('ST2',mother,param);
    
    %Grab Processing Parameters, Create and apply window
    [M,N] = size(sig);
    wndo_t = repmat(whan(M),[1 N]); %window along t-dimension (DIM1)
    sig = sig.*wndo_t;%.*wndo_x;
    
    %Zero-pad if necessary    
    L1 = 2^(nextpow2(M));
    L2 = 2^(nextpow2(N)+2); %increase resolution in x-direction only
    swap = zeros(L1,L2);
    swap(1:M,1:N) = sig;
    sig = swap; clear swap;
    
    %Compute scales
    c0 = 2*dt(2)*fcoef(2)/(L1*dt(1)*fcoef(1)); %initial velocity scales
    cN = ceil((log2(L1*L2)-2)/dj(1)); %number of velocity scales
    scales{1} = c0*2.^(dj(1)*(0:cN)); %velocity scales
    s0 = (1/2/pi)*sqrt(prod(fcoef))*sqrt(prod(dt)); %initial spatial scales
    sN = ceil((log2(sqrt(L1*L2))-1)/dj(2)); %number of spatial scales
    scales{2} = s0*2.^(dj(2)*(0:sN)); %spatial scales
    
    %Recompute velocity scales to hit acoustic velocity exactly
    if flag
        X = round(cN*log2(ca/scales{1}(1))/log2(scales{1}(end)/scales{1}(1)));
        dj2 = log2(ca/scales{1}(1))/X;
        scales{1} = c0*2.^(dj2*(0:cN));
    end
    
    %compute normalized FFT axes
    xh = fftn(sig);
    omega_t = 2*pi*(1:floor(L1/2))/L1/dt(1);
    omega_x = 2*pi*(1:floor(L2/2))/L2/dt(2);
    omegaks{1} = [0,omega_t,-fliplr(omega_t(1:floor((L1-1)/2)))];
    omegaks{2} = [0,omega_x,-fliplr(omega_x(1:floor((L2-1)/2)))];
    [K,T] = meshgrid(omegaks{2},omegaks{1}); %order is flipped because meshgrid assumes input is DIM2,DIM1
    
    %Initialize output, loop through scales indices
%     if real_flag 
%         wave = zeros(cN+1,sN+1,L1,L2);
%         parfor j = 1:cN+1
%             for k = 1:sN+1
%                 wavelet = MotherWavelets('ST2',mother,param);
%                 daughter = scales{2}(k)*wavelet(scales{2}(k)*T/sqrt(scales{1}(j)),scales{2}(k)*K*sqrt(scales{1}(j)));
%                 wave(j,k,:,:) = real(ifftn(xh.*conj(daughter))); 
%             end
%         end
%     else
%         wave = complex(zeros(cN+1,sN+1,L1,L2));
%         parfor j = 1:cN+1
%             for k = 1:sN+1
%                 wavelet = MotherWavelets('ST2',mother,param);
%                 daughter = scales{2}(k)*wavelet(scales{2}(k)*T/sqrt(scales{1}(j)),scales{2}(k)*K*sqrt(scales{1}(j)));
%                 wave(j,k,:,:) = ifftn(xh.*conj(daughter));  
%             end
%         end
%     end

        cN1 = cN+1;
        sN1 = sN+1;
        cN1sN1 = cN1*sN1;
        if real_flag
            wave = zeros(cN1sN1,L1,L2);
            parfor qq = 1:cN1sN1
                [j,k] = ind2sub( [cN1 sN1], qq );
                wavelet = MotherWavelets('ST2',mother,param);
                daughter = scales{2}(k)*wavelet(scales{2}(k)*T/sqrt(scales{1}(j)),scales{2}(k)*K*sqrt(scales{1}(j)));
                wave(qq,:,:) = real(ifftn(xh.*conj(daughter)));
            end
        else
            wave = complex(zeros(cN1sN1,L1,L2));
            parfor qq = 1:cN1sN1
                [j,k] = ind2sub( [cN1 sN1], qq );
                wavelet = MotherWavelets('ST2',mother,param);
                daughter = scales{2}(k)*wavelet(scales{2}(k)*T/sqrt(scales{1}(j)),scales{2}(k)*K*sqrt(scales{1}(j)));
                wave(qq,:,:) = ifftn(xh.*conj(daughter));
            end
        end

        %Reshape and get rid of padded cells
        wave = wave(:,1:M,1:N);
        wave = reshape(wave,cN1,sN1,M,N);

        %Convert to power, if desired
        if any(strcmpi('-mod',varargin))
            wave = abs(wave).^2;
        end
    end