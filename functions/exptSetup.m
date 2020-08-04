% exptSetup
% run experiment setup scripts here, like graphics etc

function [c] = exptSetup

% if you're using randomization, it's important to seed your random number
% generator!
rng(1,'twister'); %seed rand




[c.Window, Rect] = Screen('OpenWindow',0);
c.scrsz = get(0,'ScreenSize') ;
% Set fonts
Screen('TextFont',c.Window,'Arial');
Screen('TextSize',c.Window,24);
Screen('FillRect', c.Window, [0 0 0]);  % 0 = black background
c.textColor = [255 255 255];

% Print a loading screen
DrawFormattedText(c.Window, 'Caricamento -- il compito inizierà a breve','center','center',c.textColor);
Screen('Flip',c.Window);


ListenChar(2) %Ctrl-c to enable Matlab keyboard interaction.


end