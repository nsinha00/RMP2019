function [next,r,z0] = MaxPrice(H,n,p,last,bake,price,wait,SDPC,r,t_i,z0)
cost = ones(n,1);
    for i = 1:n
        if isequal(H.Nodes.Orders{i},[0;0;0])
            cost(i) = 1; 
        else
            cost(i) = erf(-1*H.Nodes.Orders{i}(2)/20);
        end
    end
    
    next = find(cost == min(cost));
    
    if numel(next) > 1
        next = randsample(next,1);
    end
end