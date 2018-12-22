classdef (Abstract) ProblemSensitivityBase < Problem
    properties
        constrGrad = true
        optimizeFU = false % no optimization possible!!!
        cacheGrad = {[],[]}
        cacheSens = {}
    end
    methods
        function this = ProblemSensitivityBase(b, j, optO, method, bcType, d, funcs)
            this = this@Problem(b, j, optO, method, bcType, d, funcs);
        end
        function updateControl(this, b)
            this.updateControl@Problem(b);
            this.cacheGrad = {[],[]};
            if this.j ~= 4 || ~this.optimizeFU
                this.cacheSens = {};
            end
        end
        function [psi0, grad] = optCriteria(this, b)
            psi0 = this.optCriteria@Problem(b);
            if nargout > 1 % gradient required
                grad = this.Gradient(0)';
            end
        end
        function [c, ceq, gC, gCeq] = optConstraint(this, b)
            [c, ceq] = this.optConstraint@Problem(b);
            if nargout > 2 % gradients required
                gC = [];
                gCeq = this.Gradient(1)';
            end
        end
        function options = optOptions(this)
            options = this.optOptions@Problem();
            options.GradObj = 'on';
            if this.constrGrad
                options.GradConstr = 'on';
            end
        end
        
        function du = dudb(this, x, i)
            db = zeros(1, length(this.b));
            db(i) = 1;
            du = this.interpolate(x, db, this.method);
        end
    end
    methods(Abstract)
        grad = Gradient(this, index)
    end
end
