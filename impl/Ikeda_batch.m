function batch = Ikeda_batch(F, s, pump_range, pump_levels, cw_newton_tol, cw_curve_tol, conv_cw_tol, conv_var_tol)
% Create a new Ikeda batch object holding systems.

    batch.type = 'Ikeda';
    batch.cw_newton_tol = cw_newton_tol;
    batch.cw_curve_tol  = cw_curve_tol;

    batch.conv_cw_tol  = conv_cw_tol;
    batch.conv_var_tol = conv_var_tol;

    batch.id_cnt = 1;

    batch.F = F;
    batch.alpha = pi/F;
    batch.s = s;

    batch.mi_bounds = [];
    batch.bistab_bounds = [];

    % Determine the highest occurrence of overlapping bistability from
    % adjacent red mode resonances
    [cw_upper, ~, cw_lower] = cw_Ikeda(batch.alpha, pump_range(end), ...
                                       cw_newton_tol, cw_curve_tol);
    branch_start = cw_lower(1, 1) - 2*pi;
    branch_end = cw_upper(1, end);
    batch.folds = floor((branch_end - branch_start)/(2*pi));
    

    for P = logspace(log10(pump_range(1)), log10(pump_range(end)), pump_levels)

        [cw_upper, cw_middle, cw_lower] = cw_Ikeda(batch.alpha, P, ...
                                                   cw_newton_tol, cw_curve_tol);

        % Add detun-power points on modulational instability boundary
        mi_detun = [cw_upper(1, cw_upper(2, :) > batch.alpha), ...
                    cw_lower(1, cw_lower(2, :) > batch.alpha)];

        if ~isempty(mi_detun)
            p1 = [min(mi_detun); P];
            p2 = [max(mi_detun); P];
            batch.mi_bounds = [p1 batch.mi_bounds p2];
        end       

        % Add detun-power points on bistability boundary
        if ~isequal(cw_upper, cw_middle, cw_lower)
            p1 = [min(cw_middle(1, :)); P];
            p2 = [max(cw_middle(1, :)); P];
            batch.bistab_bounds = [p1 batch.bistab_bounds p2];
        end

    end

    batch.systems = struct('id', {}, ...
                           'series', {}, ...
                           'budget', {}, ...
                           'frozen', {}, ...
                           'alpha', {}, ...
                           's', {}, ...
                           'R', {}, ...
                           'N', {}, ...
                           'T', {}, ...
                           'nT', {}, ...
                           'sweep_series', {}, ...
                           'detun_start', {}, ...
                           'detun_end', {}, ...
                           'detun', {}, ...
                           'power_start', {}, ...
                           'power_end', {}, ...
                           'power', {}, ...
                           'buffer_size', {}, ...
                           'field_buffer', {}, ...
                           'cw_upper_power', {}, ...
                           'cw_lower_power', {}, ...
                           'freeze_lim', {}, ...
                           'freeze_in', {}, ...
                           'variance', {}, ...
                           'cw_lower_diff', {}, ...
                           'cw_upper_diff', {}, ...
                           'state', {}, ...
                           'noise', {}, ...
                           'noise_gen', {});

end