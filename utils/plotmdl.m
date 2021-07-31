plotDep=30; % plot horizantal slice at plotDep (30) km

dep=[0,5,10,15,20,25,30,35,40,45,50,55,60,70,80,90,100];
plotDepIndex=find(dep==plotDep);
ndep=length(dep);

minlat=21.25;
maxlat=32.50;
dlat=0.25;
lat=maxlat:-dlat:minlat;
nlat=length(lat);
minlon=98.00;
maxlon=105.75;
dlon=0.25;
lon=minlon:dlon:maxlon;
nlon=length(lon);

aa=load('SETPcrust.dat');
mdl=zeros(nlat,nlon,ndep);

% read the velocity model
i=1;
for idep=1:ndep
	for ilon=1:nlon
		for ilat=1:nlat
			mdl(ilat,ilon,idep)=aa(i,4);
			i=i+1;
		end
	end
end

% smooth the velocity model
dlat=dlat/5;
dlon=dlat/5;
imagelat=maxlat:-dlat:minlat;
imagelon=minlon:dlon:maxlon;
[xin,yin]=meshgrid(lon,lat);
[xout,yout]=meshgrid(imagelon,imagelat);
image=griddata(xin,yin,squeeze(mdl(:,:,plotDepIndex)),xout,yout,'cubic');

% plot velocity
rd=[(0:31)/31,ones(1,32)];
gn=[(0:31)/31,(31:-1:0)/31];
bl=[ones(1,32),(31:-1:0)/31];
rwb=[rd',gn',bl'];
rwb=flipud(rwb);
imagesc(imagelon,imagelat,image); colormap(rwb); colorbar('location','eastoutside');
hold on;
set(gca,'ydir','normal','Fontsize',14,'pos',[0.28 0.1 0.35 0.8]);

% plot fault
fp=fopen('fault.dat','r');
il=0;
while 1
	line=fgetl(fp);
	if ~ischar(line)
		break;
	else
		if(line(1)=='>')
			%fprintf('%s\n',line);
			il=il+1;
			if il > 1
				plot(ft(1,:),ft(2,:),'k','LineWidth',1.2);
				hold on;
			end
			ft=[];
		else
			dum=str2num(line);
			loc=[dum(1);dum(2)];
			ft=[ft,loc];
		end
	end
end
fclose(fp);

% plot seismicity
% 1. plot catalog_3d_19802012.txt
fseis=fopen('catalog_3d_19802012.txt','r');
seis=[];
while 1
	line=fgetl(fp);
	if ~ischar(line)
		break;
	else
		dum=str2num(line);
		if length(dum)<17
			continue;
		else
			seisLat=dum(7);
			seisLon=dum(8);
			seisDep=dum(9);
			seisMag=dum(10);
			if abs(seisDep-plotDep)<=5 && seisMag>4.0
				loc=[seisLon;seisLat];
				seis=[seis,loc];
			end
		end
	end

end
plot(seis(1,:),seis(2,:),'og','MarkerSize',8);
hold on;
fclose(fseis);

% 2. plot catalog_cenc_20132016.txt
fseis=fopen('catalog_cenc_20132016.txt','r');
seis=[];
while 1
	line=fgetl(fp);
	if ~ischar(line)
		break;
	else
		dum=str2num(line);
		if length(dum)<10
			continue;
		else
			seisLat=dum(7);
			seisLon=dum(8);
			seisDep=dum(9);
			seisMag=dum(10);
			if abs(seisDep-plotDep)<=5 && seisMag>4.0
				loc=[seisLon;seisLat];
				seis=[seis,loc];
			end
		end
	end

end
plot(seis(1,:),seis(2,:),'og','MarkerSize',8);
fclose(fseis);






