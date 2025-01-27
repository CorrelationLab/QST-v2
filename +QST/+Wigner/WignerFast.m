Dir = 'D:\Programming\Wignertables\Start_m10__Step0i0625__End_10__maxFock_50';

profile on
maxQ = 10; % quadratic (q,p) space
maxZeta = 2*maxQ;
stepsizeQ = 0.125/2;
stepsizeZeta = 0.125/2;
maxFock = 50;

% set values of Q and Zeta
Q = gpuArray([-maxQ:stepsizeQ:maxQ]);
Zeta = gpuArray([-maxZeta:stepsizeZeta:maxZeta]);
nQ = length(Q);
nZeta = length(Zeta);

% set Q+Zeta/2
QplusZetaH = Q+(Zeta/2).'; % axis1: different Zeta, axis2: different Q


% calc the projection <n,Q+Zeta/2> ; axis1: Zeta, axis2:Q, axis3:n
n_QplusZetaH = gpuArray(zeros(nZeta,nQ,maxFock+1));
n_QplusZetaH(:,:,1) = pi^(-0.25)*exp(-0.5*QplusZetaH.^2);
n_QplusZetaH(:,:,2) = n_QplusZetaH(:,:,1).*QplusZetaH*sqrt(2);
for i = [3:maxFock+1]
    n_QplusZetaH(:,:,i) = sqrt(2/(i-1))*QplusZetaH.*n_QplusZetaH(:,:,i-1)-sqrt((i-2)/(i-1))*n_QplusZetaH(:,:,i-2);
end
% calc the projection <q-zeta,m>
n_QminusZetaH = flip(n_QplusZetaH,1);



% create the exp term ; axis1:Zeta, axis2:P
P = Q;
nP = nQ;
%P = gpuArray([-maxQ*1.5:stepsizeQ:maxQ*1.5]);
%nP = length(P);
EXP = exp(-1j*Zeta.'*P);

% looping over diagonales (allows to exploit to W_n_m = W_m_n*)
% goes over the upper triangle matrix and saves it side digaonal wise
for i = 0:maxFock
    W_Pattern = gpuArray(complex(zeros(nP,nQ,maxFock+1-i)));
    for j = i+1:maxFock+1
        W_Pattern(:,:,j-i) = ((n_QplusZetaH(:,:,j-i).*n_QminusZetaH(:,:,j)).'*EXP).';
        %W_Pattern(:,:,j-i) = flip(((n_QplusZetaH(:,:,j-i).*n_QminusZetaH(:,:,j)).')*EXP).',2);
    end
    W_Pattern = (1/(2*pi))*stepsizeZeta*W_Pattern;
    W_Pattern = complex(gather(real(W_Pattern)),gather(imag(W_Pattern)));
    save(strcat(Dir,filesep,'WignerPattern_offD',num2str(i)),'W_Pattern','-v6');
end


profile viewer