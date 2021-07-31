% model file
filename='MOD.Vsv';

fid=fopen(filename,'r');
sdep=fgetl(fid);
dep=str2num(sdep);
nz=length(dep);

nx=12;
ny=19;
nz=18;

% goxd and gozd
ox=32.5;
oy=90.5;
dx=0.5;
dy=0.5;

xx=ox:-dx:ox-(nx-1)*dx;
yy=oy:dy:oy+(ny-1)*dy;

% which depth to plot
pltz=40;

%
velin=[];
for i=1:ny*nz
	line=fgetl(fid);
	tmp=str2num(line);
	velin=[velin;tmp];
end
vel=zeros(nx,ny,nz);

for k=1:nz
	for j=1:ny
		for i=1:nx
			vel(i,j,k)=velin((k-1)*nx+j,i);
		end
	end
end

iz=find(dep==pltz);
contourf(yy,xx,squeeze(vel(:,:,iz)));
colormap(flipud(jet));
colorbar;

fclose(fid);
