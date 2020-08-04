% #####################################################
% DDT implemented by M.Vissani @2018
%
% This script based on Psychootolbox implements the original
% DDT in Kirby 1999.
% ######################################################
%

clear;
clc;

PsychJavaTrouble
pwd
path.main = pwd;
Screen('Preference', 'SkipSyncTests', 1); % important for Mac
rng(1,'twister'); % rand seed


exptname = 'ExpDDT';

[pathstr,curr_dir,ext] = fileparts(pwd);
if ~strcmp(curr_dir,'DDT')
    error('You must start the experiment from the DDT directory. Go there and try again.\n');
end

% define and add standard paths 
path.data = fullfile(path.main, 'data');
path.diaries = fullfile(path.main, 'diaries');
path.functions = fullfile(path.main,'functions');
addpath(path.data)
addpath(path.diaries)
addpath(path.functions)


% start the experiment!
fprintf('Welcome!\n');
subjNo = input('Subjecy ID?: ');

% check for existing file for that subject
cd(path.data);
    savename = [exptname num2str(subjNo) '.mat'];
if (exist(savename,'file'))>0
   cd(path.main)
   
   sca
   
end

% set up diary
diarySetup(path.diaries, [exptname num2str(subjNo)])

% %%%% run main tasks %%%% %
data = [];
c = exptSetup;
c.path = path;
% add session specific data
c.subjNo = subjNo;
c.exptname = exptname;
try
    [g, TDdata] = temporalDiscounting(c);
    ListenChar(1);
    Screen('CloseAll');
catch ERR
    Screen('CloseAll');
    rethrow( ERR );
end

% save data
data.g = g;
data.TDdata = TDdata;
cd(path.data)
savename = [exptname num2str(subjNo) '_order.mat'];
save(savename, 'data');

figure
subplot(121)
yes_delayed = TDdata(:,1);
ratio_now_delayed = TDdata(:,3)./TDdata(:,2);
delay = TDdata(:,4);
idx_yes_delayed = yes_delayed == 1;
idx_no_delayed = yes_delayed == 0;
scatter(delay(idx_yes_delayed),ratio_now_delayed(idx_yes_delayed),30,'ok','filled','linewidth',1.5)
hold on
scatter(delay(idx_no_delayed),ratio_now_delayed(idx_no_delayed),30,'ok','linewidth',1.5)
xlabel(' Delay [days] ')
ylabel('$\displaystyle\frac{SIR}{LDR}$ [a.u.]','interpreter','latex')
legend({' Choose delayed ',' Choose immediate '})
title(' Would you prefer SIR or LDR in delay days?')
subplot(122)
prop_yes_delayed = sum(idx_yes_delayed)/numel(yes_delayed);
prop_no_delayed = sum(idx_no_delayed)/numel(yes_delayed);
bar([prop_yes_delayed, prop_no_delayed],'linewidth',1.5,'Edgecolor','k');
xticks(1:2)
xticklabels({'Choose delay','Choose immediate'})
xlabel(' Choice ')
ylabel(' Proportion of Choice ')
title(' Choice Proportion ')