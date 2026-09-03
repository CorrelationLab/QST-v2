function graphicsSettings(Options)
%% Description:
%   This function applies common graphical display settings to the current axes and its line objects.
%
%% Syntax:
%   graphicsSettings()
%   graphicsSettings(Fontsize=19)
%
%% Input:
% name-value input options:
%   Fontsize                                        - font size applied to the current axes (default: 19)
%
%% Output:
%   This function does not return output arguments. It modifies the current axes and activates customized data tips.

arguments
    Options.Fontsize (1,1) double {mustBePositive} = 19
end

FontName = 'Arial';
Axes = gca;
Lines = findobj(Axes, 'Type', 'line');

for iLine = 1:numel(Lines)
    Lines(iLine).LineWidth = 2;
end

Axes.LineWidth = 2;
Axes.XColor = [0 0 0];
Axes.YColor = [0 0 0];
Axes.Box = 'on';
Axes.FontSize = Options.Fontsize;
Axes.FontName = FontName;
Axes.TickDir = 'in';

grid on;

DataCursorMode = datacursormode;
DataCursorMode.UpdateFcn = @QST.Helper.dataTipUpdateFcn;
end