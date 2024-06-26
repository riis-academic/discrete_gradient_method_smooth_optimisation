function [b,fval] = fzeroskeleton(x,tol,u_old,u_l,Dxul,Dyut,E,g,i,j,Ny,Nx,dt,aa,epsilon,sqrteps)
badint = 0;
% Interval input
if (numel(x) == 2) 
 
    a = x(1);
    b = x(2);    
    fa = itohabe(a,u_old,u_l,Dxul,Dyut,E,g,i,j,Ny,Nx,dt,aa,epsilon,sqrteps);
  
    fb = itohabe(b,u_old,u_l,Dxul,Dyut,E,g,i,j,Ny,Nx,dt,aa,epsilon,sqrteps);
    
%    energyfxn()
    
    if fa*fb > 0
%         disp('Wrong start interval');
        badint = 1;
        x = 0.01;
    end
    
    if ~fa
        b = a;
        return
    elseif ~fb
        % b = b;

        return
    end
end
    % Starting guess scalar input
if (numel(x) == 1) || badint

    
    fx = itohabe(x,u_old,u_l,Dxul,Dyut,E,g,i,j,Ny,Nx,dt,aa,epsilon,sqrteps);

    if fx == 0
        b = x;
 
        return

    end
    
    if x ~= 0
        dx = x/5;
    else 
        dx = 1/50;
    end
    
    % Find change of sign.
    twosqrt = sqrt(2); 
    a = x; fa = fx; b = x; fb = fx;
    


    while (fa > 0) == (fb > 0)
        dx = twosqrt*dx;
        a = x - dx;  fa = itohabe(a,u_old,u_l,Dxul,Dyut,E,g,i,j,Ny,Nx,dt,aa,epsilon,sqrteps);

        if ~isfinite(fa) || ~isreal(fa) || ~isfinite(a)
            b = NaN;
            return
        end

        if (fa > 0) ~= (fb > 0) % check for different sign
            % Before we exit the while loop, print out the latest interval
 
            break
        end
        
        b = x + dx;  fb = itohabe(b,u_old,u_l,Dxul,Dyut,E,g,i,j,Ny,Nx,dt,aa,epsilon,sqrteps);
 
   

    end % while
end % if (numel(x) == 2)

fc = fb;
% Main loop, exit from middle of the loop
while fb ~= 0 && a ~= b
    % Insure that b is the best result so far, a is the previous
    % value of b, and c is on the opposite side of the zero from b.
    if fb*fc > 0
        c = a;  fc = fa;
        d = b - a;  e = d;
    end
    if abs(fc) < abs(fb)
        a = b;    b = c;    c = a;
        fa = fb;  fb = fc;  fc = fa;
    end
    
    % Convergence test and possible exit
    m = 0.5*(c - b);
    toler = 2.0*tol*max(abs(b),1.0);
    if (abs(m) <= toler) || (fb == 0.0) 
        break
    end
    
    % Choose bisection or interpolation
    if (abs(e) < toler) || (abs(fa) <= abs(fb))
        % Bisection
        d = m;  e = m;
    else
        % Interpolation
        s = fb/fa;
        if (a == c)
            % Linear interpolation
            p = 2.0*m*s;
            q = 1.0 - s;
        else
            % Inverse quadratic interpolation
            q = fa/fc;
            r = fb/fc;
            p = s*(2.0*m*q*(q - r) - (b - a)*(r - 1.0));
            q = (q - 1.0)*(r - 1.0)*(s - 1.0);
        end
        if p > 0, q = -q; else p = -p; end
        % Is interpolated point acceptable
        if (2.0*p < 3.0*m*q - abs(toler*q)) && (p < abs(0.5*e*q))
            e = d;  d = p/q;
        else
            d = m;  e = m;
        end
    end % Interpolation
    
    % Next point
    a = b;
    fa = fb;
    if abs(d) > toler, b = b + d;
    elseif b > c, b = b - toler;
    else b = b + toler;
    end
    fb = itohabe(b,u_old,u_l,Dxul,Dyut,E,g,i,j,Ny,Nx,dt,aa,epsilon,sqrteps);
end % Main loop

fval = fb; % b is the best value

end