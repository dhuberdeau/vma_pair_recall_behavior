function [trial_target_numbers, trial_type, prescribed_PT, trial_stimA] = generate_trial_table_E1retention_v5(subject_code)
% subject_code = 'S025';

%% setup:

% setup pairs of stimuli that are predictable: [ A, B ]
predictable_pairs = [...
    1 1; ...
    2 1;...
    2 2;...
    3 2;...
    3 3;...
    4 3;...
    4 4;...
    1 4];
    
unpredictable_list = [5 6 7 8];

%% Block 0 (practice)
% Just target:
seed_targ_nums = repmat(1:4, 1, 3);
trial_target_numbers_0 = seed_targ_nums(randperm(length(seed_targ_nums)));

trial_type_0 = ones(size(trial_target_numbers_0));

prescribed_PT_0 = linspace(.9, 0, length(trial_target_numbers_0));

trial_stimA_0 = ones(size(trial_target_numbers_0));

%% Block 1 (Training)
% more of Just target:
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_1 = seed_targ_nums(randperm(length(seed_targ_nums)));

trial_type_1 = ones(size(trial_target_numbers_1));

seed_pPT = repmat(linspace(.6, 0, block_len/4), 1, 4);
prescribed_PT_1 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

trial_stimA_1 = ones(size(trial_target_numbers_1));

%% Block 2 (Introduce symbols - all predictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_2 = seed_targ_nums(randperm(length(seed_targ_nums)));

trial_type_2 = 2*ones(size(trial_target_numbers_2));

seed_pPT = repmat(linspace(.6, 0, block_len/4), 1, 4);
prescribed_PT_2 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = nan(size(trial_target_numbers_2));
for i_tr = 1:length(seed_stimA)
    matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_2(i_tr), 1);
    this_pair = matching_pairs(randperm(2));
    seed_stimA(i_tr) = this_pair(1);
end
trial_stimA_2 = seed_stimA;

%% Block 3 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_3 = seed_targ_nums(randperm(length(seed_targ_nums)));

trial_type_3 = 2*ones(size(trial_target_numbers_3));

seed_pPT = repmat(linspace(.6, 0, block_len/4), 1, 4);
prescribed_PT_3 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = nan(size(trial_target_numbers_3));
for i_tr = 1:length(seed_stimA)
    matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_3(i_tr), 1);
    this_pair = matching_pairs(randperm(2));
    seed_stimA(i_tr) = this_pair(1);
end
trial_stimA_3 = seed_stimA;

%% Block 4 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_4 = seed_targ_nums(randperm(length(seed_targ_nums)));

trial_type_4 = 2*ones(size(trial_target_numbers_4));

seed_pPT = repmat(linspace(.6, 0, block_len/4), 1, 4);
prescribed_PT_4 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = nan(size(trial_target_numbers_4));
coin = randperm(length(seed_stimA));
for i_tr = 1:length(seed_stimA)
    coin_flip = mod(coin(i_tr), 2);
    if coin_flip == 1
        % make this trial predictable 
        matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_4(i_tr), 1);
        this_pair = matching_pairs(randperm(2));
        seed_stimA(i_tr) = this_pair(1);
    else
        % make this trial unpredictable
        shuffled_list = unpredictable_list(randperm(length(unpredictable_list)));
        seed_stimA(i_tr) = shuffled_list(1);
    end
    
end
trial_stimA_4 = seed_stimA;

%% Block 5 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_5 = seed_targ_nums(randperm(length(seed_targ_nums)));

trial_type_5 = 2*ones(size(trial_target_numbers_5));

seed_pPT = repmat(linspace(.6, 0, block_len/4), 1, 4);
prescribed_PT_5 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = nan(size(trial_target_numbers_5));
coin = randperm(length(seed_stimA));
for i_tr = 1:length(seed_stimA)
    coin_flip = mod(coin(i_tr), 2);
    if coin_flip == 1
        % make this trial predictable 
        matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_5(i_tr), 1);
        this_pair = matching_pairs(randperm(2));
        seed_stimA(i_tr) = this_pair(1);
    else
        % make this trial unpredictable
        shuffled_list = unpredictable_list(randperm(length(unpredictable_list)));
        seed_stimA(i_tr) = shuffled_list(1);
    end
    
end
trial_stimA_5 = seed_stimA;

%% Block 6 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_6 = seed_targ_nums(randperm(length(seed_targ_nums)));

trial_type_6 = 2*ones(size(trial_target_numbers_6));

seed_pPT = repmat(linspace(.6, 0, block_len/4), 1, 4);
prescribed_PT_6 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = nan(size(trial_target_numbers_6));
coin = randperm(length(seed_stimA));
for i_tr = 1:length(seed_stimA)
    coin_flip = mod(coin(i_tr), 2);
    if coin_flip == 1
        % make this trial predictable 
        matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_6(i_tr), 1);
        this_pair = matching_pairs(randperm(2));
        seed_stimA(i_tr) = this_pair(1);
    else
        % make this trial unpredictable
        shuffled_list = unpredictable_list(randperm(length(unpredictable_list)));
        seed_stimA(i_tr) = shuffled_list(1);
    end
    
end
trial_stimA_6 = seed_stimA;

%% combine blocks
trial_target_numbers = [...
    trial_target_numbers_0, ...
    trial_target_numbers_1, ...
    trial_target_numbers_2, ...
    trial_target_numbers_3, ...
    trial_target_numbers_4, ...
    trial_target_numbers_5, ...
    trial_target_numbers_6, ...
    ];
    
trial_type = [...
    trial_type_0, ...
    trial_type_1, ...
    trial_type_2, ...
    trial_type_3, ...
    trial_type_4, ...
    trial_type_5, ...
    trial_type_6, ...
    ];

prescribed_PT = [...
    prescribed_PT_0, ...
    prescribed_PT_1, ...
    prescribed_PT_2, ...
    prescribed_PT_3, ...
    prescribed_PT_4, ...
    prescribed_PT_5, ...
    prescribed_PT_6, ...
    ];

trial_stimA = [...
    trial_stimA_0, ...
    trial_stimA_1, ...
    trial_stimA_2, ...
    trial_stimA_3, ...
    trial_stimA_4, ...
    trial_stimA_5, ...
    trial_stimA_6, ...
    ];

%% save subject data
save(['trial_parameters_', subject_code], 'trial_target_numbers', 'trial_type', 'prescribed_PT', 'trial_stimA');


