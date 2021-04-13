% Load data
load('mats\A1_data.mat', 'Xaudio', 'Ttest', 'Ttrain', 'fs')
load 'lambdaopt.mat'

% Clean audio using the optimal lambda
Yclean = lasso_denoise(Ttest, Xaudio, lambdaopt);

% Concatenate noisy audio with clean audio and play
Y = [Ttrain; Yclean];
soundsc(Y);
 
% Save audio
save('denoised_audio.mat', 'Yclean')