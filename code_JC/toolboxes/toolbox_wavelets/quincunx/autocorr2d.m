function A0=autocorr2d(H)

% AUTOCORR2D
%       Iterative frequency domain calculation of the 2D autocorrelation 
%       function. A=autocorr2d(H) computes the frequency response of
%       the autocorrelation filter A(exp(2*i*Pi*nu)) corresponding to the
%       scaling function with refinement filter H.
%       Please note that the 2D grid of the refinement filter (nu),
%       corresponds to a uniformly sampled grid, twice as coarse
%       (in each dimension) as the given filter H.
%
% Please treat this source code as confidential!
% Its content is part of work in preparation to be submitted:
%
% T. Blu, D. Van De Ville, M. Unser, ''Numerical methods for the computation
% of wavelet correlation sequences,'' SIAM Numerical Analysis.
%
% Biomedical Imaging Group, EPFL, Lausanne, Switzerland.  


len1=size(H,1)/2;
len2=size(H,2)/2;

% stop criterion
crit=1e-4;
improvement=1.0;

% initial "guess"
A0=ones(len1,len2);

% calculation loop

while improvement>crit,

  % sinc interpolation
  if 1,
  Af=fftshift(ifftn(A0));
  Af(1,:)=Af(1,:)/2;
  Af(:,1)=Af(:,1)/2;
  Af(len1+1,1:len2)=Af(1,len2:-1:1);
  Af(1:len1,len2+1)=Af(len1:-1:1,1);
  Ai=zeros(2*len1,2*len2);
  Ai(len1-len1/2+1:len1+len1/2+1,len2-len2/2+1:len2+len2/2+1)=Af;
  Ai=fftn(ifftshift(Ai));
  else
  Ai=interp2(A0,1,'nearest'); Ai(:,end+1)=Ai(:,end); Ai(end+1,:)=Ai(end,:);
  end;

  % recursion
  A1=Ai(1:len1,1:len2).*H(1:len1,1:len2)+Ai(len1+1:2*len1,1:len2).*H(len1+1:2*len1,1:len2)+Ai(1:len1,len2+1:2*len2).*H(1:len1,len2+1:2*len2)+Ai(len1+1:2*len1,len2+1:2*len2).*H(len1+1:2*len1,len2+1:2*len2);

  improvement=mean(abs(A1(:)-A0(:)));

  A0=A1;

end;

