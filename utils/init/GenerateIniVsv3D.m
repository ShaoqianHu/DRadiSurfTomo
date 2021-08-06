% generate intial model MOD.gam for DRadiSurfTomo

depth=[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 70.0 80.0 90.0 100.0 120.0];
nLat=12;
nLon=19;

% load 1D model
xxx=load('mod.1d');
mod1d=xxx;

% second horizontal interpolation
vsv= zeros(nLat,nLon,length(depth));
for idepth=1:length(depth)
	vsv(:,:,idepth)=mod1d(idepth);
end

% write to MOD.true file
MOD=fopen('MOD.Vsv','w');
for i=1:length(depth)
        fprintf(MOD,'%6.1f',depth(i));
end
fprintf(MOD,'\n');


for iz=1:length(depth)
	for iy=1:nLon
		for ix=1:nLat
			fprintf(MOD,'%8.4f',vsv(ix,iy,iz));	
		end
		fprintf(MOD,'\n');
	end
end
fclose(MOD);







