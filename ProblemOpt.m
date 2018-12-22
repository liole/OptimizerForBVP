classdef ProblemOpt < ProblemAM
    properties
       yVal
       uVal
       solving = false
       uSol = {}
    end
    methods
        function this = ProblemOpt(b, j, optO, method, bcType, d)
            this = this@ProblemAM(b, j, optO, method, bcType, d);
        end
        function initConstraints(this)
            sol = Problem(this.b).direct();
            y = sol.y(1,:);
            y1 = min(y);
            y2 = max(y);
            y12 = y2 - y1;
            this.yd = (y1 + y2) / 2;
            this.yMax = y2 - this.k*y12;
        end
        function u = u(this, x)
            if this.solving
                u = this.uVal(1);
            else
                sol = this.solve();
                u = deval(sol, x, 3);
            end
        end
        function y = y(this, x, i)
            if (nargin < 3)
               i = 1;
            end
            if this.solving
                y = this.yVal(i);
            else
                sol = this.direct();
                y = deval(sol, x, i);
            end
        end
        function m = muToU(this)
            y = this.yVal;
            mult = {-y(2), -y(1), -y(1).^3, 1};
            m = -2*this.gammaU/mult{this.j};
        end
        function dp = odeOpt(this, x, p)
            this.yVal = p([1 2]);
            this.uVal = p([3 4]);
            m = this.muToU();
            dp = [this.ode(x,this.yVal);...
                this.odeAM(x,m*this.uVal, 0)/m];
        end
        function res = bcOpt(this, p0, pE)
            m = this.muToU();
            res = [this.bc(p0([1 2]),pE([1 2]));...
                this.bcAM(m*p0([3 4]),m*pE([3 4]))/m];
        end
        function sol = solve(this)
            this.solving = true;
            if ~isempty(this.uSol)
                sol = this.uSol{1};
            else
                bd = mean(this.b);
                init = bvpinit(this.Omega, [this.yd 0 bd 0]);
                sol = bvp4c(@this.odeOpt,@this.bcOpt, init);
                this.uSol = {sol};
            end
            this.solving = false;
        end
    end
end