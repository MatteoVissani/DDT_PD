function [g, datamat] = temporalDiscounting(c)

csvfile = [c.exptname num2str(c.subjNo) '_TD.csv'];
csvrow= {'Response','LDR','SIR','Delay','Key','RT','index'};
IterativeCSVWriter(c.path.data, csvfile, csvrow);
% override exptSetup here
Screen('TextSize',c.Window,round(c.scrsz(3)/50));

% some constants for storing data
xx.choseLateCol = 1;
xx.lateCol = 2;
xx.soonCol = 3;
xx.delayCol = 4;
xx.keyCol=5;
xx.RTCol=6;
xx.idxCol=7;

% additional graphics stuff
c.hPosR = 3*c.scrsz(3)/5;
c.hPosL = c.scrsz(3)/7;
c.hPosition = c.scrsz(3);
c.vPosition = c.scrsz(4);
c.instr_X = c.scrsz(3)/10;


% choices


delayMatrix=[19	20	200
    10	11	189
    18  20  197
    11	12	147
    9	10	145
    14	15	83
    6	7	163
    5	6	180
    11	12	55
    6	8	169
    4	5	124
    4	6	200
    10	12	81
    5	6	73
    4	5	77
    9	12	76
    4	5	48
    8	11	56
    6	12	136
    7	10	27
    10	15	27
    4	7	26
    6	14	36
    8	15	18
    5	10	19
    2	5	17
    5	12	13
    3	7	12
    3	6	6
    6	14	6
    2	8	13
    4	10	6];

choiceArr = 1:size(delayMatrix,1);
orderedChoiceArr = Shuffle(choiceArr);


ListenChar(2) %Ctrl-c to enable Matlab keyboard interaction.
HideCursor; % Remember to type ShowCursor or sca later


%% the study::

% Instructions
DrawFormattedText(c.Window,'Istruzioni','center',35,c.textColor);
DrawFormattedText(c.Window, ['In questo esperimento, ti sarà chiesto di indicare la tua preferenza tra due somme di denaro disponibili con diversi ritardi di pagamento. \n\n'...
    'Per favore considera ogni scelta come se fosse una condizione reale. Tieni in mente che solo una scelta sarà considerata. \n\n'...
    'Cerca di rispondere il più velocemente possibile e segui il tuo istinto. \n\n'...
    'Premi ''3'' per iniziare.'],'center','center',c.textColor,100, [],[],2);
Screen('Flip',c.Window);
GetKeyFixed('3#',[],[],-3);

fprintf('\n\nTemporal Discounting: \n\n')
fprintf('Start time: %s\n\n', datestr(clock))

datamat=[]; %where stuff is actually recorded
Screen('TextSize',c.Window,40);


%% TASK PROPER

for m = 1:size(delayMatrix,1)
    idx = orderedChoiceArr(m);

    DrawFormattedText(c.Window, '+','center','center',c.textColor,100);
    Screen('Flip',c.Window);
    WaitSecs(2);
    % present delay choice
    nSoon = delayMatrix(idx,1);
    nLate = delayMatrix(idx,2);
    delay = delayMatrix(idx,3);
    [data, testTrials]=temporalTrials(c, nSoon, nLate, delay, xx);
    
    
    % record info for trial
    datamat(m,xx.choseLateCol)=data(xx.choseLateCol);
    datamat(m,xx.lateCol)=data(xx.lateCol);
    datamat(m,xx.soonCol)=data(xx.soonCol);
    datamat(m,xx.delayCol)=data(xx.delayCol);
    datamat(m,xx.keyCol)=testTrials.key(1);
    datamat(m,xx.RTCol)=testTrials.RT;
    datamat(m,xx.idxCol)=idx;
    
    % save per trial
    fprintf('%g %g %g %g %g %g %g\n',datamat(m,:));
    csvrow= {datamat(m,1), datamat(m,2),datamat(m,3), datamat(m,4), datamat(m,5), datamat(m,6), datamat(m,7) };
    IterativeCSVWriter(c.path.data, csvfile, csvrow);

end



% unshuffle choices
choices = repmat(2,length(orderedChoiceArr),1);
for i = 1:length(orderedChoiceArr)
   choices(orderedChoiceArr(i)) =  datamat(i,xx.choseLateCol);
end



DrawFormattedText(c.Window, ['Fine!'],'center','center',c.textColor,100, [],[],2);
Screen('Flip',c.Window);
KbWait([], 2);

% calculate k
g =  TD_baseline_parse(choices);

fprintf('choices: ')
fprintf('%g ', choices)

cd(c.path.data)
savename = [c.exptname num2str(c.subjNo) '_TD.mat'];
save(savename, 'datamat');
cd(c.path.main)
end


%DEBUG
function [data, testTrials] = temporalTrials(c, nSoon, nLate, delay, xx)

data = []; % temp placeholder for this subfunction, will be transferred to datamat

%randomize which side they see the late vs soon rewards - CHECK!!

sidePres = randi(2);

if sidePres==1
    hSideS=c.hPosL;
    hSideL=c.hPosR;
else
    hSideS=c.hPosR;
    hSideL=c.hPosL;
end

% record delay + values

data(xx.lateCol)=nLate;
data(xx.soonCol)=nSoon;
data(xx.delayCol)=delay;

fprintf('\n Soon: $%g \nLate: $%g \nDelay: $%g \n', nSoon, nLate, delay)


% draw
fprintf('%g Euro in %g giorni vs %g Euro ora\n',nLate, delay, nSoon)
Screen('DrawText', c.Window, [num2str(nLate,'%#4.2f') ' Euro in ' num2str(delay) ' giorni'], hSideL, c.vPosition/3, c.textColor);
Screen('DrawText', c.Window, [num2str(nSoon,'%#4.2f') ' Euro ora'], hSideS, c.vPosition/3, c.textColor);
Screen('DrawText', c.Window, 'Premi ''1'' per scegliere la proposta a sinistra, ''4'' per quella a destra.', c.instr_X ,2*c.vPosition/3, c.textColor);
Screen('Flip',c.Window);
% Now collect a keypress from the user.
[testTrials.key testTrials.RT] = GetKeyFixed({'1!','4$'},[],[],-3);
% testTrials.key = testTrials.key(1);
fprintf('RT: testTrials.RT\n')


% record choice -- AND UPDATE K range HERE!!
if any(testTrials.key=='1!') && sidePres==2  || any(testTrials.key=='4$') && sidePres==1 
    data(xx.choseLateCol)=1;
    fprintf('chose later option\n\n')
    
elseif any(testTrials.key=='1!') && sidePres==1 || any(testTrials.key=='4$') && sidePres==2
    data(xx.choseLateCol)=0;
    fprintf('chose immediate option\n\n')
end
end
