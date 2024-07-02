function [QC_Transmitted,QC_Reflected] = coherenceAfterBeamsplitter(nCoherent, nTherm, Transmission)
Reflection = 1-Transmission;
QC_Transmitted = QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent*Transmission,nTherm*Transmission);
QC_Reflected = QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent*Reflection,nTherm*Reflection);
end