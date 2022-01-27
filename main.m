% clear
clc
ardPort = serialport("COM5" , 115200);
configureTerminator(ardPort, "CR/LF");
ardPort.UserData = struct('time', [], 'reference', [], 'position', [], 'command', [], 'pfRef' , [], 'counter', 1);
ardPort.flush();
pause(1);
disp("Turn the power on")
disp("press Enter to continue")
pause;
configureCallback(ardPort,"terminator", @ardCB);

%%
for i=1:2
ardPort.write(60 , "uint8");
pause(7)
ardPort.write(150, "uint8");
pause(7)
end

configureCallback(ardPort , 'off')
disp("data collection finished")
disp("Turn the power off")
data = ardPort.UserData;
clear ardPort
%%
close all
pltLength = min([min(length(data.time)),...
    min(length(data.command)),...
    min(length(data.position)),...
    min(length(data.reference)),...
    min(length(data.pfRef))]);
figure()
subplot(2 , 1 ,1)
plot(data.time(1:pltLength) , data.reference(1:pltLength), '--');
hold on 
plot(data.time(1:pltLength), data.pfRef(1:pltLength) , ':')
plot(data.time(1:pltLength) , data.position(1:pltLength));
legend ({'reference', 'preFilteredRef','position'})
subplot(2 , 1 , 2)
plot(data.time(1:pltLength) , data.command(1:pltLength))
legend command
linkaxes(findall(gcf , 'type' , 'axes') , 'x')
%%
function ardCB(src, ~)
    msg = char(readline(src));
    src.UserData.time(end+1) = typecast(uint8(msg(1:4)) , 'single');
    src.UserData.reference(end + 1) = typecast(uint8(msg(5:8)), 'single');
    src.UserData.position(end + 1) = typecast(uint8(msg(9:12)), 'single');
    src.UserData.position(end)
    src.UserData.command(end + 1) = typecast(uint8(msg(13:16)), 'single');
    src.UserData.pfRef(end+1) = typecast(uint8(msg(17:end)), 'single');
    src.UserData.counter = src.UserData.counter + 1;
    
end


