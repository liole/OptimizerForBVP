function plotAll(problem, myTitle)    
    x = linspace(problem.x0, problem.xE, 500);
    y = problem.y(x);
    
    tName = '';
    if nargin == 2
        tName = [myTitle ': '];
    end
    figure('Name', sprintf('%sPsi0 = %f; Psi1 = %f', tName,...
       problem.criteria(), problem.constraint()));
    %       'Position', [0 0 500 1000]);
    
    subplot(3, 1, 1);
    hold on
    %plot(problem.Omega, repmat(problem.uMin,1,2), '--');
    %plot(problem.Omega, repmat(problem.uMax,1,2), '--');
    plot(x,problem.u(x));
    hold off
    xlabel(' ')
    title('Control function');
    
    subplot(3, 1, [2 3]); 
    hold on
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
end