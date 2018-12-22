clear;
tic;


b0 = [0 0 0];
j = 4;    % index of u in [r g1 g3 fu]
optO = 2; % index of Omega to minimize on
method = 'constant'; % linear or constant
bcType = [Utils.Dirichlet; Utils.Neumann];
d = [0 1]; % boundary condition values

q = ProblemAM(b0, j, optO, method, bcType, d);
q.optimize(true, true);
format long
q.criteria()
q.constraint()
toc;
plot2(q);