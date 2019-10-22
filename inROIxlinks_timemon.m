function [INroixlinks, frame, inddel, INroiframe, INbindtime, INroibinds, INbindtimetot]=inROIxlinks_timemon(toff, ton, ROIin, zexp, OUTroiframecc, var)
INbindtime=zeros(1,ROIin);
INbindtimetot = zeros(1,ROIin);
INroiframe= zeros(1,ROIin);
INroixlinks = zeros(1,ROIin);
INroibinds = zeros(1,ROIin);
inddel=[];
for frame=1:var.EXPstop
    
    if all(INbindtimetot>=2) && (frame > max(INroiframe)+var.monitorStop)
        break
    elseif frame==var.EXPstop
        inddel=zexp;
        break
    end
    
    for roi=1:ROIin
        if INroixlinks(roi)>0 && rand()<var.xlinkrev
            INroixlinks(roi) = INroixlinks(roi)-1;
        end
        % Skip the ROI binding calculation if ROI is still bound to a
        % strand
        if (frame <= INroiframe(roi) + INbindtime(roi)) || (INroixlinks(roi)>0)
            continue
        end
        if rand() < 1/toff
            INbindtime(roi) = ceil(exprnd(ton)); %so we dont get 0 frame bindtimes
            INbindtimetot(roi) = INbindtimetot(roi) + INbindtime(roi);
            INroibinds(roi) = INroibinds(roi)+1;
            INroiframe(roi) = frame; %Record the frame at which the roi bound.
            
            INroiframecc = frame:(frame+INbindtime(roi)-1); %INroiframe crosscheck %subtract one from bindtime for indexing correction
            INroiframecc = INroiframecc(INroiframecc<=var.EXPstop); %In case the binding goes really long
            
            INOUTcc = ~ismember(INroiframecc,OUTroiframecc); %Non-membership check will give all 1's if
            bindtime_update = numel(nonzeros(INOUTcc));
            INbindtime(roi) = bindtime_update;
            
            if rand() < 1-(var.Pxlinkf^(bindtime_update-1)) %Due to the 1 frame camera delay, the exposure time is -1.
                INroixlinks(roi) = INroixlinks(roi)+1;
            end
            
            for i=1:ROIin
                if i==roi
                    continue
                end
                if rand() < var.xlink405rev
                    INroixlinks(i)=0;
                end
            end
        end
        
    end
end
end