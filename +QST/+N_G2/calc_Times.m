function [Times] = calc_Times(Length,AverageMethod,AverageSize,StepSize,Options)
    arguments
        Length;
        AverageMethod {mustBeMember(AverageMethod,['static','moving'])};
        AverageSize;
        StepSize;
        Options.Samplerate = 75.3864;
        Options.FirstQuadIndex = 1; 
    end
    %% 1. Calculate Times
    switch AverageMethod
        case 'static'
            Times = Options.FirstQuadIndex-1+(0.5:1:Length)*AverageSize*1/(Options.Samplerate*1000000);
        case 'moving'
            Times = (Options.FirstQuadIndex-1+((1:1:Length)-1)*StepSize+0.5*AverageSize)*1/(Options.Samplerate*1000000);
        otherwise
            error('Only "static" or "moving" are allowed modes');
    end
end
