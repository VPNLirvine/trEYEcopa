function MakePRT_Loc(TrialOrder, filename, CondNames, ExptName, TR)
    %% Make PRT FILE %%

    % 9/16/10: Wrote it. (JP)
    % 8/28/18: Revised. (EG)
    % 7/28/21 Revised (EG)
    
    CondColor(1).color = [255 0 0]; %red
    CondColor(2).color = [0 255 0]; %green
    CondColor(3).color = [0 0 255]; %blue
    CondColor(4).color = [255 255 0]; %yellow
    CondColor(5).color = [255 0 255]; %purple
    CondColor(6).color = [0 255 255]; %teal
    CondColor(7).color = [255 128 128]; %pink
    CondColor(8).color = [128 128 0]; %olive
    CondColor(9).color = [0 128 128]; %cyan
        

    %% Create prt File
    prt = BVQXfile('new:prt');
    prt.Experiment = ExptName;
    prt.ResolutionOfTime = 'msec'; % should keep 'msec' for tricopa
    prt.TimeCourseThick = 3;
    prt.TimeCourseColor = [255 255 255];


    %% Find TRs For Conditions
    NumConds = length(CondNames);
    for i = 1:NumConds

        [TRindex junk]  = find(TrialOrder(:,3)==i);
        TRsforCond = TrialOrder(TRindex, 1:2);
        prt.AddCond(CondNames{i}, TRsforCond, CondColor(i).color);

    end


    prt.SaveAs(filename);
