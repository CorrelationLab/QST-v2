# QST-v2
A package written in matlab to analyse data aquired by multichannel homodyne detection. The codes are partially rewritings of the package by CarolinLueders and nMerlin ('https://github.com/CarolinLueders/QST')
Every function has an extensive documentation (partially written with the use of AI (ChatGPT 5.6)). The package as it is corresponds to the state of the running package as it was at 06.09.2026. However, minor bugs have been general structure has been straighten, and minor bugs have been eliminated.



# General Structure
The package uses the general MATLAB package syntax to prevent function doubling. The usually used main function are found in QST.Main . Functions that apply on a series of measurements are indicated by the syllable 'Series'. In the most cases these functions apply as a wrapper for a function of similar name that execute the wanted operation on a single dataset. To this end these wrapper functions usually handling the file managment. 


# Basic Usage:

# 1. Quadrature Calculation
The first step of every analysis is the quadrature calculation. This is done via 'QST.Main.execSeriesQuadratureCalculation'




## Analysis of phase averaged measurements (1 or 2 detection channels)

# 1. (Time resolved) N and g2
The first step in every analysis of a phase averaged dataset (the phase relation between local oscillator and signal randomizes on timescales shorter than the time between two consective LO pulses) is usually to check the average photon number N and the second order correlation g2(0).
This is done on a measurement series via 'QST.Main.execSeriesAnalysis_N_G2'

# 2. Time averaged Husimi Q distribution and the DTS model
The next step is usually to analyze the series in terms of the DTS model using the light fields representation in phase space via its Husimi-Q distribution. The 
This can be done via 'QST.Main.execSeriesAnalysis_HusimiQ_DTS'. An alternative approach using a different fitting approach can be accessed via 'QST.Main.execAnalysis_HusimiQ_DTS_By1DModel'.
The latter however is only implemented for single measurements.

# 3. Time resolved Husimi-Q anaylsis
Finally the Husimi Q analysis can, similarly to the N and g2 analysis, be executed on smaller datasets, creating an effective temporal resolution. This can be applied to single measurements using either
'QST.Main.createTimeResolvedHusimiMovie_By1DModel' or 'QST.Main.createTimeResolvedHusimiMovie_By2DModel', dependent on if the traditional 2D model or the alternative 1D Model approach should be used.




## Analysis of phase sensitive measurements (1 detetcion channel)

# 1. Density matrix
In case of phase sensitive measurements (the phase relation between local oscillator and signal is usually fixed and modulated to a sinusoidal relation. To this end the signal has to emerge from the local oscillator beam and external phase deviation have to be negligible). In this case N and g2 cannot be reconstructed the usual way. Instead, one has to compute the light fields density matrix that gives full information over the quantum state. This can be done for a series of measurements using 'QST.Main.computeSeriesDensityMatrix'.

# 2. Wigner Function
Further one can reconstruct the Wigner function from the density matrix. This can be done for a measurement series via 'QST.Main.computeSeries_Wigner'. Requirement is that one beforehand constructed  a set of generating functions. This can be done via 'QST.Wigner.computeWignerTable'.







## Analysis of non stationary optical tomography (3 channels)

# Analysis of the regularized P function according to the work of Carolin Lüders
originally made for a learning purpose the package also includes a rewriting of the the analysis introduced by Carolin Lüders to construct the regularized P function P_Omega from 3 channel measurements. More detail are found in the instruction by Carolin Lüders https://zenodo.org/records/7467083 . The computation consists of several steps: 
- First the generating function has be computed using 'QST.P_Omega.computeQuadratureGridAndPattern'.
- Second the quadratures have to be postselected by orthogonality and the phase has to be computed using 'QST.P_Omega.computeThreeChannelDataSet'
- Third a region of the original dataset has to be selected via 'QST.P_Omega.selectThreeChannelDataSet_ByRegion_MAIN'
- Fourth P_Omega is computed via 'QST.P_Omega.computePOmega_MultipleRegions' which also allows to construct P_Omega for different regions
- Finally P_Omega can be plotted using 'QST.P_Omega.plotPOmega'.





## File and Variable Handling
- Subdirectories and files can be found with the functions in QST.File_managment
- Variables can be extrcated from matfiles via 'QST.Variable_Managment.getVariableFromFilePath' (QST.Variable_Managment.getVariablesFromSeries if one has a full series)
Metadata can be extracted from strings (as filepaths) using 'QST.Variable_Managment.getMetaDataFromString'




## Quadrature Selection
- Quadrature subsets fulfilling specific conditions can be extracted from the full quadrature sets using the functions in QST.QuadratureSelection
- As one important aspect in this context to know the quadratures that are used to compute a specific photon number or g2 I that computed as means over a window of quadratures
  I introduced the concept of EdgeIndices. With this a window of quadratures associated with a specific N or g2 value is specified by the first and last quadrature index only.
  This way memory is saved. Edgeindices can be transfered back into regular quadrature indices using 'QST.Helper.calcQuadraturesFromEdgeIndices'



## Simulation
Some basic quantum optic simulation functions for classic states are found in 'QST.Simulation'. 