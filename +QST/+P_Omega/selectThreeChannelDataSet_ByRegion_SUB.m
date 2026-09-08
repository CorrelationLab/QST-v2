function [X_Target_Selected,Theta_Selected,Indices_Selected] = selectThreeChannelDataSet_ByRegion_SUB(X_PsFast_Orth,X_PsSlow_Orth,X_Target_Orth,Theta_Orth,Region)
% SELECTREGION PostSelects DataSubsets from the Targetchannel, based on the Position of the belonging PostSelection Quadratures in Phasespace by
% giving a struct describing a specific region in phasespace
%
% X_PsFast_Orth :       Orthogonal Subset from PsFast Channel
% X_PsSlow_Orth :       Orthogonal Subset from PsSlow Channel
% X_Target_Orth :       Orthogonal Subset from Target Channel
% Theta_Orth :          Orthogonal Subset from Theta (Phase between PsFast and Target)
% Region :              Struct which defines the a specific Region in phasespace according to which the fitting Quadratures are then taken from
%                       X_Target_Orth and Theta.
%                       The following Regions Regions are possible and are distinguished by their Type:
%
%                       Type:               Parameter         Meaning                           Special
%                       "Rectangle"         "X"               X Position of lower left Corner
%                                           "Y"               Y Position of lower left Corner
%                                           "Width"           Width
%                                           "Height"          Height
%
%                       "HalfCircle"        "Radius_In"       Inner Radius                      The Circle stays in the first and second quadrant
%                                           "Width"           Width                             The radius goes then from Radius_in to Radius_In+Width
%
%                       "FullCircle"        "Radius"          central Radius
%                                           "Width"           Width
%
%                       "Dot"               "X"               X Position of the Dot
%                                           "Y"               Y Position of the Dot
%                                           "Width"           Width
%
%                       "Phase"             "Phase_Cent"      Central Value of the Phase
%                                           "Phase_Width"     Width of the Phase
%
%                       "PhaseAndAmplitude" "Phase_Cent"      Central Value of the Phase
%                                           "Phase_Width"     Width of the Phase
%                                           "Radius"          Central radius
%                                           "Width"           Width
%
%                       "QLine"             "Q_Cent"          Central Q Position                straight Line in pure P direction
%                                           "Width"           Width
%
%                       "PLine"             "P_Cent"          Central P Position                straight Line in pure Q direction
%                                           "Width"           Width
%
%
%
% OUTPUTS:
% X_Target_Selected:    Selected Subset from X_Target_Orth
% Theta_Selected:       Selected Subset from Theta_Orth
% Indices_Selected:     Indices of the found Subset



    arguments(Input)
        X_PsFast_Orth
        X_PsSlow_Orth
        X_Target_Orth
        Theta_Orth
        Region
    end


    %% calculate the Indices which fullfill the conditions of the wanted Region
    switch Region.Type
        case "Rectangle"
            X = Region.X;
            Y = Region.Y;
            W = Region.Width;
            H = Region.Height;
            Indices_Selected = find(X_PsFast_Orth>X & X_PsFast_Orth<(X+W) & X_PsSlow_Orth>Y & X_PsSlow_Orth<(Y+H));
        case "HalfCircle"
            R = Region.Radius_In;
            W = Region.Width;
            HusimiRadius = sqrt(X_PsFast_Orth.^2+X_PsSlow_Orth.^2);
            Indices_Selected = find(HusimiRadius>R & HusimiRadius<(R+W) & X_PsSlow_Orth>0);
        case "FullCircle"
            R = Region.Radius;
            W = Region.Width;
            HusimiRadius = sqrt(X_PsFast_Orth.^2+X_PsSlow_Orth.^2);
            Indices_Selected = find(HusimiRadius>(R-W/2) & HusimiRadius<(R+W/2));
        case "Dot"
            X = Region.X;
            Y = Region.Y;
            R = Region.Width;
            Indices_Selected = find(((X_PsFast_Orth-X).^2+(X_PsSlow_Orth-Y).^2) <= R^2);
        case "Phase"
            Theta_Central = Region.Phase_Cent;
            Theta_Width = Region.Phase_Width;
            HusimiPhase = atan2(X_PsSlow_Orth,X_PsFast_Orth);
            HusimiRadius = sqrt(X_PsFast_Orth.^2+X_PsSlow_Orth.^2);
            Indices_Selected = find(HusimiPhase>(Theta_Central-Theta_Width/2) & HusimiPhase<(Theta_Central+Theta_Width/2) & HusimiRadius>sqrt(0.5));
        case "PhaseAndAmplitude"
            Theta_Central = Region.Phase_Cent;
            Theta_Width = Region.Phase_Width;
            R = Region.Radius;
            W = Region.Width;
            HusimiPhase = atan2(X_PsSlow_Orth,X_PsFast_Orth);
            HusimiRadius = sqrt(X_PsFast_Orth.^2+X_PsSlow_Orth.^2);
            Indices_Selected = find(HusimiPhase>(Theta_Central-Theta_Width/2) & HusimiPhase<(Theta_Central+Theta_Width/2) & HusimiRadius>(R-W/2) & HusimiRadius<(R+W/2) & HusimiRadius>sqrt(0.5));
        case "QLine"
            Q = Region.Q_Cent;
            W = Region.Width;
            Indices_Selected = find(X_PsFast_Orth>(Q-W/2) & X_PsFast_Orth<(Q+W/2));
        case "PLine"
            P = Region.P_Cent;
            W = Region.Width;
            Indices_Selected = find(X_PsSlow_Orth>(P-W/2) & X_PsSlow_Orth<(P+W/2));
        otherwise
            error("Invalid Type of Region")
    end
    %% Select Region from TargetChannel
    X_Target_Selected = X_Target_Orth(Indices_Selected);
    %% ReCalculate Phase dependent on the Phase between the Data in the Postselectionchannel
    Theta_Selected = mod(Theta_Orth + atan2(X_PsSlow_Orth,X_PsFast_Orth),2*pi);
    Theta_Selected = Theta_Selected(Indices_Selected);
end

