clear
%% Parameters to Vary
%ROI arrangement (try to keep it in integers please)
ROIin = 3;
ROIout = 3;

ton  = 10;
toff = 500; %Frames

var.Pxlink = .18; %This is the per frame efficiency (3 in total should equal ~.45)
var.Pxlinkf = 1-var.Pxlink; %used to calculate consecutive frame efficiency 1-(Pxlinkf^bindtime)
var.P_bg = .012;

var.EXPstop = 5000;
var.ROIblinkstop = 3;
var.apExp=2000;

var.monitorStop = 2000;

var.xlinkrev = 0;
var.xlink405rev = 0;

INROIfinal = [];
OUTROIfinal = [];
expDel=[];
%%
for zexp=1:var.apExp
    %% Pre Populate all OUT binding events first
    OUTroixlinks = zeros(1,ROIout);
    [OUTroiframecc, OUTroixlinklist]=outROIxlinks_varstruct(toff, ton, ROIout, var);
    
    %% Simulate IN binding
    [INroixlinks, frame, zinddel, INroiframe, INbindtime, INroibinds, INbindtimetot]=inROIxlinks_timemon(toff, ton, ROIin, zexp, OUTroiframecc, var);
    expDel=[expDel zinddel]; %If Exp reaches autostop, index for deletions
    
    %% Truncate OUTroixlinks to match frame
    LastIN = find( max(INroiframe(:)+INbindtime(:)) == INroiframe(:)+INbindtime(:));
    if all(INroiframe(:)+INbindtime(:)+var.monitorStop<=var.EXPstop)
        OUTroixlinklist=OUTroixlinklist( 1:(INroiframe(LastIN)+INbindtime(LastIN)+var.monitorStop-1) , :);
    end
    
    for i=1:ROIout
        OUTroixlinks(i)=sum(OUTroixlinklist(:,i));
    end
    
    INROIfinal = vertcat(INROIfinal, INroixlinks);
    OUTROIfinal = vertcat(OUTROIfinal, OUTroixlinks);
end

%%
% apExp = apExp - numel(expDel);
INROIfinal(expDel,:)=[];
OUTROIfinal(expDel,:)=[];

allsuc=zeros(numel(INROIfinal(:,1)),1);
alloutsuc=zeros(numel(INROIfinal(:,1)),1);

for i=1:numel(INROIfinal(:,1))
    if all(INROIfinal(i,:)>0)
        allsuc(i,1)=1;
    end
    if all(OUTROIfinal(i,:)==0)
        alloutsuc(i,1)=1;
    end
end

[ONperc]=calcResults(allsuc, alloutsuc,var.apExp)
disp(['alloutsuc ' num2str(numel(nonzeros(alloutsuc)))]);
disp(['allsuc ' num2str(numel(nonzeros(allsuc)))]);
%%
function [ONperc]=calcResults(allsuc, alloutsuc, apExp)
allon = find(allsuc==1);
alloff = find(alloutsuc==1);
ONperc = numel(intersect(allon,alloff))/apExp;
end
