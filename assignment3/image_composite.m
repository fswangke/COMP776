function mosaic = image_composite(im1, im2, H)
box1 = [ 1 1 1;
    size(im1,2) 1 1;
    size(im1,2) size(im1,1) 1;
    1 size(im1,1) 1];
box1_ = box1 * (H);
box1_(:,1) = box1_(:,1) ./ box1_(:,3) ;
box1_(:,2) = box1_(:,2) ./ box1_(:,3) ;
ur = min([1 box1_(:,1)']):max([size(im2,2) box1_(:,1)']) ;
vr = min([1 box1_(:,2)']):max([size(im2,1) box1_(:,2)']) ;

[u,v] = meshgrid(ur,vr) ;
H = inv(H);
z_ = H(1,3) * u + H(2,3) * v + H(3,3) ;
u_ = (H(1,1) * u + H(2,1) * v + H(3,1)) ./ z_ ;
v_ = (H(1,2) * u + H(2,2) * v + H(3,2)) ./ z_ ;
if size(im1,3) > 1
    im1_r = interp2(im2double(im1(:,:,1)),u_,v_,'cubic');
    im1_g = interp2(im2double(im1(:,:,2)),u_,v_,'cubic');
    im1_b = interp2(im2double(im1(:,:,3)),u_,v_,'cubic');
    im2_r = interp2(im2double(im2(:,:,1)),u,v,'cubic');
    im2_g = interp2(im2double(im2(:,:,2)),u,v,'cubic');
    im2_b = interp2(im2double(im2(:,:,3)),u,v,'cubic');
    im1_ = cat(3, im1_r, im1_g, im1_b);
    im2_ = cat(3, im2_r, im2_g, im2_b);
else
    im1_ = interp2(im2double(im1),u_,v_,'cubic') ;
    im2_ = interp2(im2double(im2),u,v,'cubic') ;
end
mass = ~isnan(im1_) + ~isnan(im2_) ;
im1_(isnan(im1_)) = 0 ;
im2_(isnan(im2_)) = 0 ;
mosaic = (im1_ + im2_) ./ mass ;
end