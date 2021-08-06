%mdlFile='DRadiSurfTomo.inMeasure.dat';
mdlFile='DRadiSurfTomo.inMeasure.dat.iter009';
plotDep=30; % plot horizantal slice at plotDep (30) km

dep=[0,5,10,15,20,25,30,35,40,45,50,55,60,70,80,90,100];
plotDepIndex=find(dep==plotDep);
ndep=length(dep);

minlat=28.0;
maxlat=32.50;
dlat=0.5;
lat=maxlat:-dlat:minlat;
nlat=length(lat);
minlon=90.5;
maxlon=98.5;
dlon=0.5;
lon=minlon:dlon:maxlon;
nlon=length(lon);

aa=load(mdlFile);
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

%{
% plot velocity
rd=[(0:31)/31,ones(1,32)];
gn=[(0:31)/31,(31:-1:0)/31];
bl=[ones(1,32),(31:-1:0)/31];
rwb=[rd',gn',bl'];
rwb=flipud(rwb);
%imagesc(imagelon,imagelat,image); colormap(rwb); colorbar('location','eastoutside');
%}
imagesc(imagelon,imagelat,image); colormap(flipud(jet)); colorbar('location','eastoutside');
hold on;
set(gca,'ydir','normal','Fontsize',14,'pos',[0.15 0.3 0.6 0.4]);

