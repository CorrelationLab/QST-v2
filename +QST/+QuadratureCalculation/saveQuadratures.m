function [] = saveQuadratures(Directory, Filename, X1, X2, X3, X4, PiezoInfos)
%% Description:
%   This function saves four calculated quadrature arrays and their associated piezo information in a MATLAB .mat file.
%
%   The output file is created in the specified folder and is named using FileName with the extension '.mat'.
%
%% Syntax:
%   saveQuadratures(Directory, FileName, X1, X2, X3, X4, PiezoInfos)
%
%% Input:
% required input values:
%   Directory                                       - path to the directory in which the .mat file is saved
%   FileName                                        - name of the output file without the '.mat' extension
%   X1                                              - calculated quadrature data of channel 1
%   X2                                              - calculated quadrature data of channel 2
%   X3                                              - calculated quadrature data of channel 3
%   X4                                              - calculated quadrature data of channel 4
%   PiezoInfos                                      - structure or array containing information associated with the
%                                                     piezo movement and quadrature data
%
%% Output:
%   This function does not return output arguments. It saves X1, X2, X3, X4, and PiezoInfos in a .mat file.



    arguments(Input)
        Directory;
        Filename;
        X1;
        X2;
        X3;
        X4;
        PiezoInfos;
    end


    save(strcat(char(Directory),'\',Filename,'.mat'),'X1','X2','X3','X4','PiezoInfos');
end

