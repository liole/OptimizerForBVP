clear;
tic;
b0 = [0 0 0];
q = Problem(b0);
q.optimize(true, true);
format long
q.criteria()
q.constraint()
toc;
plot2(q);