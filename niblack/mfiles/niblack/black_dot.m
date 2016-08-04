function [img_out,VF] = black_dot(img_out)
img_labeled = bwlabel(img_out);
class = img_labeled(117,781);
pic = double(img_labeled == class);

area = sum(pic(:));
if area<=40*40
    img_out = img_out-pic;
end

class = img_labeled(995,415);
pic = double(img_labeled == class);

area = sum(pic(:));
if area<=40*40
    img_out = img_out-pic;
end

VF = sum(img_out(:))/1430/1430
% save(path,'img_out','VF');
end