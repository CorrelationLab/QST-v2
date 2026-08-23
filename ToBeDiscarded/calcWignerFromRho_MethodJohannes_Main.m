function WF = calcWignerFromRho_MethodJohannes_Main(rho,varargin)
% calculates the Wigner function from the input density matrix rho.
% Optional Input: Directory: The directory, where the WignerTables WigTab
% are located that should be used.  

%% Validate and parse input arguments
p = inputParser;
defaultDirectory = 'E:\WignerTables\nMax200_Qm20To20Res0i125';
addParameter(p,'Directory',defaultDirectory,@ischar);
parse(p,varargin{:});
c = struct2cell(p.Results);
[directory] = c{:};

maxn=size(rho,1);
load(strcat(directory,'\n0m0'),'WigTab');
WF=zeros(size(WigTab,1),size(WigTab,2));
tic
for nVal=0:maxn-1
    for mVal=0:maxn-1
        loadstring=strcat(directory,'\n',int2str(nVal),'m',int2str(mVal));
        load (loadstring,'WigTab');
        WF=WF+(rho(nVal+1,mVal+1)*WigTab);
    end
end
toc
%WF = real(WF);
WF = WF/sum(sum(WF));

end
