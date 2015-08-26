

pool = parpool(12);
%Preprocessing for wavelet transform
signal = p_s;
% signal = p_s(1:128,9:520,:);
qmf = MakeONFilter('Battle',5);
[M,N,L] = size(signal);

% %Filter in radial direction
% signal = permute(signal,[2 3 1]);
% signal = reshape(signal,N*L,M);
% parfor k = 1:(N*L)
%     tmp = signal(k,:);
%     filt = CohWave(tmp,4,qmf);
%     signal(k,:) = filt;
% end
% signal = reshape(signal,[N,L,M]);
% signal = ipermute(signal,[2 3 1]);
% 
% %Filter in axial direction
% signal = permute(signal,[1 3 2]);
% signal = reshape(signal,M*L,N);
% parfor k = 1:(M*L)
%     tmp = signal(k,:);
%     filt = CohWave(tmp,4,qmf);
%     signal(k,:) = filt;
% end
% signal = reshape(signal,[M,L,N]);
% signal = ipermute(signal,[1 3 2]);

%Smooth in spatial dimensions
parfor k = 1:L
    signal(:,:,k) = nanmoving_average2(signal(:,:,k),1,2);
end

%Filter in temporal direction
signal = reshape(signal,[],L);
parfor k = 1:(M*N)
    tmp = signal(k,:);
    filt = CohWave(tmp,4,qmf);
    signal(k,:) = filt;
end
signal = reshape(signal,[M,N,L]);



delete(pool);