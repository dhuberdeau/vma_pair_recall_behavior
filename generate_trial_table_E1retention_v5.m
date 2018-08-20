function [trial_target_numbers, trial_type, prescribed_PT] = generate_trial_table_E1retention_v5(subject_code)
% subject_code = 'S025';

%% Block 0 (practice block)
% No catch trials
trial_type_begin_ = [zeros(1,12)];
trial_type_begin = trial_type_begin_(randperm(length(trial_type_begin_)));
trial_target_numbers_begin_ = [ones(1,3), 2*ones(1,3), 3*ones(1,3), 4*ones(1,3)];
trial_target_numbers_begin = trial_target_numbers_begin_(randperm(length(trial_target_numbers_begin_)));
prescribed_PT_begin = linspace(.6, 0, 12);


%% Blocks:
trial_target_seed = repmat(repmat(reshape(repmat(1:4, 3, 1), 1, 4*3), 1, 5), 1, 3);
trial_type_seed = repmat(repmat(repmat([0, 1, 2], 1, 4), 1, 5), 1, 3);

trial_randomize = randperm(length(trial_target_seed));
trial_target_numbers_ = trial_target_seed(trial_randomize);
trial_type_ = trial_type_seed(trial_randomize);

gen_rand_PT = @() linspace(.6, 0, 15) + .015*(rand(1, 15) - .5);

prescribed_PT_ = [gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT()];

trial_target_catch_seed = [1:4, 1:4, 1:4, 1:4, 1:4];
trial_type_catch_seed = [[3*ones(1,2), 4*ones(1,2)], [4*ones(1,2), 3*ones(1,2)], [3*ones(1,2), 4*ones(1,2)], [4*ones(1,2), 3*ones(1,2)], [3*ones(1,2), 4*ones(1,2)]];
trial_catch_randomize = randperm(length(trial_target_catch_seed));
trial_target_catch = trial_target_catch_seed(trial_catch_randomize);
trial_type_catch = trial_type_catch_seed(trial_catch_randomize);
prescribed_PT_catch = .400+.200*rand(1,length(trial_target_catch_seed));

l1 = length(trial_type_begin);
l2 = length(trial_type_)/3;
l3 = length(trial_type_catch);

all_trial_inds = 1:(l1 + l2*3 + l3);
catch_trial_patches = l1+[((l1+1):(l2+5)), (l2+5)+((l1+1):(l2+5)), (l2+5)*2+((l1+1):(l2+6))];
rand_inds = randperm(length(catch_trial_patches));
catch_trial_inds = catch_trial_patches(rand_inds(1:l3));
non_catch_trial_inds = setdiff(all_trial_inds, catch_trial_inds);

trial_type = nan(1, length(all_trial_inds));
trial_target_numbers = nan(1, length(all_trial_inds));
prescribed_PT = nan(1, length(all_trial_inds));

trial_type(non_catch_trial_inds) = [trial_type_begin, trial_type_];
trial_target_numbers(non_catch_trial_inds) = [trial_target_numbers_begin, trial_target_numbers_];
prescribed_PT(non_catch_trial_inds) = [prescribed_PT_begin, prescribed_PT_];
trial_type(catch_trial_inds) = trial_type_catch;
trial_target_numbers(catch_trial_inds) = trial_target_catch;
prescribed_PT(catch_trial_inds) = prescribed_PT_catch;

plot(prescribed_PT)

%% save subject data
save(['trial_parameters_', subject_code], 'trial_target_numbers', 'trial_type', 'prescribed_PT');


