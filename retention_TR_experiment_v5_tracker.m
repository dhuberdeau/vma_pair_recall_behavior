function varargout = retention_TR_experiment_v5_tracker(varargin)
% Screen('Preference', 'SkipSyncTests', 1);
%% Specify trial list
% ultimately replace this section with code to load in a separately
% prepared trial table file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
AssertOpenGL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

% screen_dims = [1600, 900];
screen_dims = [1920, 1080];
home_position = screen_dims/2;
TARG_LEN = 350;
% targ_angles = 15+(0:60:300);
targ_angles = 0:90:300;
targ_coords_base = TARG_LEN*[cosd(targ_angles)', sind(targ_angles)'] + home_position;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
res1 = 1920;
res2 = 1080;
screen_dim1 = screen_dims(1);
screen_dim2 = screen_dims(2);

load('camera_params');
load('mm_per_pix');
load('camera_angle_calibration.mat');
% angle_error = angle_error;
c_rr = cosd(angle_error);
s_rr = sind(angle_error);
ROT_MAT = [c_rr s_rr; -s_rr c_rr];

ind1 = repmat((1:res2)', 1, res1);
ind2 = repmat((1:res1), res2, 1);

DISC_SIZE = 40;

ind1_d = repmat((1:DISC_SIZE:res2)', 1, res1/DISC_SIZE);
ind2_d = repmat((1:DISC_SIZE:res1), res2/DISC_SIZE, 1);
SUBWIN_SIZE = 75;
ind1 = repmat((1:res2)', 1, res1);
ind2 = repmat((1:res1), res2, 1);

RMIN = 0;
RMAX = .025;

pre_alloc_samps = 36000; %enough for 10 minutes blocks
pre_alloc_trial = 15*60; %enough for 15 second trials
x = nan(1, pre_alloc_samps);
y = nan(1, pre_alloc_samps);
tim = nan(1, pre_alloc_samps); %pre-allocate space for 10-min. of 60-hz recording.


delays = nan(5,pre_alloc_samps);
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

%%

im_list = cell(1,4);
im_list{1}= imread('afasa1.jpg');
im_list{2}= imread('afasa2.jpg');
im_list{3}= imread('afasa3.jpg');
im_list{4}= imread('afasa4.jpg');

CUE_TIME = .250; %sec
RET_TIME = 3; %sec
TR_TIME = 1.1; %sec 
MOV_TIME = 1.9; % (1.1 for targ disp, 1.9 for movement)
MOV_LIMIT_TIME = .75; %time limit from release of home key to press of another key
TR_TOLERANCE = .15;
FB_TIME = .75;
ITI_TIME = 2; %inter-trial interval time
% TEXT_LOC = [600 525];
TEXT_LOC = home_position;
TEXT_SIZE = 40;
SCREEN_COORD_X = screen_dims(1);
SCREEN_COORD_Y = screen_dims(2);

InitializePsychSound
pahandle = PsychPortAudio('Open');

Ts = 1/44100;
sound_dur = .1;
tone_freq1 = 1000;
tone_freq2 = 1700;
time = Ts:Ts:.1;
tone_signal1 = .1*sin(tone_freq1*time);
tone_signal2 = .1*sin(tone_freq2*time);

sound_data = [tone_signal1, zeros(1, round(.4/Ts)), tone_signal1, zeros(1, round(.4/Ts)), tone_signal2];
sound_data2 = repmat(sound_data, 2, 1);
PsychPortAudio('FillBuffer', pahandle, sound_data2);

cursor_color = [0 0 0]';
cursor_dims = [-7.5 -7.5 7.5 7.5]'; %box dimensions defining circle around center
target_circle_dims = [-TARG_LEN, -TARG_LEN, TARG_LEN, TARG_LEN];
target_color = [1 53 53]';
target_dims = [-10 -10 10 10]';
bubble_start_diam = 2;
bubble_end_diam = TARG_LEN;
bubble_expand_rate = 800;

%% full session - ramped pPT
SUB_NUM_ = 'dmh';
%%
[trial_target_numbers_MASTER, trial_type_MASTER, prescribed_PT_MASTER] = generate_trial_table_E1retention_v5(SUB_NUM_);

screens=Screen('Screens');
screenNumber=min(screens);
[win, rect] = Screen('OpenWindow', screenNumber, []); %[0 0 1600 900]);

for block_num = 1:4
    switch block_num
        case 1
            this_trials = 1:12;
% this_trials = 1:1;
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 2
            this_trials =12+(1:60);
% this_trials = 1:1;
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 3
            this_trials = 12+60+(1:60);
% this_trials = 1:1;
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 4
            this_trials = 12+120+(1:60);
% this_trials = 1:1;
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        otherwise
            error('Not a valid block')
    end

    N_TRS = length(trial_target_numbers);
    % N_TRS = 100;

    %% setup data collection
    Data.MT = nan(N_TRS, 1);
    Data.RT = nan(N_TRS, 1);
    Data.Succ = nan(N_TRS, 1);
    % Data.Key = nan(N_TRS, 1);
    Data.pPT = nan(N_TRS, 1);
    Data.time_targ_disp = nan(N_TRS, 1);
    Data.Type = nan(N_TRS, 1);
    Data.ViewTime = nan(N_TRS, 1);
    Data.Kinematics = cell(N_TRS, 1);
    Data.EventTimes = cell(N_TRS, 1);
    Data.Target = nan(N_TRS, 1);

    %% initialize kinematics
%     kinematics = nan(pre_alloc_samps, 3);
    
    %% wait for subject to begin new block
    Screen('DrawText', win, 'Please press any key to begin the next block.', round(screen_dim1/2), round(screen_dim2/2));
    Screen('Flip', win);
    pause;
    %% run through trial list

    try
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
        grabber = Screen('OpenVideoCapture', win);
        Screen('StartVideoCapture', grabber, 60, 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

%         exp_time = tic;
        exp_time = GetSecs;
        for i_tr = 1:N_TRS

            state = 'prestart';
            entrance = 1;
            kinematics = nan(pre_alloc_trial, 3);
            flip_onset_times = nan(1, pre_alloc_trial);
            flip_offset_times = nan(1, pre_alloc_trial);
            stim_times = nan(1, pre_alloc_trial);
            image_capture_time = nan(1, pre_alloc_trial);
            k_samp = 1;
            trial_time = GetSecs; %tic;
            screen_text_buff = {};
            screen_pic_buff = {};
            screen_picDim_buff = cell(2,0);
            screen_oval_buff = nan(4, 0);
            screen_color_buff = nan(3, 0);
            screen_bubble_buff = nan(4, 0);
            draw_text_flag = 0;
            draw_pic_flag = 0;
            draw_bubble_flag = 0;
            draw_red_cursor_flag = 0;
            k_text_buff = 1;
            k_pic_buff = 1;
            k_oval_buff = 0;
    %         curr_target = targ_coords_base(trial_target_numbers(i_tr), :);
            curr_target = home_position;
            while ~isequal(state, 'end_state')

                % record position data and draw all text/pics/objects
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
                k = sum(~isnan(x(1,:)))+1;
                del_1 = tic;
                [tex, pts, nrdropped, imtext]=Screen('GetCapturedImage', win, grabber, 1, [], 2);
                image_capture_time(k_samp) = pts - exp_time;
                delays(1,k) = toc(del_1);
                del_1 = tic;
    %             img = permute(imtext([3,2,1], :,:), [3,2,1]);
                img_ = imtext(:, 1:DISC_SIZE:end, 1:DISC_SIZE:end);
                img = permute(img_([3,2,1], :,:), [3,2,1]);
                b = rgb2hsv(img);
    %             b = (double(img_(:,:,1)) - mean(img_(:,:,[2:3]),3))./max(max(double(img_(:,:,1))));
                delays(2,k) = toc(del_1);
                del_1 = tic;
                im_r = inRange(b, [RMAX 1 1], [RMIN 0.5 0.5]);
    %             im_r = b > .25;
                trk_y_rd = round(median(ind1_d(im_r)));
                trk_x_rd = round(median(ind2_d(im_r)));
                delays(3,k) = toc(del_1);
                del_1 = tic;
    %             img_ = imtext(:, max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]), max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]));
                img_ = imtext(:, max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]), max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]));
                img = permute(img_([3 2 1], :, :), [3 2 1]);
    %             c_r = rgb2hsv(img(max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]), max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]), :));
                c_r = rgb2hsv(img);
                im_r = inRange(c_r, [.02 1 1], [0 0.5 0.5]);
                rel_ind2 = ind2(max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]),max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]));
                rel_ind1 = ind1(max([(trk_y_rd - SUBWIN_SIZE),1]):min([(trk_y_rd + SUBWIN_SIZE),res2]),max([(trk_x_rd - SUBWIN_SIZE),1]):min([(trk_x_rd + SUBWIN_SIZE), res1]));
                trk_y_r = median(rel_ind1(im_r));
                trk_x_r = median(rel_ind2(im_r));
                delays(4,:) = toc(del_1);
                del_1 = tic;
                if ~isempty(trk_x_r) && ~isempty(trk_y_r)
                    try
                        calib_pts_ = undistortPoints([trk_x_r, trk_y_r], camera_params);
                        calib_pts = (calib_pts_ - [res1, res2]/2)*ROT_MAT + [res1, res2]/2;
                    catch
                        calib_pts = nan(1,2);
                    end
                else
                    calib_pts = nan(1,2);
                end
                x(1,k) = calib_pts(1,1)*mm_pix;
                y(1,k) = calib_pts(1,2)*mm_pix;
%                 tim(k) = toc(exp_time);
                tim(k) = GetSecs - exp_time;
                xr = calib_pts(1,1)*screen_dims(1)/res1;
                yr = calib_pts(1,2)*screen_dims(2)/res2;
                Screen('Close', tex);
                delays(5,k)= toc(del_1);
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE

                kinematics(k_samp, :) = [GetSecs - exp_time, xr, yr];% translate to screen coordinates
                Screen('FillOval', win, [cursor_color, screen_color_buff],...
                    [[kinematics(k_samp, 2:3), kinematics(k_samp, 2:3)]' + cursor_dims, ...
                    screen_oval_buff]);
                Screen('FrameOval', win, [74, 96, 96]', [home_position home_position]' + target_circle_dims');
                if draw_text_flag == 1
                    for i_text = 1:length(screen_text_buff)
                        Screen('DrawText', win, screen_text_buff{i_text}, TEXT_LOC(1), TEXT_LOC(2) + (i_text - 1)*15);
                    end
                end
                if draw_pic_flag == 1
                    for i_pic = 1:length(screen_pic_buff)
                        Screen('DrawTexture', win, screen_pic_buff{i_pic}, screen_picDim_buff{1, i_pic}, screen_picDim_buff{2, i_pic});
                    end
                end
                if draw_bubble_flag == 1
                    Screen('FrameOval', win, 1, [home_position home_position]' + screen_bubble_buff(:)); 
                    if norm(kinematics(k_samp, 2:3) - home_position) < screen_bubble_buff(end)
                        draw_red_cursor_flag = 1;
                    end
                end
                if draw_red_cursor_flag
                    Screen('FillOval', win, [255, 0, 10]',...
                        [kinematics(k_samp, 2:3), kinematics(k_samp, 2:3)]' + cursor_dims);
                end
                
                % THE MAIN EXPERIMENT FLIP (FLIPS SCREEN EVERY SAMPLE):
%                 Screen('Flip', win);
                [t_flip_0, t_stim, t_flip_f] = Screen('Flip', win);
                flip_onset_times(k_samp) = t_flip_0 - exp_time;
                flip_offset_times(k_samp) = t_flip_f - exp_time;
                stim_times(k_samp) = t_stim - exp_time;
                
                switch state
                    case 'prestart'
                        if entrance == 1
                            % first entrance into state
    %                         Screen('DrawText', win, 'Go to Home', 600, 525);
    %                         Screen('Flip', win);
                            screen_text_buff{k_text_buff} = 'Go to Home';
    %                         k_text_buff = k_text_buff + 1;
                            draw_text_flag = 1;
                            screen_oval_buff(:,1) = [home_position home_position]' + target_dims;
                            screen_color_buff(:,1) = target_color;
                            k_oval_buff = k_oval_buff + 1;
                            Data.pPT(i_tr) = prescribed_PT(i_tr);
                            Data.Type(i_tr) = trial_type(i_tr);
                            entrance = 0;
                        else
    %                         [keyIsDown,secs,keyCode]=KbCheck;
    %                         if keyIsDown && keyCode(home)
                            targ_dist = norm(curr_target - kinematics(k_samp, 2:3));
                            if targ_dist <= 15 %&& temp_jkey
                                % home pos reached: switch to home state
                                entrance = 1;
                                state = 'home';
                                draw_text_flag = 0;
                                draw_pic_flag = 0;
                            else
                                % have not reached home & pressed key1 yet
                            end
                        end
                    case 'home'
                        if entrance == 1
                            % first entrance into home state
                            home_start_time = GetSecs - trial_time; %toc(trial_time);
                            switch trial_type(i_tr)
                                case 4 % catch trial 
                                    rnd_ind = randperm(3);
                                    switch trial_target_numbers(i_tr)
                                        case 1
                                            temp_alt_targ = [2 3 4];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        case 2
                                            temp_alt_targ = [1 3 4];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        case 3
                                            temp_alt_targ = [1 2 4];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        case 4 
                                            temp_alt_targ = [1 2 3];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        otherwise
                                            error('Invalid target name listed');
                                    end
                                     screen_picDim_buff{1, k_pic_buff} = [0; 0; tx_size(2); tx_size(1)];
                                     screen_picDim_buff{2, k_pic_buff} = [TEXT_LOC(1) - TEXT_SIZE; TEXT_LOC(2) - TEXT_SIZE;...
                                         TEXT_LOC(1) + TEXT_SIZE; TEXT_LOC(2) + TEXT_SIZE];
                                     screen_pic_buff{k_pic_buff} = temp_tx;
                                     draw_pic_flag = 1;
                                     Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 3 % catch trial
                                    rnd_ind = randperm(3);
                                    k_oval_buff = k_oval_buff + 1;
                                    switch trial_target_numbers(i_tr)
                                        case 1       
                                            temp_alt_targ = [2 3 4];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 3;
                                        case 2
                                            temp_alt_targ = [1 3 4];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 4;
                                        case 3
                                            temp_alt_targ = [1 2 4];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 5;
                                        case 4 
                                            temp_alt_targ = [1 2 3];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 6;
                                        otherwise
                                            error('Invalid target name listed');
                                    end
                                    Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 2
                                    switch trial_target_numbers(i_tr)
                                        case 1
                                            temp_tx = Screen('MakeTexture', win, im_list{1});
                                            tx_size = size(im_list{1});
                                        case 2
                                            temp_tx = Screen('MakeTexture', win, im_list{2});
                                            tx_size = size(im_list{2});
                                        case 3
                                            temp_tx = Screen('MakeTexture', win, im_list{3});
                                            tx_size = size(im_list{3});
                                        case 4 
                                            temp_tx = Screen('MakeTexture', win, im_list{4});
                                            tx_size = size(im_list{4});
                                        otherwise
                                            error('Invalid target name listed');
                                    end
                                     screen_picDim_buff{1, k_pic_buff} = [0; 0; tx_size(2); tx_size(1)];
                                     screen_picDim_buff{2, k_pic_buff} = [TEXT_LOC(1) - TEXT_SIZE; TEXT_LOC(2) - TEXT_SIZE;...
                                         TEXT_LOC(1) + TEXT_SIZE; TEXT_LOC(2) + TEXT_SIZE];
                                     screen_pic_buff{k_pic_buff} = temp_tx;
                                     draw_pic_flag = 1;
                                     Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 1
                                    k_oval_buff = k_oval_buff + 1;
                                    screen_oval_buff(:, k_oval_buff) = [targ_coords_base(trial_target_numbers(i_tr),:)'; targ_coords_base(trial_target_numbers(i_tr),:)'] + target_dims;
                                    screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                    Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 0
                                    %show nothing
                                    Data.Target(i_tr) = trial_target_numbers(i_tr);
                                otherwise
                                    error('No valid trial type specified.')
                            end 
                            entrance = 0;
                            curr_target = targ_coords_base(trial_target_numbers(i_tr),:);
                        else
%                             if (toc(trial_time) - home_start_time) < CUE_TIME
                            if ((GetSecs - trial_time) - home_start_time) < CUE_TIME
                                % actually do nothing.. just wait
                            else
                                % extinguish cue and switch to retention state
    %                             Screen('Flip', win);
                                draw_text_flag = 0;
                                draw_pic_flag = 0;
                                switch trial_type(i_tr)
                                    case 4
                                    case 3
                                        k_oval_buff = k_oval_buff - 1;
                                        screen_oval_buff = screen_oval_buff(:, 1:k_oval_buff);
                                        screen_color_buff = screen_color_buff(:, 1:k_oval_buff);
                                    case 2
                                    case 1
                                        k_oval_buff = k_oval_buff - 1;
                                        screen_oval_buff = screen_oval_buff(:, 1:k_oval_buff);
                                        screen_color_buff = screen_color_buff(:, 1:k_oval_buff);
                                    case 0
                                    otherwise
                                        error('invalid trial type')
                                end
                                entrance = 1;
                                state = 'retention';
                            end
                        end
                    case 'retention'
                        if entrance == 1
                            % just entered state
                            retention_start_time = GetSecs - trial_time; %toc(trial_time);
                            entrance = 0;
                        else
                            if ((GetSecs - trial_time) - retention_start_time) < RET_TIME 
                                %(toc(trial_time) - retention_start_time) < RET_TIME
                                % actually do nothing.. just wait
                            else
                                % extinguish cue and switch to retention state
    %                             Screen('Flip', win);
                                entrance = 1;
                                state = 'TR';
                            end
                        end
                    case 'TR'
                        if entrance == 1
                            % just entered TR state
                            TR_state_time = GetSecs - trial_time; %toc(trial_time);
                            startTime = PsychPortAudio('Start', pahandle);
                            target_shown = 0;
                            mov_begun = 0;
                            mov_ended = 0;
                            entrance = 0;
                            move_start_time = nan;
                            move_end_time = nan;
                        else
                            home_dist = norm(home_position - kinematics(k_samp, 2:3));
    %                         targ_dist = norm(curr_target - kinematics(k_samp, 2:3));
%                             state_elapsed_time = (toc(trial_time) - TR_state_time);
                            state_elapsed_time = ((GetSecs - trial_time) - TR_state_time);
                            if state_elapsed_time >= TR_TIME
                                bubble_rad = (state_elapsed_time - TR_TIME)*bubble_expand_rate;
                                if bubble_rad > TARG_LEN
                                    draw_bubble_flag = 0;
                                else
                                    screen_bubble_buff = [-bubble_rad; -bubble_rad; bubble_rad; bubble_rad];
                                    draw_bubble_flag = 1;
                                end
                            else
                                draw_bubble_flag = 0;
                            end
                            if home_dist > 15 && ~mov_begun
                                % movement just begun
                                mov_begun = 1;
                                move_start_time = (GetSecs - trial_time); %toc(trial_time);
                            end
                            if home_dist > TARG_LEN && ~mov_ended
                                mov_ended = 1;
                                move_end_time = GetSecs - trial_time; %toc(trial_time);
                            end
                            if ((GetSecs - trial_time) - TR_state_time) > (TR_TIME - prescribed_PT(i_tr))
                            %if (toc(trial_time) - TR_state_time) > (TR_TIME - prescribed_PT(i_tr))
                                % time to show target once
                                if target_shown == 0
                                    k_oval_buff = k_oval_buff + 1;
                                    screen_oval_buff(:, k_oval_buff) = [targ_coords_base(trial_target_numbers(i_tr),:)'; targ_coords_base(trial_target_numbers(i_tr),:)'] + target_dims;
                                    screen_color_buff(:, k_oval_buff) = [0;0;0];
                                    target_shown = 1;
                                    target_shown_time = GetSecs - trial_time; %toc(trial_time);
                                    Data.time_targ_disp(i_tr) = GetSecs - exp_time;%toc(exp_time);
                                else
                                    % no need to do anything
                                end
                            else
                                % wait for PT start time
                            end
                            %if (toc(trial_time) - TR_state_time) > (TR_TIME + MOV_TIME)
                            if ((GetSecs - trial_time) - TR_state_time) > (TR_TIME + MOV_TIME)
                                % transition to ITI state
                                entrance = 1;
                                state = 'ITI';
                                if mov_begun
                                    Data.ViewTime(i_tr) = (target_shown_time - TR_state_time) - (move_start_time - TR_state_time);
                                    Data.RT(i_tr) = (move_start_time - TR_state_time) - TR_TIME;
                                end
                                if mov_ended
                                    Data.MT(i_tr) = move_end_time - move_start_time;
                                    Data.Succ(i_tr) = 1;
                                else
                                    Data.Succ(i_tr) = 0;
                                end
                            end
                        end
                    case 'ITI'
                        if entrance == 1
                            ITI_state_time = GetSecs - trial_time; %toc(trial_time);
                            draw_red_cursor_flag = 0;
                            if abs(Data.RT(i_tr)) >= TR_TOLERANCE && Data.RT(i_tr) >= 0
                                % movement was earlier than "go" cue &
                                % outside of tolerance
    %                             screen_text_buff = {'MOVED TOO LATE!'};
    %                             draw_text_flag = 1;
    %                             Screen('DrawText', win, 'MOVED TOO SOON!', 680, 525);
    %                             Screen('Flip', win);
                            elseif abs(Data.RT(i_tr)) > TR_TOLERANCE && Data.RT(i_tr) < 0
                                screen_text_buff = {'MOVED TOO SOON!'};
                                draw_text_flag = 1;
    %                             Screen('DrawText', win, 'MOVED TOO LATE!', 680, 525);
    %                             Screen('Flip', win);
                            else
                                % timing was within tolerance.. disp nothng
                            end
                            if Data.MT(i_tr) > MOV_LIMIT_TIME
    %                             screen_text_buff{length(screen_text_buff) + 1} = 'MOVED TOO SLOW!';
    %                             draw_text_flag = 1;
    %                             Screen('DrawText', win, 'MOVED TOO SLOWLY!', 680, 650);
    %                             Screen('Flip', win);
                            else
                                % MT was within tolerance... disp nothing
                            end

                            entrance = 0;
                        else
                            %if (toc(trial_time) - ITI_state_time) > FB_TIME
                            if ((GetSecs - trial_time) - ITI_state_time) > FB_TIME
                                % extinguish feedback
    %                             Screen('Flip', win);
                                draw_text_flag = 0;
                            end
%                             if (toc(trial_time) - ITI_state_time) > (ITI_TIME)
                            if ((GetSecs - trial_time) - ITI_state_time) > (ITI_TIME)
                                % end trial
    %                             Screen('Flip', win);
                                draw_text_flag = 0;
                                Data.Kinematics{i_tr} = kinematics(~isnan(kinematics(:,1)), :);
                                Data.EventTimes{i_tr} = [image_capture_time; ...
                                    flip_onset_times;
                                    stim_times;
                                    flip_offset_times];
                                state = 'end_state';
                            end
                        end
                    otherwise
                        error('No state specified');
                end
                k_samp = k_samp + 1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
        if exist('grabber')
                Screen('StopVideoCapture', grabber);
                Screen('CloseVideoCapture', grabber);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
%         sca;
    catch
        try
            warning('An error occured')
            Data.ViewTime = Data.pPT - Data.RT;
            uniqueness_code = now*10000000000;
            save([SUB_NUM_, num2str(uniqueness_code)], 'Data');
            varargout = {0, lasterror, Data, kinematics, delays};
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
            Screen('StopVideoCapture', grabber);
            Screen('CloseVideoCapture', grabber);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
            sca;
            return
        catch
            try
                %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
                Screen('StopVideoCapture', grabber);
                Screen('CloseVideoCapture', grabber);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%% CAMERA KAPTURE
                sca
                return
            catch
                sca;
                clear all; close all; clc
                return
            end
        end
        sca
        return
    end
    Data.ViewTime = Data.pPT - Data.RT;
    Data.x_track = x; Data.y_track = y; Data.t_track = tim;
    varargout = {1, [], Data, kinematics, delays};
    uniqueness_code = now*10000000000;
    save([SUB_NUM_, num2str(uniqueness_code)], 'Data');
    
    %% between blocks break
    if block_num < 4
        Screen('Flip', win);
        Screen('DrawText', win, 'This is a mandatory 30 second break. Tracking has been disabled.', round(screen_dim1/2), round(screen_dim2/2));
        Screen('Flip', win);
        pause(10);%change back to 10 (and those below)
        Screen('DrawText', win, '...20 more seconds', round(screen_dim1/2), round(screen_dim2/2));
        Screen('Flip', win);
        pause(10);
        Screen('DrawText', win, '...10 more seconds', round(screen_dim1/2), round(screen_dim2/2));
        Screen('Flip', win);
        pause(5);
        Screen('DrawText', win, '...5 more seconds', round(screen_dim1/2), round(screen_dim2/2));
        Screen('Flip', win);
        pause(5);
        Screen('DrawText', win, 'Beginning new block now...', round(screen_dim1/2), round(screen_dim2/2));
        Screen('Flip', win);
        pause(1);
    else
        % exit
    end
end
Screen('Flip', win);
Screen('DrawText', win, 'This now completes the experiment. Thank you for participating.', round(screen_dim1/2), round(screen_dim2/2));
Screen('Flip', win);
pause;
sca;