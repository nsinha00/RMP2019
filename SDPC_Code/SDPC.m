clear 
algorithm = @TDAlg;     
t = 35000;
prices = [0.01,0.0075,0.0075,0.005,0.005]; %price of order, by node
order_likelihoods = [0.01, 0.0075, 0.0075, 0.005, 0.005];

%% Graph 
Adjacency =[00,26,40,24,00,  ,  ,  ;
            26,00,22,00,00,  ,  ,  ;
            40,22,00,22,00,  ,  ,  ;
            24,00,22,00,35,  ,  ,  ;
            00,00,00,35,00,  ,  ,  ;
            00,00,00,35,00,  ,  ,  ;
            00,00,00,35,00,  ,  ,  ];
            00,00,00,35,00,  ,  ,  ];
H = graph(Adjacency);
x = [2.75,5.75,5.5,3,0]; y = [3.5,5,2,1,0.5]; % Helps visualize it

%% TD initial values 
r = ones(1,7);
z0 = zeros(1,7);

%% Shortcuts 
n = numnodes(H);
bake = 1;
price = 2;
wait = 3;
SDPC = n+1;

%% SDPC 
last = randsample(n,1);
nextstop = last;
H = addnode(H,1);
H = addedge(H,last,SDPC,0);
dists = distances(H);

%% Initial conditions 
H.Nodes.Orders(:) = {[0;0;0]};
delivering = 0;
t_i = 1;
moving = 0;
t_elapsed = 0;

%% Metrics 
Orders_MaxWait_TD = zeros(1,t);

Waits = zeros(1,t);
Revenues = zeros(1,t);
Distances = zeros(1,t);

%% Time loop 
for t = 1:t
   %% Orders
   % Idea: try cancelling orders after x time
   for i = 1:n
       if isequal(H.Nodes.Orders{i},[0;0;0])
           if i == 1 && rand < order_likelihoods(1)
               H.Nodes.Orders(i) = {[normrnd(22,5);normrnd(18,4);0]}; % = [bake,price,wait]
           end
           if i == 2 && rand < order_likelihoods(2)
               H.Nodes.Orders(i) = {[normrnd(22,5);normrnd(17,4);0]}; % = [bake,price,wait]
           end
           if i == 3 && rand < order_likelihoods(3)
               H.Nodes.Orders(i) = {[normrnd(22,5);normrnd(16,4);0]}; % = [bake,price,wait]
           end
           if i == 4 && rand < order_likelihoods(4)
               H.Nodes.Orders(i) = {[normrnd(22,5);normrnd(20,4);0]}; % = [bake,price,wait]
           end
           if i == 5 && rand < order_likelihoods(5)
               H.Nodes.Orders(i) = {[normrnd(22,5);normrnd(17,4);0]}; % = [bake,price,wait]
           end
       end
   end

   %% Control Alg 
   if delivering == 0
       [next,r,z0] = algorithm(H,n,prices,last,bake,price,wait,SDPC,r,t_i,z0);
       t_i = t_i+1;
   end

   %% Traveling 
   delivering = 1;
   path1 = shortestpath(H,SDPC,last);
   path2 = shortestpath(H,last,next);
   path2(1) = [];
   if size(path1,2) == 1
       path = shortestpath(H,SDPC,next);
   else
       path = cat(2,path1,path2);
   end
   if degree(H,SDPC) == 1 && size(path,2) == 2
       moving = 0;
       if t_elapsed < H.Nodes.Orders{next}(bake)
           % do nothing
       else
           if ~isequal(H.Nodes.Orders{next},[0;0;0])
               Orders_MaxWait_TD(t) = t;
               Waits(t) = H.Nodes.Orders{next}(wait); % Metrics
               Revenues(t) = H.Nodes.Orders{next}(price); % Metrics
               Distances(t) = dists(last,next); % Metrics
           end
           H.Nodes.Orders{next} = [0;0;0];
           t_elapsed = 0;
           delivering = 0;
           % Order Delivered
       end
   else
       moving = 1;
       nextstop = path(3);
       t_travel = dists(last,nextstop);
       if t_elapsed < t_travel
            H = rmedge(H,[last,nextstop],[SDPC,SDPC]);
            H = addedge(H,[last,nextstop],[SDPC,SDPC],[t_elapsed,t_travel-t_elapsed]);
       else
            H = rmedge(H,[last,nextstop],[SDPC,SDPC]);
            H = addedge(H,nextstop,SDPC,0);
            if t_elapsed < H.Nodes.Orders{next}(bake)
                % do nothing (baking...)
            else
                if nextstop == next
                    if ~isequal(H.Nodes.Orders{next},[0;0;0])
                        Orders_MaxWait_TD(t) = t;
                        Waits(t) = H.Nodes.Orders{next}(wait); % Metrics
                        Revenues(t) = H.Nodes.Orders{next}(price); % Metrics
                        Distances(t) = dists(last,next); % Metrics
                    end
                    
                    H.Nodes.Orders{next} = [0;0;0];
                    delivering = 0;
                    moving = 0;
                    % Order Delivered
                end
            end
            t_elapsed = 0;
            last = nextstop;
       end
   end

   t_elapsed = t_elapsed + 1;
   for k = 1:n % Wait time
       if ~isequal(H.Nodes.Orders{k},[0;0;0])
           H.Nodes.Orders{k}(wait) = H.Nodes.Orders{k}(wait) + 1;
       end
   end 

   %% Plotting 
   %
   Plot = true;
   if Plot
       if nextstop == last
           x(SDPC) = x(last);
           y(SDPC) = y(last);
       else
           x(SDPC) = (t_elapsed*x(nextstop)+(t_travel-t_elapsed)*x(last))/(t_travel);
           y(SDPC) = (t_elapsed*y(nextstop)+(t_travel-t_elapsed)*y(last))/(t_travel);
       end

       Plot = plot(H,'XData',x,'YData',y,'EdgeLabel',H.Edges.Weight,'EdgeColor','black','EdgeFontName','times new roman','EdgeFontSize',9,'NodeColor','black','NodeFontName','Times new roman','NodeFontSize',10);  
       labelnode(Plot,2,'Bronx');
       labelnode(Plot,3,'Queens');
       labelnode(Plot,4,'Brooklyn');
       labelnode(Plot,5,'Staten Is.');
       labelnode(Plot,SDPC,"SDPC"); 
       highlight(Plot,SDPC,'Marker','^','MarkerSize',5);

       for i = 1:n
           if ~isequal(H.Nodes.Orders{i},[0;0;0])
               highlight(Plot,i,'NodeColor','m');
           else
               highlight(Plot,i,'NodeColor','black');
           end
       end
       pause(0.000125);
   end
  %}
end

%% Waits 
Waits = Waits(Orders_MaxWait_TD ~= 0);
Waits_MaxWait_TD = zeros(size(Waits));
for i = 1:numel(Waits)
    Waits_MaxWait_TD(i) = mean(Waits(1:i));
end

%% Revenues 
Revenues = Revenues(Orders_MaxWait_TD ~= 0);
Revenues_avg = zeros(size(Revenues));
for i = 1:numel(Revenues)
    Revenues_avg(i) = mean(Revenues(1:i));
end
Revs_MaxWait_TD = cumsum(Revenues);

%% Distances 
Distances = Distances(Orders_MaxWait_TD ~= 0);
Dists_MaxWait_TD = zeros(size(Distances));
for i = 1:numel(Distances)
    Dists_MaxWait_TD(i) = mean(Distances(1:i));
end

%% OrderTimes 
Orders_MaxWait_TD = Orders_MaxWait_TD(Orders_MaxWait_TD ~= 0);

%% Plotting Metrics
figure()
plot(Orders_MaxWait_TD,Waits_MaxWait_TD);
title('Avg Wait over Time');
xlabel('Time');
ylabel('Avg Wait');
avg_of_Waits = Waits_MaxWait_TD(end)
max_of_Waits = max(Waits)
std_of_Waits = std(Waits)

figure();
plot(Orders_MaxWait_TD,Revs_MaxWait_TD);
title('Total Revenue over Time');
xlabel('Time');
ylabel('Total Revenue Collected');

figure();
plot(Orders_MaxWait_TD,Dists_MaxWait_TD);
title('Distance per Order over Time');
xlabel('Time');
ylabel('Distance per Order');

disp(strcat('DONE!'));
