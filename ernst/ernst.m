T1=input('Please input the T1 of the tissue in seconds: ');
selectedTR=input('Please input the TR of the experiment in seconds: ');
TR=0:0.01:4;
alpha = 180*acos(exp(-TR/T1))/pi;
alphaP10 = 180*acos(exp(-TR/(T1*1.1)))/pi;
alphaM10 = 180*acos(exp(-TR/(T1*0.9)))/pi;
figure;
plot(TR, alpha, 'LineWidth', 2)
hold on
plot(TR, alphaP10, ':r')
plot(TR, alphaM10, ':r')
grid on
text(1.75, 5, ['Ernst Angle at a TR of ' num2str(selectedTR) 's = ' sprintf('%2.1f', (alpha(selectedTR*100+1))) '°'], ...
      'FontSize', 12)
xlabel('TR (s)', 'FontSize', 12)
ylabel('Ernst Angle (°)', 'FontSize', 12)
title(['Ernst Angle for T_1 = ' num2str(T1) 's ±10% vs. TR'], 'FontSize', 14)
msgbox(['Ernst Angle = ' num2str(alpha(selectedTR*100+1)) '°']);