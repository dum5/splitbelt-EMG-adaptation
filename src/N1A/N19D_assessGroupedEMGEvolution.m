%% Assuming that the variables groups() exists (From N19_loadGroupedData)

%If not loaded:
if ~exist('controls','var')
    fprintf('Data not found on workspace. Loading from file...')
    load ../../data/HPF30/groupedParams_wMissingParameters.mat
    fprintf('...done!\n')
end
%% Directory to save figs
figDir='../../intfig';
dirStr=[figDir '/all/emg/'];
if ~exist(dirStr,'dir')
    mkdir(dirStr);
end
%% Aux vars:
patientFastList=strcat('P00',{'01','02','05','08','09','10','13','14','15','16'}); %Patients above .72m/s, which is the group mean. N=10. Mean speed=.88m/s. Mean FM=29.5 (vs 28.8 overall)
controlsSlowList=strcat('C00',{'01','02','04','05','06','07','09','10','12','16'}); %Controls below 1.1m/s (chosen to match pop size), N=10. Mean speed=.9495m/s
addpath(genpath('../fun/'))
if ~exist('useLateAdapBase','var')
    useLateAdapBase=false;
end
if ~exist('plotSym','var')
    plotSym=false;
end
if ~exist('removeP07Flag','var')
    removeP07Flag=false;
end
%%
figuresColorMap
cc=condColors;

%% Define groups from lists:
%Excluding outliers:
controlList=controls.removeSubs({'C0001'}).ID;
patientList=patients.removeSubs({'P0007'}).ID; 

%
groups{1}=controls.getSubGroup(controlList);
groups{2}=patients.getSubGroup(patientList);

%Remove bad strides?
%for k=1:length(groups)
%    groups{k}=groups{k}.removeBadStrides;
%end

%% Define epochs:
%baseEp=getBaseEpoch; %defines baseEp
ep=getEpochs(); %Defines other epochs

if ~useLateAdapBase
    refEp=ep(strcmp(ep.Properties.ObsNames,'Base'),:); 
else
    refEp=ep(strcmp(ep.Properties.ObsNames,'late A'),:); 
end
refEp.Properties.ObsNames{1}=['Ref: ' refEp.Properties.ObsNames{1}];

%% Get normalized parameters:
%Define parameters we care about:
mOrder={'TA', 'PER', 'SOL', 'LG', 'MG', 'BF', 'SEMB', 'SEMT', 'VM', 'VL', 'RF', 'HIP', 'ADM', 'TFL', 'GLU'};
nMusc=length(mOrder);
type='s';
labelPrefix=([strcat('f',mOrder) strcat('s',mOrder)]); %To display
labelPrefixLong= strcat(labelPrefix,['_' type]); %Actual names
normString='^Norm';
%baseEp=getBaseEpoch;

%Renaming normalized parameters, for convenience:
for k=1:length(groups)
    ll=groups{k}.adaptData{1}.data.getLabelsThatMatch(normString);
    l2=regexprep(regexprep(ll,normString,''),'_s','s');
    groups{k}=groups{k}.renameParams(ll,l2);
end
newLabelPrefix=strcat(labelPrefix,'s');

%% Compute symmetry/asymmetry terms
if plotSym==1
%     %try %This will fail if parameters were already defined
%         M=numel(l2);
%         aux=reshape(l2(M/2+1:M),(M/2)/nMusc,nMusc);
%         N=size(aux,1);
%         aux=aux([N/2+1:N,1:N/2],:); %Flipping first/second halves of stride cycle for fast leg
%         l2=[l2(1:M/2); aux(:)];
%         for k=1:length(groups)
%             for i=1:(M/2)
%                 groups{k}=groups{k}.addNewParameter(['a' l2{i}(2:end)],@(x,y) .5*(x-y),{l2{i},l2{i+M/2}},''); %Asymmetry term
%                 groups{k}=groups{k}.addNewParameter(['b' l2{i}(2:end)],@(x,y) .5*(x+y),{l2{i},l2{i+M/2}},''); %Symmetry term
%             end
%         end
%     %catch
%         %nop
%     %end
%     newLabelPrefix=regexprep(newLabelPrefix,'^s','a');
%     newLabelPrefix=regexprep(newLabelPrefix,'^f','b');
flip=2;
end

%% Plot (and get data)
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
ph=tight_subplot(length(groups),length(ep)+1,[.03 .005],.04,.04);
flip=true;
if plotSym==1
    flip=2;
end
summFlag='median';
clear dataE dataRef
for k=1:length(groups)
    groups{k}.plotCheckerboards(newLabelPrefix,refEp,fh,ph(k,1),[],flip); %First, plot reference epoch:   
    [~,~,labels,dataE{k},dataRef{k}]=groups{k}.plotCheckerboards(newLabelPrefix,ep,fh,ph(k,2:end),refEp,flip,summFlag);%Second, the rest:
end
set(ph(:,1),'CLim',[-1 1]);
set(ph(:,2:end),'YTickLabels',{},'CLim',[-1 1].*.5);
set(ph(1,:),'XTickLabels','');
set(ph(2,:),'Title',[]);
set(ph,'FontSize',8)
pos=get(ph(1,end),'Position');
axes(ph(1,end))
colorbar
set(ph(1,end),'Position',pos);
%% Do stats.plotCheckerboard
%minEffectSize2=0;
minEffectSize2=0.1;
fdr=.05;
for k=1:length(groups)
    for i=1:length(ep)+1
        if i>1
            dd=reshape(dataE{k}(:,:,i-1,:),size(dataE{k},1)*size(dataE{k},2),size(dataE{k},4));
        else
            dd=reshape(dataRef{k}(:,:,i,:),size(dataRef{k},1)*size(dataRef{k},2),size(dataRef{k},4));
        end
        [~,p2]=ttest(dd');
        for j=1:size(dd,1)
           [p2(j)]=signrank(dd(j,:),0,'method','exact');
        end
        p=p2;
        %[h,pTh,~,pAdj]=BenjaminiHochberg(p,fdr); %Conservative mult-comparisons: Benjamini & Hochberg approach
        [h,pTh,~,pAdj]=BenjaminiHochberg(p,fdr,true); %Two-stage Benjamini, Krieger, Yekuteli approach
        %Alternative, use Matlab's built-in (single-pass):
        %[pAdj]=mafdr(p,'BHFDR',true); %Matlab's built-in
        %h=pAdj<fdr;
        h(abs(median(dd,2))<minEffectSize2)=0; %not reporting small (meaningless) effects
        %Add to plot:
        subplot(ph(k,i))
        hold on
        ss=findobj(gca,'type','Surface');
        h1=nan(size(h));
        h1(h==1)=10;
        if i>1
            plot3(repmat([ss.XData(1:end-1)+diff(ss.XData)/2]',1,length(ss.YData)-1),repmat(ss.YData(1:end-1)+diff(ss.YData)/2,length(ss.XData)-1,1),reshape(h1,[length(ss.XData)-1,length(ss.YData)-1])','ko','MarkerFaceColor','k','MarkerSize',4)
            aux=num2str(round(1e3*pTh)/1000,2);
            ph(k,i).Title.String=[{ph(k,i).Title.String}; {['p=' aux(2:end)]}];
        else
            aux2=num2str(round(1e2*fdr)/1e2,2);
            aux3=num2str(round(1e2*minEffectSize2)/1e2,2);
            ph(k,i).Title.String=[{ph(k,i).Title.String}; {['FDR=' aux2 '; min Eff.=' aux3]}];
        end
    end
end

%% Save
saveName=['allChangesEMG'];
% if plotSym==1
%     saveName=[saveName 'Sym'];
% end
% if matchSpeedFlag==1
%    saveName=[saveName '_speedMatched']; 
% elseif matchSpeedFlag==2
%     saveName=[saveName '_uphill'];
% end
if removeP07Flag
    saveName=[saveName '_noP07'];
end
% if subCountFlag==1
%     saveName=[saveName '_subjCount_05pp'];
% end
if useLateAdapBase
    saveName=[saveName '_lateAdapBase'];
end
if plotSym
    saveName=[saveName '_sym'];
end
saveFig(fh,dirStr,[saveName],0);
