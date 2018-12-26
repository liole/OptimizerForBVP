classdef ProblemFDM < ProblemSensitivityBase
    methods
        function this = ProblemFDM(b, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected)
            this = this@ProblemSensitivityBase(b, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected);
        end
        
        function grad = Gradient(this, index)
            if ~isempty(this.cacheGrad{index+1})
                grad = this.cacheGrad{index+1};
            else
                if nargin < 3
                   d = 0.01; 
                end
                b = this.b;
                n = length(b);
                g = zeros(2, n);
                psi = [this.Psi(0), this.Psi(1)];
                oldCache = this.cacheBVP;
                for i = 1:n
                    bD = b;
                    bD(i) = bD(i) + d;
                    this.setControl(bD);
                    for j = 1:2
                        psiD = this.Psi(j-1);
                        g(j,i) = (psiD - psi(j)) / d;
                    end
                end
                this.setControl(b);
                this.cacheBVP = oldCache;
                this.cacheGrad{1}= g(1,:);
                this.cacheGrad{2}= g(2,:);
                grad = g(index+1,:);
            end
        end
    end
end