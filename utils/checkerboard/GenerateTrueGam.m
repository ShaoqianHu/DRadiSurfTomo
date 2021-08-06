% generate true and initial models for checkerboard test  

depth=[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 70.0 80.0 90.0 100.0 120.0];
nLat=12;
nLon=19;
grid=2;
anorm=0.06;
gam=1.0;

anormP=(2+anorm)/(2-anorm);
anormN=(2-anorm)/(2+anorm);

% second horizontal interpolation
gamTrue= zeros(nLat,nLon,length(depth));
for idepth=1:length(depth)
	gamTrue(:,:,idepth)=gam;
end

perb=zeros(nLat,nLon);
[iy,ix]=meshgrid(round([1:nLat]/grid),round([1:nLon]/grid));
perb=(-1).^round((ix+iy));

for i=1:nLon
	for j=1:nLat
		if perb(i,j)>0
			perb(i,j)=anormP;
		else
			perb(i,j)=anormN;
		end
	end
end
for idepth=1:length(depth)
	gamTrue(:,:,idepth)=perb';
end

% output MOD.true.gam 
MODtrue=fopen('MOD.true.gam','w');

for iz=1:length(depth)
	for iy=1:nLon
		for ix=1:nLat
			fprintf(MODtrue,'%8.4f',gamTrue(ix,iy,iz));	
		end
		fprintf(MODtrue,'\n');
	end
end
fclose(MODtrue);

% output MOD.gam
MODinit=fopen('MOD.gam','w');

for i=1:length(depth)
        fprintf(MODinit,'%6.1f',depth(i));
end
fprintf(MODinit,'\n');

for iz=1:length(depth)
        for iy=1:nLon
                for ix=1:nLat
                        fprintf(MODinit,'%8.3f',gam);                   
                end
                fprintf(MODinit,'\n');
        end
end
fclose(MODinit);





