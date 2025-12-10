function cost_value = cost_func_rfo(k)
    gain_names = {'g1','g2','g3','g4'};
    persistent try_number;

    if isempty(try_number)
        try_number = 1;
    else
        try_number = try_number + 1;
    end

    disp(['Try number: ', num2str(try_number)]);

    for i = 1:numel(k)
        assignin('base', gain_names{i}, k(i));
        disp(['  ', gain_names{i}, ' = ', num2str(k(i))]);
    end

    error_triggered = false;
    try
        simOut = sim('OptBFSMC_TargetChemo_BrainTumor.slx', 'ReturnWorkspaceOutputs', 'on');
        err_ts = simOut.get('errorr1');
        
        % === FIX: extract numeric data ===
        if isa(err_ts, 'timeseries')
            err = err_ts.Data;  % Extract data from timeseries
        elseif isnumeric(err_ts)
            err = err_ts;
        else
            error('Unknown data format returned for errorr1.');
        end
        
    catch ME
        if strcmp(ME.identifier, 'Simulink:Engine:DerivNotFinite')
            cost_value = inf;
            error_triggered = true;
        else
            rethrow(ME);
        end
    end

    if ~error_triggered
        cost_value = sum(abs(err));  % IAE: Integral of Absolute Error
        disp(['Cost: ', num2str(cost_value)]);
        disp('---');
    end
end
