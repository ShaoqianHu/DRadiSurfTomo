% generate true Vsv model and initial model for checkerboard test  

depth=[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 70.0 80.0 90.0 100.0 120.0];
nLat=12;
nLon=19;
grid=2;
anorm=-0.04;

%vel=4.0;

% second horizontal interpolation
mod1d=load('mod.1d');
velTrue= zeros(nLat,nLon,length(depth));
for idepth=1:length(depth)
	velTrue(:,:,idepth)=mod1d(idepth);
end

perb=zeros(nLat,nLon);
[iy,ix]=meshgrid(round([1:nLat]/grid),round([1:nLon]/grid));
perb=(-1).^round((ix+iy));

for idepth=1:length(depth)
	VelTrue(:,:,idepth)=velTrue(:,:,idepth)+perb'*anorm*mod1d(idepth);
end

% output MOD.true.Vsv
MODtrue=fopen('MOD.true.Vsv','w');

for iz=1:length(depth)
	for iy=1:nLon
		for ix=1:nLat
			fprintf(MODtrue,'%8.3f',VelTrue(ix,iy,iz));	
		end
		fprintf(MODtrue,'\n');
	end
end
fclose(MODtrue);

% output MOD.Vsv
MODinit=fopen('MOD.Vsv','w');

for i=1:length(depth)
        fprintf(MODinit,'%6.1f',depth(i));
end
fprintf(MODinit,'\n');

for iz=1:length(depth)
	for iy=1:nLon
		for ix=1:nLat
			fprintf(MODinit,'%8.3f',mod1d(iz));	
		end
		fprintf(MODinit,'\n');
	end
end
fclose(MODinit);





