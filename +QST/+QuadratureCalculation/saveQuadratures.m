function [] = saveQuadratures(FolderPath,FileName,X1,X2,X3, X4, PiezoInfos)
%SAVEQUADRATURES saves the calculated quadratures in the given directory
    save(strcat(char(FolderPath),'\',FileName,'.mat'),'X1','X2','X3','X4','PiezoInfos');
end

