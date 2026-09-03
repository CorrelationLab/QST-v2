function [StandardError]= getStandardErrorsFromFit(Params,gof,method)
%% Description:
%   This function estimates the standard errors of the coefficients obtained from a MATLAB curve-fitting result.
%
%   The standard errors are derived from confidence intervals returned by confint and the degrees of freedom stored in
%   the goodness-of-fit structure. Two alternative calculation methods are available.
%
%% Syntax:
%   StandardError = getStandardErrorsFromFit(Params, gof, method)
%
%% Input:
% required input values:
%   Params                                          - fitted model object returned by MATLAB fit
%
%   gof                                             - goodness-of-fit structure returned by MATLAB fit; the field dfe is
%                                                     used as the number of degrees of freedom
%
%   method                                          - method used to estimate the standard errors:
%
%                                                     't_Distribution': derive a one-standard-error confidence interval using
%                                                     the Student's t distribution
%
%                                                     any other value: derive standard errors from a 95 % confidence
%                                                     interval and the associated Student's t quantile
%
%% Output:
%   StandardError                                   - vector containing the estimated standard error of every fitted
%                                                     coefficient; the coefficient order follows the fitted model Params
%
%% Notes:
%   This function requires Curve Fitting Toolbox function confint and Statistics and Machine Learning Toolbox
%   functions tcdf and tinv.



    arguments
        Params;
        gof;
        method
    end


    if strcmp(method,'t_Distribution')
        %source:
        %https://de.mathworks.com/matlabcentral/answers/34234-how-to-obtain-std-of-coefficients-from-curve-fitting,
        % comment from Tom Lane
%         The 1 comes from wanting 1 standard error. The negative sign is to 
%         get the level associated with 1 standard error below zero. 
%         The multiplication by 2 is to include the values beyond 2 standard 
%         error above the mean, by symmetry.
        level = 2*tcdf(-1,gof.dfe);
        m = confint(Params,1-level);    
        StandardError = (m(2,:)-m(1,:))/2;    
    else
        % source: https://de.mathworks.com/matlabcentral/answers/153547-how-can-i-compute-the-standard-error-for-coefficients-returned-from-curve-fitting-functions-in-the-c
        alpha = 0.95;
        ci = confint(Params, alpha);
        t = tinv((1+alpha)/2, gof.dfe); 
        StandardError = (ci(2,:)-ci(1,:)) ./ (2*t);
    end
end