function [xvar, yvar, xexp, yexp] = Fit2DGaussian(W, axes, plotEnable)
    %% Fit a 2D gaussian function to data
    %% PURPOSE:  Fit a 2D gaussian centroid to simulated data
    % Uses lsqcurvefit to fit
    %
    % INPUT: W - gaussian to fit
    %        axes - gaussian axes: [start step stop]
    %        plot - true or false value which sets whether plotting is done
    % 
    %   
    %% ---------Input checks-------------------
    if nargin < 3
        error("Invalid amount of arguments provided.")
    end
    if size(W, 1) <= 1 | size(W, 2) <= 1
        error("Invalid input gaussian dimensions.")
    end
    if size(axes, 2) ~= 3
        error("Not all axes elements specified, required is: [start step stop].");
    end
    %% ---------User Input---------------------
    MdataSize = 640; % Size of nxn data matrix
    % parameters are: [Amplitude, x0, sigmax, y0, sigmay, angel(in rad)]
    x0 = [1,0,50,0,50,0]; %Inital guess parameters
    InterpolationMethod = 'nearest'; % 'nearest','linear','spline','cubic'
    %% ---Generate centroid to be fitted--------------------------------------
    X = axes(1):axes(2):axes(3);
    [X,Y] = meshgrid(X);
    xdata = zeros(size(X,1),size(Y,2),2);
    xdata(:,:,1) = X;
    xdata(:,:,2) = Y;
    [Xhr,Yhr] = meshgrid(linspace(axes(1),axes(2),300)); % generate high res grid for plot
    xdatahr = zeros(300,300,2);
    xdatahr(:,:,1) = Xhr;
    xdatahr(:,:,2) = Yhr;
    %---Generate noisy centroid---------------------
    Z = W;
    %% --- Fit---------------------
    x0 =x0(1:5);
    xin(6) = 0; 
    x = zeros(6);
    lb = [0,-MdataSize/2,0,-MdataSize/2,0];
    ub = [realmax('double'),MdataSize/2,(MdataSize/2)^2,MdataSize/2,(MdataSize/2)^2];
    [x,resnorm,residual,exitflag] = lsqcurvefit(@QST.Wigner.D2GaussFunction,x0,xdata,Z,lb,ub);
    x(6) = 0;
    xvar = x(3);
    yvar = x(5);
    xexp = x(2);
    yexp = x(4);
    if plotEnable == true
        %% -----Plot profiles----------------
        hf2 = figure(2);
        set(hf2, 'Position', [20 20 950 900])
        alpha(0)
        subplot(4,4, [5,6,7,9,10,11,13,14,15])
        imagesc(X(1,:),Y(:,1)',Z)
        set(gca,'YDir','reverse')
        colormap('jet')
        string1 = ['       Amplitude','    X-Coordinate', '    X-Width','    Y-Coordinate','    Y-Width','     Angle'];
        string2 = ['Set     ',num2str(xin(1), '% 100.3f'),'             ',num2str(xin(2), '% 100.3f'),'         ',num2str(xin(3), '% 100.3f'),'         ',num2str(xin(4), '% 100.3f'),'        ',num2str(xin(5), '% 100.3f'),'     ',num2str(xin(6), '% 100.3f')];
        string3 = ['Fit      ',num2str(x(1), '% 100.3f'),'             ',num2str(x(2), '% 100.3f'),'         ',num2str(x(3), '% 100.3f'),'         ',num2str(x(4), '% 100.3f'),'        ',num2str(x(5), '% 100.3f'),'     ',num2str(x(6), '% 100.3f')];
        text(axes(1)*0.9,axes(3)*1.15,string1,'Color','red')
        text(axes(1)*0.9,axes(3)*1.25,string3,'Color','red')
        %% -----Calculate cross sections-------------
        % generate points along horizontal axis
        m = -tan(x(6));% Point slope formula
        b = (-m*x(2) + x(4));
        xvh = -MdataSize/2:MdataSize/2;
        yvh = xvh*m + b;
        hPoints = interp2(X,Y,Z,xvh,yvh,InterpolationMethod);
        % generate points along vertical axis
        mrot = -m;
        brot = (mrot*x(4) - x(2));
        yvv = -MdataSize/2:MdataSize/2;
        xvv = yvv*mrot - brot;
        vPoints = interp2(X,Y,Z,xvv,yvv,InterpolationMethod);
        hold on % Indicate major and minor axis on plot
        % % plot pints 
        % plot(xvh,yvh,'r.') 
        % plot(xvv,yvv,'g.')
        % plot lins 
        xint = [axes(1) axes(3)];
        yint = [yvh(1) yvh(size(yvh,2))];
        plot([xvh(1) xvh(size(xvh))],[yvh(1) yvh(size(yvh))],'r') 
        plot([xvv(1) xvv(size(xvv))],[yvv(1) yvv(size(yvv))],'g') 
        hold off
        axis([axes(1) axes(3) axes(1) axes(3)])
    end
end