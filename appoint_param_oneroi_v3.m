clear
Onoff=zeros(41,101);
%%
x=linspace(0, 20, numel(Onoff(:,1)));
y=linspace(0, 2000, numel(Onoff(2,:)));
%%
InROI = 3;
OutROI = 3;
%%
var.Pxlink = .18; %This is the per frame efficiency (3 in total should equal ~.45)
var.Pxlinkf = 1-var.Pxlink; %used to calculate consecutive frame efficiency 1-(Pxlinkf^bindtime)
var.P_bg = .012;

var.EXPstop = 10000;
var.ROIblinkstop = 3;
var.apExp=4000;

var.monitorStop = 2000;

var.xlinkrev = 0;
var.xlink405rev = 0;

%%
parfor i=1:numel(x)
    
    ton=x(i);
    offcol=zeros(1,numel(y));
    for j=1:numel(y)
        toff = y(j);
        [ONperc]=apPointsim_v4_bindtimemon(InROI, OutROI, ton, toff, var);
        offcol(1,j)=ONperc;
        disp(toff)
    end
    Onoff(i,:)=offcol;
    disp(ton)
end
%%
expstopstr=num2str(var.EXPstop);
xlinkrevstr = num2str(var.xlinkrev);
uvrevstr = num2str(var.xlink405rev);
save(['onoff_' num2str(InROI) '_xlinkrev_' xlinkrevstr '_405rev' uvrevstr '_cutoff' expstopstr '.mat']);

