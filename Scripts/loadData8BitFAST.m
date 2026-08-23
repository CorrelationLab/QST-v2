function [Data8Bit_LO,Data8Bit_SIG,Range_LO,Range_SIG] =  loadData8BitFAST()
Dir = "D:\Data\Tests\rawdata";

FilePath_LO_Raw = strcat(Dir,filesep,"LOOnly.raw");
FilePath_SIG_Raw = strcat(Dir,filesep,"LOwithSIG.raw");
FilePath_LO_Cfg = strcat(Dir,filesep,"LOOnly.cfg");
FilePath_SIG_Cfg = strcat(Dir,filesep,"LOwithSIG.cfg");
FilePath_SIG_Stamp = strcat(Dir,filesep,"LOwithSIG.stamp");

% load Configdata
Config_LO = QST.QuadratureCalculation.getConfig(FilePath_LO_Cfg);
Config_SIG = QST.QuadratureCalculation.getConfig(FilePath_SIG_Cfg);
% get the params
Segmentsize = Config_LO.SpectrumCard.ModeSetup.Segmentsize_I32;
Memsize_LO = round(Config_LO.SpectrumCard.ModeSetup.Memory_DBL);
Memsize_SIG = round(Config_SIG.SpectrumCard.ModeSetup.Memory_DBL);
NumberOfRecordings_LO = Memsize_LO/Segmentsize;
NumberOfRecordings_SIG = Memsize_SIG/Segmentsize;
Range_LO = Config_LO.SpectrumCard.Channel00.Range_I32;
Range_SIG = Config_SIG.SpectrumCard.Channel00.Range_I32;


% load raw data
Data8Bit_LO = fread(fopen(FilePath_LO_Raw),[Segmentsize*2, NumberOfRecordings_LO], 'int8=>int8');
Data8Bit_LO = permute(reshape(Data8Bit_LO,2,Segmentsize,NumberOfRecordings_LO),[2,3,1]);
Data8Bit_SIG = fread(fopen(FilePath_SIG_Raw),[Segmentsize*2, NumberOfRecordings_SIG], 'int8=>int8');
Data8Bit_SIG = permute(reshape(Data8Bit_SIG,2,Segmentsize,NumberOfRecordings_SIG),[2,3,1]);
end