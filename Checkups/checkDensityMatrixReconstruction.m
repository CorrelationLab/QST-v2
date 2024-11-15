% 1. reshape X1
X1 = reshape(X1,PiezoInfos.X1.Shape);
Theta = QST.Helper.computePhase(X1,1,PiezoInfos.X1.StartDirection);
MaxFock = 200;
Iterations = 300;
Rhos = zeros(MaxFock+1,MaxFock+1,size(Theta,2));
for i = 1:size(Theta,2)
    disp(i)
    D = X1(:,:,i);
    D = D(:);
    T = Theta(:,i);
    Rhos(:,:,i) = QST.DensityMatrix.computeDensityMatrix_FAST(D,T,MaxFockState=MaxFock,Iterations=Iterations);
end