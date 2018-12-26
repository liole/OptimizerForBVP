classdef Problem < handle
    properties % variant setup
        j = 4    % index of u in [r g1 g3 fu]
        optO = 2 % index of Omega to minimize on
        method = 'constant' % linear or constant
        bcType = [Utils.Dirichlet; Utils.Neumann]
        d = [0 1] % boundary condition values
    end
    properties
        b  % current opt. var values
        b0
        r  = @(x) 1
        g1 = @(x) 3
        g3 = @(x) 2
        fu = @(x) 3
        f0 = @(x) 1
        x0 = 0
        xE = 1
        uMin = -10 % -10
        uMax = 10  % 10
        gammaY = 1
        gammaU = 1e-2
        p = [0.25 0.25]
        k = 0.1
        yd = 0 
        yMax = 1
        cacheBVP = {} % save direct problem solutions
        funcStrings
        isKSelected=true
    end
    methods
        function this = Problem(b, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected)
            if length(b) == 1 && strcmp(this.method, 'linear')
                b = [b b];
            end
            this.b = b;
            this.b0 = b;
            
            % for GUI
            this.j = j;
            this.optO = optO;
            this.method = method;
            this.bcType = bcType;
            this.d = d;
            this.parseFuncs(funcs);
            this.x0 = x0;
            this.xE = xE;
            this.uMin = uMin;
            this.uMax = uMax;
            this.gammaY = gammaY;
            this.gammaU = gammaU;
            this.p = [p1 p2];
            this.isKSelected=isKSelected;
            if(isKSelected)
                this.k = k;
                this.initConstraints();
            else
                this.yd=yd;
                this.yMax=yMax;
            end            
            this.replaceU();
            
        end
        function parseFuncs(this, funcs)
            syms x;
            this.funcStrings = funcs;
            this.r  = matlabFunction(eval(funcs{1}), 'Vars', x);
            this.g1 = matlabFunction(eval(funcs{2}), 'Vars', x);
            this.g3 = matlabFunction(eval(funcs{3}), 'Vars', x);
            this.fu = matlabFunction(eval(funcs{4}), 'Vars', x);
        end
        function replaceU(this)
           params = {this.r, this.g1, this.g3, this.fu}; 
           params{this.j} = @this.u;
           [this.r, this.g1, this.g3, this.fu] = deal(params{:});
        end
        function f = interpolate(this, x, v, m)
            const = strcmp(m, 'constant');
            len = length(v) + const;
            interval = linspace(this.x0, this.xE, len);
            if (const)
                f = Utils.ConstInterp(interval, v, x);
            else
                f = interp1(interval, v, x, m);
            end
        end
        function u = u(this, x)
            u = this.interpolate(x, this.b, this.method);
        end
        function dy = ode(this, x, y)
            dy = zeros(2, 1);
            dy(1) = y(2);
            dy(2) = this.r(x)*y(2) + this.g1(x)*y(1) + ...
                this.g3(x)*y(1)^3 - this.f0(x) - this.fu(x);
        end
        function res = bc(this, y0, yE)
            res = zeros(2, 1);
            res(1) = this.bcType(1,:)*y0 - this.d(1);
            res(2) = this.bcType(2,:)*yE - this.d(2);
        end
        function range = Omega(this, index)
            if nargin == 1 || index == 0
                range = [this.x0 this.xE];
            else
                len = this.xE - this.x0;
                o1(1) = this.x0 + this.p(1) * len;
                o1(2) = this.xE - this.p(2) * len;
                if index == 1
                    range = o1;
                else
                    range = [this.x0, o1(1); o1(2) this.xE];
                end
            end
        end
        function iO = limO(this)
            iO = Utils.OtherIndex(this.optO);
        end
        function setControl(this, b)
            if any(this.b ~= b)
                this.updateControl(b);
            end
        end
        function updateControl(this, b)
            this.b = b;
            this.cacheBVP = {};
        end
        function sol = direct(this)
            if ~isempty(this.cacheBVP)
                sol = this.cacheBVP{1};
            else
                init = bvpinit(this.Omega, [this.yd 0]);
                sol = bvp4c(@this.ode,@this.bc, init);
                this.cacheBVP = {sol};
            end
        end
        function initConstraints(this)
            sol = this.direct();
            y = sol.y(1,:);
            y1 = min(y);
            y2 = max(y);
            y12 = y2 - y1;
            this.yd = (y1 + y2) / 2;
            this.yMax = y2 - this.k*y12;
        end
        function y = y(this, x, i)
            if (nargin < 3)
               i = 1;
            end
            sol = this.direct();
            y = deval(sol, x, i);
        end
        function psi0 = criteria(this)
            psi0 = this.gammaY * Utils.Integrate(...
                    this.Omega(this.optO),...
                    @(x) (this.y(x)-this.yd).^2) + ...
                this.gammaU * Utils.Integrate(...
                    this.Omega(0), ...
                    @(x) this.u(x).^2);
        end
        function psi0 = optCriteria(this, b)
            this.setControl(b);
            psi0 = this.criteria();
        end
        function psi1 = constraint(this)
            psi1 = Utils.Integrate(...
                this.Omega(this.limO),...
                @(x) (abs(this.y(x)-this.yMax)+...
                          this.y(x)-this.yMax).^2);
        end
        function [c, ceq] = optConstraint(this, b)
            this.setControl(b);
            c = [];
            ceq = this.constraint();
        end
        function psi = Psi(this, index)
            switch index
                case 0
                    psi = this.criteria();
                case 1
                    psi = this.constraint();
            end
        end
        function options = optOptions(~)
            options = optimset('LargeScale', 'on',...
                               'MaxFunEvals', 1000);
        end
        function optimize(this, yConstraint, bConstraint)
            
            nonLinCon = [];
            if yConstraint
                nonLinCon = @this.optConstraint;
            end
            
            bLower = [];
            bUpper = [];
            if bConstraint
                bLower = repmat(this.uMin, size(this.b));
                bUpper = repmat(this.uMax, size(this.b));
            end
            
            options = this.optOptions();
            
            if yConstraint || bConstraint
                b = fmincon(        ...
                    @this.optCriteria,...
                    this.b,        ...
                    [],[],[],[],    ... % no linear constraints
                    bLower, bUpper, ...
                    nonLinCon,      ...
                    options         ...
                );
            else
                b = fminunc(@this.optCriteria, this.b, options);
            end
            this.setControl(b);
        end
    end
end