function [lobemat]=lobe_cmp(cmpmat)

lobemat=zeros(24,24);

labelnum=zeros(1,83);
labelnum(1:14)=1;   labelnum(15:20)=2;  labelnum(21:24)=3;  labelnum(25:33)=4;
labelnum(34:41)=[5:1:12];
labelnum(42:55)=13; labelnum(56:61)=14; labelnum(62:65)=15; labelnum(66:74)=16;
labelnum(75:83)=[17:1:25];
% 1: RF
% 2: RP
% 3: RO
% 4: RT
% 5: R insula, 
% 6: Right-Thalamus-Proper
% 7: Right-Caudate        
% 8: Right-Putamen        
% 9: Right-Pallidum       
% 10:Right-Accumbens-area 
% 11:Right-Hippocampus    
% 12:Right-Amygdala 
% 13: LF
% 14: LP
% 15: LO
% 16: LT
% 17: L insula
% 18: Left-Thalamus-Proper
% 19: Left-Caudate        
% 20: Left-Putamen        
% 21: Left-Pallidum       
% 22: Left-Accumbens-area 
% 23: Left-Hippocampus    
% 24: Left-Amygdala       

% Between area
for i=1:24
    for j=1:24
        tmp=cmpmat(labelnum==i,labelnum==j);
        lobemat(i,j)=sum(sum(tmp));
    end;
end;

% Within area
for i=1:24
    tmp=cmpmat(labelnum==i,labelnum==i);
    lobemat(i,i)=sum(sum(tmp))-(sum(sum(tmp))-sum(diag(tmp)))/2;
end;