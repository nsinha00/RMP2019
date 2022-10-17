function next = Random(H,n,~,~,~,~,~,~,~)
cost = ones(n,1);
    for i = 1:n
        if isequal(H.Nodes.Orders{i},[0;0;0])
            cost(i) = 1; 
        else
            cost(i) = rand;
        end
    end

next = randsample(cost);
end