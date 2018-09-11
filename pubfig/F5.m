%%
fh=openfig('../intfig/intersubj/fig/AgeSpeedEffects_controls.fig');
addpath(genpath('./auxFun/'))
figSize
%%
f1=figure('Units',figUnits,'OuterPosition',figPos);
ph=findobj(fh,'Type','Axes');
pa=copyobj(ph([7:10,6]),f1);
mapI=[1,2,3,1,2]; %Alignment along x-axis
mapJ=[2,1,1,1,2]; %y-axis
for k=1:5
%for i=1:2
%    for j=1:2
i=mapI(k);
j=mapJ(k);
        p=pa(k);
        axes(p)
        ss=findobj(p,'Type','scatter');
        %ll=legend(ss);
        %drawnow
        %pause(1)
        %ll.FontSize=10;
        p.Position=[.07+.3*(i-1)+.15*(j>1) .1+.5*((2-j)) .22 .35];
        p.FontSize=14;
        drawnow
        ll2=findobj(gca,'Type','Scatter');
        try
             nn=get(ll2,'DisplayName');
                cc=cell2mat(get(ll2,'CData'));
                aa=cell2mat(get(ll2,'MarkerFaceAlpha'));
                cc=(cc.*aa +(1-aa));
                if k==4
                    nn{1}=['\beta_M ' nn{1}(5:end)];
                nn{2}=['\beta_S ' nn{2}(4:end)];
                end
                for ii=1:size(cc,1)
                    nn{ii} = sprintf('\\color[rgb]{%f, %f, %f}%s', cc(ii,:), nn{ii});
                end
        catch
             nn=get(ll2,'DisplayName');
                cc=(get(ll2,'CData'));
                aa=(get(ll2,'MarkerFaceAlpha')); 
                cc=(cc.*aa +(1-aa)); 
                nn = sprintf('\\color[rgb]{%f, %f, %f}%s', cc, nn);
        end
        nn=regexprep(nn,'r=','r= ');
        switch k
            case 1 %SLA aftereffects
                axis([45 80 0 .35])
                text(60,.27,nn([1:41,50:end]),'FontSize',13,'FontWeight','bold','FontName','Open Sans')
                set(gca,'YTick',[0:.1:.3])
                p.YLabel.String={'Step-length';'asymmetry'};
            case 2 %Feedback
                axis([45 80 2 14.8])
                text(54,13,nn,'FontSize',11,'FontWeight','bold','FontName','Open Sans')
                p.Title.String='Feedback responses';
                p.YLabel.String='Magnitude (a.u.)';
            case 3 %Late adapt
                axis([45 80 2 9])
                text(50,7,nn([1:41,52:end]),'FontSize',13,'FontWeight','bold','FontName','Open Sans')
                p.Title.String='Late Adaptation modulation';
                set(gca,'YTick',3:4:15)
                p.YLabel.String='Magnitude (a.u.)';
            case 4 %Regressors
                axis([45 80 -.4 .8])
                ll2=findobj(gca,'Type','Scatter');
                set(gca,'YTick',[-.4:.4:.8])
                text(60,.68,nn{1},'FontSize',13,'FontWeight','bold','FontName','Open Sans')
                text(60,-.3,nn{2},'FontSize',13,'FontWeight','bold','FontName','Open Sans')
                 %Add panel letters:
                text(37,.9,'A','FontWeight','Bold','FontSize',20)
                text(85,.9,'B','FontWeight','Bold','FontSize',20)
                text(133.5,.9,'C','FontWeight','Bold','FontSize',20)
                text(110,-.85,'E','FontWeight','Bold','FontSize',20)
                text(61,-.85,'D','FontWeight','Bold','FontSize',20)
                ax=gca; ax.YLabel.String='Coefficients';
               
                p.Title.String='Regression model';
            case 5 %EMG aftereffects
                axis([45 80 2 14])
                text(59,12,nn([1:41,52:end]),'FontSize',13,'FontWeight','bold','FontName','Open Sans')
                set(gca,'YTick',[0:5:15])
                p.YLabel.String='Magnitude (a.u.)';
        end
        ax=gca;
        ax.YLabel.Position(1)=ax.YLabel.Position(1)-1;
        ax.FontName='Helvetica';
        ax.Title.String=upper(ax.Title.String);
         %p.YLabel.FontWeight='bold';
         %p.XLabel.FontWeight='bold';
end
%%
set(findobj(f1,'Type','Axes'),'FontName','Helvetica')
saveFig(f1,'./','Fig5',0)