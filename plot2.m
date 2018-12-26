function plot2(problem, myTitle, axU, axY)
    x = linspace(problem.x0, problem.xE, 500);
    y = problem.y(x);
    p0 = Problem(problem.b0, problem.j, problem.optO, problem.method, problem.bcType, problem.d, problem.funcStrings);
    y0 = p0.y(x);
    
    tName = '';
    if nargin == 2
        tName = [myTitle ': '];
    end
    if nargin ~= 4
        figure('Name', sprintf('%sPsi0 = %f; Psi1 = %f', tName,...
           problem.criteria(), problem.constraint()));
        %       'Position', [0 0 500 1000]);
    end
    
    if nargin < 3
        subplot(3, 1, 1);
    else
        axes(axU);
    end
    hold on
    %plot(problem.Omega, repmat(problem.uMin,1,2), '--');
    %plot(problem.Omega, repmat(problem.uMax,1,2), '--');
    plot(x,p0.u(x), 'g');
    plot(x,problem.u(x));
    hold off
    xlabel(' ')
    title('Control function');
    
    if nargin < 4
        subplot(3, 1, [2 3]);
    else
        axes(axY);
    end
    hold on
    plot(x, y0, 'g');
    plot(x, y);
    
    optRange = problem.Omega(problem.optO)';
    line(optRange, repmat(problem.yd, size(optRange)),...
        'Color', 'r', 'LineStyle', '-.');
    
    limRange = problem.Omega(Utils.OtherIndex(problem.optO))';
    line(limRange, repmat(problem.yMax, size(limRange)),...
        'Color', 'b', 'LineStyle', '--');
    
    line(repmat(problem.Omega(1),2,1), repmat(get(gca,'YLim'),2,1)',...
        'Color', 'm', 'LineStyle', ':');
    hold off
    title('State function');
    xlabel('x');
    if (any(problem.b0 ~= problem.b))
        legend({'Initial', 'Optimal'}, 'Location', 'southeast');
    end
end