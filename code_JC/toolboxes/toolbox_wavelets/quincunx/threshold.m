function Q2=threshold(Q,J,factor);

x2=size(Q,1);
y2=size(Q,2);

x1=1;
y1=y2/2+1;

Q2=zeros(size(Q));

for iter=1:J,
  tmp=Q(x1:x2,y1:y2);

  thr=factor*std(tmp(:));
  %thr=thr*thselect(tmp(:),'sqtwolog');

  tmp(find(abs(tmp)<thr))=0; % thresholding
  if 1, % soft version
    tmp(find(tmp>0))=tmp(find(tmp>0))-thr;
    tmp(find(tmp<0))=tmp(find(tmp<0))+thr;
  end;

  Q2(x1:x2,y1:y2)=tmp;

  if mod(iter,2)==1,
    y2=y1-1;
    y1=1;
    x1=x2/2+1;
  else
    x2=x1-1;
    x1=1;
    y1=y2/2+1;
  end;

end;

y1=1;
Q2(x1:x2,y1:y2)=Q(x1:x2,y1:y2);

