Broadly, the program takes random orders over time and applies a given control algorithm to determine its next node before moving there and reevaluating.

Feel free to read the uploaded paper (Sinha-Ferguson-2019) for a deeper explanation of the motivation & problem construction.

The main code is SDPC.m; the other files are helper code.

Key variables:
	algorithm -- change this to reference a control algorithm script (currently there is TDAlg, MaxPrice, MaxWait, MinDistance, and Random)
	t -- the number of timesteps which the time loop executes
	p -- a vector with the probability of an order appearing for each given node
	t_i -- the number of times the program has executed the control algorithm
	Adjacency -- encodes all of the graph information w/ weights representing "distances," which are effectively travel times as far as the program is concerned

Functions:
	Random -- picks control at random; didn't use it but could be helpful
	MaxPrice, MaxWait, MinDistance -- baseline greedy algorithms that optimize for their respective parameter
	TDAlg -- a general temporal difference algorithm which can be modified to optimize for any parameter by changing g

For %% Graph, x and y only affect how the graph is plotted if being displayed

In %% Orders orders are randomly generated according to p
In %% Control Alg the SDPC executes a control alg if it is not currently delivering 
In %% Traveling the SDPC finds the shortest path to the next node and waits that much time according to the distance between them while updating the position of the SDPC -- right now the updating position of the SDPC node doesn't affect the program, but it could help if the SDPC was made to apply the control algorithm for each timestep.

%% Plotting can be turned on and off by uncommenting

Everything following this is designed to compile 3 metrics: wait time per order, revenue per order, and distance traveled per order.
