# QST-v2
A package written in matlab to analyse data aquired by multichannel homodyne detection. The codes are partially rewritings of the package by CarolinLueders and nMerlin ('https://github.com/CarolinLueders/QST')
Every function has an extensive documentation (partially written with the use of AI (ChatGPT 5.6)). The package as it is set up for documentation is based on the regulars package state of the 06.09.2026. However, the general structure has been streamlined and found minor bugs have been fixed. The package was tested on MATLAB 2025b.



# General Structure
The package uses the general MATLAB package syntax to prevent function doubling. The usually used main function are found in 'QST.Main'. Functions that apply on a series of measurements are indicated by the syllable 'Series'. In the most cases these functions apply as a wrapper for a function of similar name that execute the wanted operation on a single dataset. To this end these wrapper functions usually handling the file management. 


# Basic Usage:

# 1. Quadrature Calculation
The first step of every analysis is the quadrature calculation. This is done via 'QST.Main.execSeriesQuadratureCalculation'
Example:
QST.Main.execSeriesQuadratureCalculation('PathToSeriesMainDir',[1,2],Preset='RandomPhase',StarHub=false);


## Analysis of phase averaged measurements (1 or 2 detection channels)

# 1. (Time resolved) N and g2
The first step in every analysis of a phase averaged dataset (the phase relation between local oscillator and signal randomizes on timescales shorter than the time between two consecutive LO pulses) is usually to check the average photon number N and the second order correlation g2(0).
This is done on a measurement series via 'QST.Main.execSeriesAnalysis_N_G2'
Example:
QST.Main.execSeriesAnalysis_N_G2('PathToSeriesMainDir',[1,2]);



# 2. Time averaged Husimi Q distribution and the DTS model
The next step is usually to analyse the series in terms of the DTS model using the light fields representation in phase space via its Husimi-Q distribution.
This can be done via 'QST.Main.execSeriesAnalysis_HusimiQ_DTS'. An alternative approach using a different fitting approach can be accessed via 'QST.Main.execAnalysis_HusimiQ_DTS_By1DModel'.
The latter however is only implemented for single measurements.
Example:
QST.Main.execSeriesAnalysis_HusimiQ_DTS_By2DModel('PathToSeriesMainDir',[1,2],AnalysisMode='All',Resolution=0.15);
QST.Main.execAnalysis_HusimiQ_DTS_By1DModel(MatFilePath="PathToMatFile",X1String="X1",X2String="X2",Resolution=0.01);



# 3. Time resolved Husimi-Q anaylsis
Finally the Husimi Q analysis can, similarly to the N and g2 analysis, be executed on smaller datasets, creating an effective temporal resolution. This can be applied to single measurements using either
'QST.Main.createTimeResolvedHusimiMovie_By1DModel' or 'QST.Main.createTimeResolvedHusimiMovie_By2DModel', dependent on if the traditional 2D model or the alternative 1D Model approach should be used.
Examples:
QST.Main.createTimeResolvedHusimiMovie_By1DModel(MatFilePath="PathToMatFile",StartTime=0,EndTime=0.005,X1String='X1',X2String='X2',nQuadratures=30000,nStepSize=10000,Resolution=0.1);
QST.Main.createTimeResolvedHusimiMovie_By2DModel(MatFilePath="PathToMatFile",StartTime=0,EndTime=0.005,X1String='X1',X2String='X2',nQuadratures=30000,nStepSize=10000,Resolution=0.2);





## Analysis of phase sensitive measurements (1 detetcion channel)

# 1. Density matrix
In case of phase sensitive measurements (the phase relation between local oscillator and signal is usually fixed and modulated to a sinusoidal relation. To this end the signal has to emerge from the local oscillator beam and external phase deviation have to be negligible). In this case N and g2 cannot be reconstructed the usual way. Instead, one has to compute the light fields density matrix that gives full information over the quantum state. This can be done for a series of measurements using 'QST.Main.computeSeriesDensityMatrix'.
Example:
QST.Main.computeSeriesDensityMatrix("PathToMatFile","X1","PiezoInfos");

# 2. Wigner Function
Further one can reconstruct the Wigner function from the density matrix. This can be done for a measurement series via 'QST.Main.computeSeries_Wigner'. Requirement is that one beforehand constructed a set of generating functions. This can be done via 'QST.Wigner.computeWignerTable'.
Example:
QST.Wigner.computeWignerTable("SaveDirectoryForWignerTable",10,0.2,50)
Wigner = QST.Wigner.computeWignerFromDensityMatrix(DensityMatrix(1).Rho,"DirectoryWignerTable");






## Analysis of non stationary optical tomography (3 channels)

# Analysis of the regularized P function according to the work of Carolin Lüders
originally made for a learning purpose the package also includes a rewriting of the analysis introduced by Carolin Lüders to construct the regularized P function P_Omega from 3 channel measurements. More detail are found in the instruction by Carolin Lüders https://zenodo.org/records/7467083. The computation consists of several steps: 
- First one computes the generating function using 'QST.P_Omega.computeQuadratureGridAndPattern'.
- Second one postselects the quadrature pairs that are orthogonal to each other in the postselection channel. Further one computes the phase between the postselection and the target channel. This is done via 'QST.P_Omega.computeThreeChannelDataSet'
- Third one selects a region in the phase space of the postselection channel via 'QST.P_Omega.selectThreeChannelDataSet_ByRegion_MAIN'
- Fourth one computes the regularized P-function P_Omega via 'QST.P_Omega.computePOmega_MultipleRegions' which also allows to construct P_Omega for different regions
- Finally one can plot P_Omega using 'QST.P_Omega.plotPOmega'.





## File and Variable Handling
- Subdirectories and files can be found with the functions in QST.File_managment
- Variables can be extracted from mat files via 'QST.Variable_Managment.getVariableFromFilePath' (QST.Variable_Managment.getVariablesFromSeries if one has a full series)
Metadata can be extracted from strings (as for e.g. filepaths) using 'QST.Variable_Managment.getMetaDataFromString'




## Quadrature Selection
- Quadrature subsets fulfilling specific conditions can be extracted from the full quadrature sets using the functions in 'QST.QuadratureSelection'
- One important aspect in this context is to know the subset of quadratures that are connected with a subset of photon numbers or g2 values (for example the data subset where the photon number is above 1). To convert between the indexset of N and g2 and that of the quadratures while keeping memory consumption low I introduced the concept of EdgeIndices. An Edgeindices connects the range of quadratureindices that are connected with an N or g2 by svaing only the first and last connected quadrature index.
One can transfer between EdgeIndices and regular quadrature indices using 'QST.Helper.calcQuadraturesFromEdgeIndices'



## Simulation
Some basic quantum optic simulation functions for classic light field states are found in 'QST.Simulation'. 