function [LensMagnification] = calc_MagnificationOfLensSystem(Lenses)
    %% 1. Calc the manificationfactor of a given set of lenses (from first to last) 
    LensMagnification = 1;
    for i = 1:length(Lenses)
        LensMagnification = LensMagnification*Lenses(i)^((-1)^i);
    end
end

