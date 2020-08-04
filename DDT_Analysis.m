
TDdata = data.TDdata; % load datamat per each subject

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


global qdat

% Run minimization to find k-value
qdat.SIR = TDdata(:,3);
qdat.LDR = TDdata(:,2);
qdat.Delay = TDdata(:,4);
qdat.Choices = TDdata(:,1);




[x, y] = fminbnd(@GenerateLogLik,0,1);
Discounting_Ratio = x;
Delay_to_plot = 0 : max(qdat.Delay);
Discount_Subj = 1./(1+Discounting_Ratio*Delay_to_plot);
% plot figure
figure
plot(Delay_to_plot,Discount_Subj,'color','k','linewidth',2)
xlabel(' Time Delay [days] ')
ylabel(' Discount Factor ')
title(' ID Subject: 3')
set(gca,'fontsize',15)
text(100,0.95,['K = ', num2str(Discounting_Ratio)],'fontsize',20)


%     DEFINE OBJECTIVE FUNCTION         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sumloglik = GenerateLogLik(cur_k)

global qdat
% Define vector that will store the probability that the model chooses
% as the participant for every choice
choiceprobabilities = zeros(length(qdat.Choices),1);
len = length(qdat.LDR);

for j = 1:len
    % load the choice probability vector for every choice
    choiceprobabilities(j) = GetPChoice(cur_k,qdat.SIR(j),qdat.LDR(j),qdat.Delay(j),qdat.Choices(j));
end

% take sum of logs and negative to be able to work within minimization
% framework
sumloglik = (-1)*(sum(log(choiceprobabilities)));
end