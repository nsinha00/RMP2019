function [next,r,z0] = TDAlg(H,n,p,last,bake,price,wait,SDPC,r,t_i,z0)

    alpha = 0.5;
    lambda = 0.9;
    
    waittimes = zeros(1,n);
    for i = 1:n % Wait Times
        waittimes(i) = H.Nodes.Orders{i}(3);
    end

    dists = distances(H);

    prices = zeros(1,n);
    for i = 1:n % Prices
        prices(i) = H.Nodes.Orders{i}(2);
    end

    degrees = centrality(H,'degree');
    degrees = degrees(1:n);
    for i = 1:n % Degrees
        if isequal(H.Nodes.Orders(i),[0;0;0])
            degrees(i) = 0;
        end
    end

    closeness = centrality(H,'closeness');
    closeness = closeness(1:n);
    for i = 1:n % Closeness
        if isequal(H.Nodes.Orders,[0;0;0])
            closeness(i) = 0;
        end
    end
    
    %{
    bakedist = zeros(1,n);
    for i = 1:n %! Bake Dist (add bakedistU)
        if ~isequal(H.Nodes.Orders{i},[0;0;0])
            bakedist(i) = abs(H.Nodes.Orders{i}(bake)-dists(SDPC,i));
        end
    end
    %}

    %! vvv Expand to more features 
    f(1) = max(waittimes);
    f(2) = mean(waittimes);
    f(3) = max(prices);
    f(4) = mean(prices);
    f(5) = mean(dists(SDPC,:));
    f(6) = mean(degrees); % Delete
    f(7) = mean(closeness); % Delete
    % add max dist to another order
    %f(8) = mean(bakedist);
    %! ^^^

    J = r*f';

    for i = 1:n
        if ~isequal(H.Nodes.Orders{i},[0;0;0]) || i == last
            U(i) = i;
        end
    end
    U = U(U ~= 0);
    T = 10;
    G = zeros(size(U));

    for i = 1:numel(U) % Determine cost vector
        f1 = feature(i,H,n,p,f,U,dists,last,bake,waittimes,prices,degrees,closeness);
        % MinDist: dists(SDPC,U(i)); -
        % MaxPrice: H.Nodes.Orders{U(i)}(price); +
        % MaxWait: H.Nodes.Orders{U(i)}(wait); +
        g = H.Nodes.Orders{U(i)}(wait); % PARAMETER OPTIMIZED FOR
        G(i) = g+alpha*f1*r';
    end

    gibbs = (exp(+G/T)/sum(exp(+G/T)))'; % +G/T for max, -G/T for min
    next = U(find(rand<=cumsum(gibbs),1));
    d = G(find(U == next)) - J;
    
    if t_i == 1
        z = feature(find(U == next),H,n,p,f,U,dists,last,bake,waittimes,prices,degrees,closeness);
    else
        z = feature(find(U == next),H,n,p,f,U,dists,last,bake,waittimes,prices,degrees,closeness) + alpha*lambda*z0;
    end
    
    r = (r + (t_i^(-1))*d*z);
    r = r/sum(abs(r));
    
    z0 = z;

    function f1 = feature(i,H,n,p,f,U,dists,last,bake,waittimes,prices,degrees,closeness)
        waittimesU = zeros(1,n);
        pricesU = zeros(1,n);
        degreesU = zeros(1,n);
        closenessU = zeros(1,n);

        f1 = zeros(size(f));

        for j = 1:n % waittimesU
            if U(i) == j
                waittimesU(j) = 0;
            elseif isequal(H.Nodes.Orders{j},[0;0;0])
                waittimesU(j) = (1-(1-p(j))^max(dists(U(i),j),H.Nodes.Orders{U(i)}(bake)))*max(dists(U(i),j),H.Nodes.Orders{U(i)}(bake))/2;
            else
                waittimesU(j) = waittimes(j)+max(H.Nodes.Orders{U(i)}(bake),dists(last,U(i)));
            end
        end

        for j = 1:n % pricesU
            if U(i) == j
                pricesU(j) = 0;
            elseif prices(j) == 0 %? Randomness or expected value?
                pricesU(j) = (1-(1-p(j))^max(dists(U(i),j),H.Nodes.Orders{U(i)}(bake)))*22;
            else
                pricesU(j) = prices(j);
            end
        end   

        for j = 1:n % degreesU
            if U(i) == j
                degreesU(j) = 0;
            elseif degrees(j) == 0
                degreesU(j) = (1-(1-p(j))^max(dists(U(i),j),H.Nodes.Orders{U(i)}(bake)))*degree(j);
            else
                degreesU(j) = degrees(j);
            end
        end

        for j = 1:n % closenessU
            if U(i) == j
                closenessU(j) = 0;
            elseif degrees(j) == 0
                closenessU(j) = (1-(1-p(j))^max(dists(U(i),j),H.Nodes.Orders{U(i)}(bake)))*closeness(j);
            else
                closenessU(j) = closeness(j);
            end
        end

        f1(1) = max(waittimesU);
        f1(2) = mean(waittimesU);
        f1(3) = max(pricesU);
        f1(4) = mean(pricesU);
        f1(5) = mean(dists(U(i),:));
        f1(6) = mean(degreesU);
        f1(7) = mean(closenessU);
    end
end
