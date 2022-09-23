function [outlat,outlon] = trans_local2geo(local_lat,local_lon,station_lat,station_lon,height_band)

    alpha = station_lat/180*pi;
    beta = station_lon/180*pi;
    trans_matrix = [sin(alpha)*cos(beta),-sin(beta),cos(alpha)*cos(beta);...
                    sin(alpha)*sin(beta),cos(beta),cos(alpha)*sin(beta);...
                    -cos(alpha),0,sin(alpha)];
    RE=6371.2; %km
    R = (RE+height_band)/RE;
    local_x = R.*cos(local_lat./180*pi).*cos(local_lon./180*pi);
    local_y = R.*cos(local_lat./180*pi).*sin(local_lon./180*pi);
    local_z = R.*sin(local_lat./180*pi);
    outlat = zeros(size(local_lat));
    outlon = zeros(size(local_lon));
    for i=1:length(outlat(1,:))
        for j=1:length(outlat(:,1))
            trans_coord = trans_matrix*[local_x(i,j);local_y(i,j);local_z(i,j)];
            outlat(i,j) = atan(trans_coord(3)/sqrt(trans_coord(1)^2+trans_coord(2)^2))./pi*180;
            outlon(i,j) = atan2(trans_coord(2),trans_coord(1))./pi*180;
        end
    end
end

