function [OUTroiframecc, OUTroixlinklist]=outROIxlinks_varstruct(toff, ton, ROIout, var)
OUTroiframecc=[]; %Used for final ROI binding event crosschecks (cc).

OUTbindtime = zeros(1,ROIout);
OUTbindframe = zeros(1,ROIout);
OUTroixlinklist = zeros(var.EXPstop,ROIout);
OUTroixlink = zeros(1,ROIout);

for frame=1:var.EXPstop
    for roi=1:ROIout
        if OUTroixlink(roi)>0 && rand()<var.xlinkrev
            OUTroixlink(roi) = OUTroixlink(roi)-1;
            OUTroixlinklist(frame, roi) = OUTroixlinklist(frame, roi)-1;
        end
        if (frame <= OUTbindframe(roi) + OUTbindtime(roi)) || (OUTroixlink(roi)>0)
            continue
        end
        if rand() < 1/toff
            OUTbindtime(roi) = ceil(exprnd(ton)); %so we dont get 0 frame bindtimes
            OUTbindframe(roi)=frame; %Record the frame at which the roi bound.
            OUTroiframecc = [OUTroiframecc frame:(frame+OUTbindtime(roi))]; %Saves list of ALL OUT roi binding frames
            
            if rand() < 1-((1-var.P_bg)^OUTbindtime(roi))
                OUTroixlink(roi)=1;
                OUTroixlinklist(frame, roi)=1;
            end
        end
    end
end

end