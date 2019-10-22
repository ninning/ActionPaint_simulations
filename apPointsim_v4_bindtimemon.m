function [ONperc]=apPointsim_v4_bindtimemon(ROIin, ROIout, ton, toff, var)

INROIfinal = [];
OUTROIfinal = [];
expDel=[];

for zexp=1:var.apExp
    %% Pre Populate all OUT binding events first
    OUTroixlinks = zeros(1,ROIout);
    [OUTroiframecc, OUTroixlinklist]=outROIxlinks_varstruct(toff, ton, ROIout, var);
    
    %% Simulate IN binding
    [INroixlinks, frame, zinddel, INroiframe, INbindtime, ~, ~]=inROIxlinks_timemon(toff, ton, ROIin, zexp, OUTroiframecc, var);
    expDel=[expDel zinddel];
    
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

[ONperc]=calcResults(allsuc, alloutsuc, var.apExp);
%%
    function [ONperc]=calcResults(allsuc, alloutsuc, apExp)
        allon = find(allsuc==1);
        alloff = find(alloutsuc==1);
        ONperc = numel(intersect(allon,alloff))/apExp;
    end
end