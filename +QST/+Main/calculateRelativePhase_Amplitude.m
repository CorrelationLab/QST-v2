%function calculateRelativePhase_Amplitude(MatFilePath, Channel)
% This is NOT a FUNCTION, it is still a SCRIPT

% It calculates the relative phase between two signals that have been measured simultaneously. 
% I also calculates the amplitude of the two signals.
% Mode 1 corresponds to the signal measured in X1 and X2
% Mode 2 corresponds to the signal measured in X3 and X4. 

% How to use
% load the Matdata.mat directly or use the command: load('Path...\mat-data\Matdata.mat')

   % clc
    close all
    
    % Relative phase between Signal and LO
    phi_X12 = atan2(X2, X1);  
    phi_X34 = atan2(X4, X3);  
    
    %Relative phase between signals
    Rphi = phi_X12 - phi_X34;

    %Removing data that has been filtered out (i.e., vacuum)
    idx1 = intersect(Results_N_G2_TimeResolved.Channel1.EdgeIndices_High, Results_N_G2_TimeResolved.Channel2.EdgeIndices_High);
    idx2 = intersect(Results_N_G2_TimeResolved.Channel3.EdgeIndices_High, Results_N_G2_TimeResolved.Channel4.EdgeIndices_High);
    idx3 = intersect(idx1, idx2);
   
    Rphi_filtered = Rphi(idx3);


   %This makes no sense unless the phase is very well defined
   % Mean value of the relative phase in a selected range of -pi to +pi. 
   %x1 = -pi;
   %x2 = pi;
   %values_in_range = Rphi_filtered(Rphi_filtered >= x1 & Rphi_filtered <= x2);
   %mean_in_range = mean(values_in_range);


    % Amplitudes (A)
    A_X12 = sqrt((X1).^2+(X2).^2);
    A_X12_filtered = A_X12(idx3);

    A_X34 = sqrt((X3).^2+(X4).^2);
    A_X34_filtered = A_X34(idx3);

    Total_A_filtered = A_X12_filtered + A_X34_filtered;
    Difference_filtered = A_X34_filtered - A_X12_filtered;

    %Mean values of the amplitudes
    meanA1 = mean(A_X12_filtered);
    meanA2 = mean(A_X34_filtered);
    meanA3 = mean(Total_A_filtered);
    meanA4 = mean(Difference_filtered);

    
   
    % Visualization of results
    figure;
    subplot(2,4,1);
    histogram(phi_X12, 'BinEdges', linspace(-pi, pi, 100), 'Normalization', 'pdf', 'FaceColor', [0.0 0.2 0.4], 'EdgeColor', [0.15 0.15 0.15]);
    xlabel('Relative phase between Sig-LO, CH 1 & 2 (rad)');
    ylabel('Probability density');
    title('Mode 1 (BEC+Vacuum)');
    xlim([-pi, pi]);
    xticks([-pi, -pi/2, 0, pi/2, pi]);
    xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});


    subplot(2,4,2);
    histogram(phi_X34, 'BinEdges', linspace(-pi, pi, 100), 'Normalization', 'pdf', 'FaceColor', [0.0 0.2 0.4], 'EdgeColor', [0.15 0.15 0.15]);
    xlabel('Relative phase between Sig-LO, CH 3 & 4 (rad)');
    ylabel('Probability density');
    title('Mode 2 (BEC+Vacuum)');
    xlim([-pi, pi]);
    xticks([-pi, -pi/2, 0, pi/2, pi]);
    xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});


    subplot(2,4,3);
    histogram(Rphi, 'BinEdges', linspace(-pi, pi, 100), 'Normalization', 'pdf', 'FaceColor', [0.0 0.2 0.4], 'EdgeColor', [0.15 0.15 0.15]);
    xlabel('Relative phase between Sig-CH12 & Sig-CH34 (rad)');
    ylabel('Probability density');
    title('Relative Phase (BEC+Vacuum)');
    xlim([-pi, pi]);
    ylim([0, 0.4]);
    xticks([-pi, -pi/2, 0, pi/2, pi]);
    xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});


    subplot(2,4,4);
    h=histogram(Rphi_filtered, 'BinEdges', linspace(-2*pi, 2*pi, 200), 'Normalization', 'pdf', 'FaceColor', [0.0 0.2 0.4], 'EdgeColor', [0.15 0.15 0.15]);
    xlabel('Relative phase between Sig-CH12 & Sig-CH34 (rad)');
    ylabel('Probability density');
    title('Relative Phase (only BEC)');
    xlim([-pi, pi]);
    ylim([0, 0.4]);
    xticks([-pi, -pi/2, 0, pi/2, pi]);
    xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
    %circular variance
    r_mean = mean(exp(1i*Rphi_filtered));
    Var_Rphi = 1-abs(r_mean);
    %Calculates the most probable value of the histogram
    bin_centers = (h.BinEdges(1:end-1) + h.BinEdges(2:end)) / 2;
    [~, idx_max] = max(h.Values);
    most_probable_value = bin_centers(idx_max)/pi;
    % Add label with most probable value of the histogram
    text_x4 = -0.5; % X coordinate
    text_y4 = 0.93 * max(ylim); % below maximum of top Y axis
    text(text_x4, text_y4, sprintf('Mean = %.2f \\pi\nCircular Variance = %.3f', most_probable_value, Var_Rphi), 'FontSize', 10, 'FontWeight', 'bold', 'Interpreter','tex');
 

    subplot(2,4,5);
    histogram(A_X12_filtered, 'BinEdges', linspace(0, 10, 100), 'Normalization', 'pdf', 'FaceColor', [0.49 0.18 0.55], 'EdgeColor', [0.2 0.2 0.2]);
    xlabel('Amplitude, CH 1 & 2');
    ylabel('Probability density');
    title('Mode 1 (only BEC)');
    xlim([0, 10]);
    %ylim([0, 0.6]);
    % Add label with mean value of the histogram
    text_x5 = 0.7 * max(xlim); % X coordinate
    text_y5 = 0.95 * max(ylim); % below maximum of top Y axis
    text(text_x5, text_y5, sprintf('Mean = %.2f', meanA1), 'FontSize', 10, 'FontWeight', 'bold');



    subplot(2,4,6);
    histogram(A_X34_filtered, 'BinEdges', linspace(0, 10, 100), 'Normalization', 'pdf', 'FaceColor', [0.49 0.18 0.55], 'EdgeColor', [0.2 0.2 0.2]);
    xlabel('Amplitude, CH 3 & 4');
    ylabel('Probability density');
    title('Mode 2 (only BEC)');
    xlim([0, 10]);
    %ylim([0, 0.6]);
    % Add label with mean value of the histogram
    text_x6 = 0.7 * max(xlim); % X coordinate
    text_y6 = 0.95 * max(ylim); % below maximum of top Y axis
    text(text_x6, text_y6, sprintf('Mean = %.2f', meanA2), 'FontSize', 10, 'FontWeight', 'bold');

    subplot(2,4,7);
    histogram(Total_A_filtered, 'BinEdges', linspace(0, 10, 100), 'Normalization', 'pdf', 'FaceColor', [0.49 0.18 0.55], 'EdgeColor', [0.2 0.2 0.2]);
    xlabel('Amplitude');
    ylabel('Probability density');
    title('Total Amplitude Mode1+Mode2 (only BEC)');
    xlim([0, 10]);
    % Add label with mean value of the histogram
    text_x7 = 0.7 * max(xlim); % X coordinate
    text_y7 = 0.85 * max(ylim); % below maximum of top Y axis
    text(text_x7, text_y7, sprintf('Mean = %.2f', meanA3), 'FontSize', 10, 'FontWeight', 'bold');
    
    
    subplot(2,4,8);
    histogram(Difference_filtered, 'BinEdges', linspace(-10, 10, 200), 'Normalization', 'pdf', 'FaceColor', [0.49 0.18 0.55], 'EdgeColor', [0.2 0.2 0.2]);
    xlabel('Amplitude');
    ylabel('Probability density');
    title('Difference Mode2-Mode1 (only BEC)');
    xlim([-5, 5]);
    %variance
    Var_A = var(Difference_filtered);
    Std_A = sqrt(Var_A);
    % Add label with mean value of the histogram
    text_x8 = 0.25 * max(xlim); % X coordinate
    text_y8 = 0.93 * max(ylim); % below maximum of top Y axis
    text(text_x8, text_y8, sprintf('Mean = %.2f\nVariance = %.3f', meanA4, Var_A), 'FontSize', 10, 'FontWeight', 'bold');



%fix aspect ratio of all figures    
myAspectRatio = [1 1 1];
for i = 1:8
    subplot(2,4,i);
    pbaspect(myAspectRatio);
end



