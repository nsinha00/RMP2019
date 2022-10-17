function [next,r,z0] = MinDistance(H,n,p,last,bake,price,wait,SDPC,r,t_i,z0)
dists = distances(H);
cost = ones(n,1);
    for i = 1:n
        if isequal(H.Nodes.Orders{i},[0;0;0])
            cost(i) = 2; 
        else
            cost(i) = erf(dists(SDPC,i)/max(dists(:)));
        end
    end
    disp(cost);
    next = find(cost == min(cost));
    
    if numel(next) > 1
        next = randsample(next,1);
    end
end