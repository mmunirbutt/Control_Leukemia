clc;
clear;

% === Parameters ===
dim = 4;                      % Number of variables (a1, a2, a3, a4)
nFox = 30;                    % Number of foxes
max_iter = 15;                % Number of iterations
lb = [0.01, 0.01, 0.01, 0.01];   % Lower bounds
ub = [2, 2, 2, 2];               % Upper bounds

% === Initialize population ===
foxes = repmat(lb, nFox, 1) + rand(nFox, dim) .* repmat(ub - lb, nFox, 1);
fitness = zeros(nFox, 1);

% === Evaluate initial population ===
for i = 1:nFox
    fitness(i) = cost_func_rfo(foxes(i, :));
end

[bestFitness, idx] = min(fitness);
bestFox = foxes(idx, :);

% === Tracking Arrays ===
bestCostTrack = zeros(max_iter, 1);
gainsTrack = zeros(max_iter, dim);

% === Main Optimization Loop ===
for iter = 1:max_iter
    disp(['Iteration: ', num2str(iter), ' Best Cost: ', num2str(bestFitness)]);

    for i = 1:nFox
        % Fox movement
        newFox = foxes(i, :) + rand(1, dim) .* (bestFox - foxes(i, :));
        newFox = max(min(newFox, ub), lb);

        newFitness = cost_func_rfo(newFox);

        if newFitness < fitness(i)
            foxes(i, :) = newFox;
            fitness(i) = newFitness;

            if newFitness < bestFitness
                bestFitness = newFitness;
                bestFox = newFox;
            end
        end
    end

    bestCostTrack(iter) = bestFitness;
    gainsTrack(iter, :) = bestFox;
end

% === Results ===
disp('=== Optimization Completed ===');
disp(['Best Gains: ', num2str(bestFox)]);
disp(['Best Cost: ', num2str(bestFitness)]);

% === Visualization ===

% % 1. Scatter Plot (a1 vs a2, colored by fitness)
% figure;
% scatter(foxes(:, 3), foxes(:, 4), 80, fitness, 'filled');
% colormap jet;
% colorbar;
% xlabel('a1');
% ylabel('a2');
% title('a1 vs a2 colored by Cost');
% grid on;

% % 2. Parallel Coordinates Plot
% figure;
% parallelcoords([foxes fitness], 'Labels', {'a1','a2','a3','a4','Cost'});
% title('Parallel Coordinates Plot for Parameters and Cost');
% grid on;

% 3. Convergence Curve
figure;
if max_iter > 1
    normCost = (bestCostTrack - min(bestCostTrack)) / (max(bestCostTrack) - min(bestCostTrack) + eps);
    plot(linspace(0, 100, max_iter), normCost, 'b-', 'LineWidth', 2);
    xlabel('Progress (%)');
    ylabel('Normalized Cost');
    title('Normalized Convergence Behavior of RFO');
    grid on;
else
    bar(1, bestCostTrack(1), 'FaceColor', [0.2 0.6 0.8]);
    xlabel('Only Iteration');
    ylabel('Cost Value');
    title('Single Iteration Cost (No Convergence Curve)');
    grid on;
end
drawnow;
