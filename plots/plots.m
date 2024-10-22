clear all;
clc;
close all;


Stage1 = cell(10, 1);

Stage1(1:5) = {'Quality'};
Stage1(6:10) = {'Localization'};

Quality = [4, 3, 5, 5, 4];
Localization = [5, 4, 5, 5, 4];

combinedArray = horzcat(Quality, Localization);
stage1_val = combinedArray';


figure
vs1 = violinplot(stage1_val, Stage1);
ylabel('Results Stage 1');
xlim([0, 3]);
ylim([1, 5]); yticks(1:5);

%%

s = [5, 5, 5, 4, 3];
la = [4, 4, 4, 5, 4];
lo = [5, 5, 5, 4, 4];

stage2 = cell(15, 1);
stage2(1:5) = {'Stability'};
stage2(6:10) = {'Latency'};
stage2(11:15) = {'Localization'};

stage2_val = [s(:); la(:); lo(:)];

figure
vs2 = violinplot(stage2_val, stage2);
ylabel('Results Stage 2');
xlim([0, 4]);
ylim([1, 5]); yticks(1:5);

%%

stabilityData = [5, 4, 4, 5, 4];
latencyData = [4, 4, 4, 4, 3];
systemMoveData = [4, 5, 4, 3, 5];
localizationData = [4, 4, 5, 5, 4];

stage3 = cell(20, 1);
stage3(1:5) = {'Stability'};
stage3(6:10) = {'Latency'};
stage3(11:15) = {'System Move'};
stage3(16:20) = {'Localization'};

stage3Values = [stabilityData(:); latencyData(:); systemMoveData(:); localizationData(:)];

figure
violinplot(stage3Values, stage3);
ylabel('Results - Stage 3');
xlim([0, 5]);
ylim([1, 5]); yticks(1:5);


%%

overallExperienceData = [4, 5, 5, 5, 4];

finalStage = cell(5, 1);
finalStage(1:5) = {'Overall Experience'};

finalStageValues = overallExperienceData(:);

figure
violinplot(finalStageValues, finalStage);
ylabel('Results - Final Stage');
xlim([0, 2]);
ylim([1, 5]); yticks(1:5);
