close all
figure
Ts= 0.001;
time = command.time;
inp = -command.signals.values;
pos = reshape(position.signals.values , [length(time) , 1]);

%%

inpHighStart = find(inp ,1,  'first');
inpHighstop = find(inp , 1 , 'last');
inds2Plot = (inpHighStart-500:inpHighstop);
sysIDIn = inp(inds2Plot);
sysIDOut = pos(inds2Plot);
sysIDData = iddata(sysIDOut, sysIDIn, Ts);
estimatedTF = tfest(sysIDData , 2,0);
% yyaxis left
% lsim(estimatedTF ,inp , linspace(time(1) , time(end) , length(time))); 
step(255*estimatedTF , time(inpHighstop) - time(inpHighStart)) 
hold on
plot(time(inds2Plot) - time(inpHighStart), inp(inds2Plot))
hold on
plot(time(inds2Plot) - time(inpHighStart), pos(inds2Plot) - pos(inpHighStart-500))
hold on
linkaxes(findall(gcf,'type' , 'axes') , 'x')