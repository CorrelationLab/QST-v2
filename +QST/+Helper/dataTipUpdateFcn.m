function output_txt = dataTipUpdateFcn(Event_Object)
%% Description:
%   This function defines the text displayed by a MATLAB data cursor. It returns the coordinates of the selected
%   data point with increased numerical precision.
%
%   The X- and Y-coordinates are always displayed with 10 significant digits. If the selected point has a
%   third coordinate, the Z-coordinate is additionally displayed with 4 significant digits.
%
%% Syntax:
%   output_txt = dataTipUpdateFcn(Event_Object)
%
%% Input:
% required input values:
%   Event_Object                                       - MATLAB data-cursor event object containing the position of the
%                                                     selected data point
%
%% Output:
%   output_txt                                      - cell array of character vectors defining the data-cursor text;
%                                                     contains X and Y coordinates and optionally a Z coordinate
%
%% Notes:
%   This function is intended to be used as the UpdateFcn callback of a MATLAB data cursor mode object:
%
%   DataCursorMode = datacursormode;
%   DataCursorMode.UpdateFcn = @QST.Helper.dataTipUpdateFcn;



    arguments
        Event_Object;
    end


    Position = get(Event_Object,'Position');
    output_txt = {['X: ',num2str(Position(1),10)],...
                  ['Y: ',num2str(Position(2),10)]};
    
    % If there is a Z-coordinate in the position, display it as well
    if length(Position) > 2
        output_txt{end+1} = ['Z: ',num2str(Position(3),4)];
    end
end
