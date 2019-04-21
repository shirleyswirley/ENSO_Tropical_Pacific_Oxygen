% month fractions corresp to jan, feb, mar, etc.:
monthfracs = [0 0.0834 0.1666 0.25 0.3334 0.4166 0.5 0.5834 0.6666 0.75 0.8334 0.9166];
fnameoni = 'data/ENSOtimeseries/oniindex1950_2018.txt';
fid = fopen(fnameoni);
raw = textscan(fid,'%f%f','Delimiter',',','CommentStyle','#');
fclose(fid);
onitime = raw{1};
onibegmoidx = find(onitime==year(begdate)+monthfracs(month(begdate)));
oniendmoidx = find(onitime==year(enddate)+monthfracs(month(enddate)));
onitime = raw{1}(onibegmoidx:oniendmoidx);
oni = raw{2}(onibegmoidx:oniendmoidx);
onien = zeros(size(oni)); % 1 = el nino month
oniln = zeros(size(oni)); % 1 = la nina month
cmcounter = 0; % consecutive months counter
for imonth = 1:length(oni)
    if oni(imonth)>=0.5
        cmcounter=cmcounter+1;
    elseif oni(imonth)<0.5
        cmcounter=0;
    end
    if cmcounter>=5
       onien(imonth-cmcounter+1:imonth)=1;
    end
end
cmcounter = 0; % consecutive months counter
for imonth = 1:length(oni)
    if oni(imonth)<=-0.5
        cmcounter=cmcounter+1;
    elseif oni(imonth)>-0.5
        cmcounter=0;
    end
    if cmcounter>=5
       oniln(imonth-cmcounter+1:imonth)=1;
    end
end

clear cmcounter fid fnameoni imonth monthfracs onibegmoidx oniendmoidx raw;
