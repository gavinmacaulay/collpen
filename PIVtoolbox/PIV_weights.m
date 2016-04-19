function [w,level,EM]=PIV_weights(snrs,pkhs,is,par)
%
% function w=PIV_weights(snrs,pkhs,is,par)
%
% The PIV analysis works well when clear translations and with high SNR.
% When no fish are seen in the image, the PIV should be remo ved. However,
% instead of using a hard threshold for detecting single individual fish,
% we calucate a weight based on the image strength.
% Instead of hard-thresholding the PIV estimates, we creates weights for
% each PIV estimate to be used in subsequent analysis. The weights are
% calculated as follows:
%
% w = w_pkhs * w_snr * w_thr
%
% where w_pkhs = pkhs,
%       w_snr = .5*(1+erf((snrs-par.msnrs)/sqrt(2*par.ssnrs^2))),
% and   w_thr = .5*(1+erf((is-par.msthr)/sqrt(2*par.sthr^2)))
%
% and par.msnrs and par.ssnrs, and par.msthr and par.ssthr is the mean snr
% and thr threshold and variance parameters, respectively.
%
% Keane and Adrian Keane and Adrian [1992] suggest that a threshold
% value of about msnr=1.3 is appropriate.
%
% A threshold level of w is calculated using Otsu's method that can be used
% to filter out low quality samples.

% (C) Nils Olav Handegard


% Calculate weights
w_snr =.5*(1+erf((snrs-par.msnrs)/sqrt(2*par.ssnrs^2)));
w_thr =.5*(1+erf((is-par.mthr)/sqrt(2*par.sthr^2)));

% Outide relevant area
% if nargin ==2
%     
% end
% Weights
w = w_snr.*w_thr.*pkhs ;



%hist([w_snr(:) w_thr(:) pkhs(:) w(:)],200)
%legend({'snr','thr','pkhs','w'})

% Create threshold using Otsu's method
[level EM] = graythresh(w);

