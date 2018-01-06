function [imageBox,maskBox] = lesionBox(image, mask)

    X0 = 1;
    for i=linspace(1,size(mask,1),size(mask,1))
        tmp = mask(i,:,:);
        if sum(abs(tmp(:,:)));
            break;
        else
            X0 = X0 + 1;
        end
    end
    
    X1 = size(mask,1);
    for i=linspace(size(mask,1),1,size(mask,1))
        tmp = mask(i,:,:);
        if sum(abs(tmp(:,:)));
            break;
        else
            X1 = X1 - 1;
        end
    end
    
    Y0 = 1;
    for i=linspace(1,size(mask,2),size(mask,2))
        tmp = mask(:,i,:);
        if sum(abs(tmp(:)));
            break;
        else
            Y0 = Y0 + 1;
        end
    end
    
    Y1 = size(mask,2);
    for i=linspace(size(mask,2),1,size(mask,2))
        tmp = mask(i,:,:);
        if sum(abs(tmp(:,:)));
            break;
        else
            Y1 = Y1 - 1;
        end
    end
    
    Z0 = 1;
    for i=linspace(1,size(mask,3),size(mask,3))
        tmp = mask(:,:,i);
        if sum(abs(tmp(:)));
            break;
        else
            Z0 = Z0 + 1;
        end
    end
    
    Z1 = size(mask,3);
    for i=linspace(size(mask,3),1,size(mask,3))
        tmp = mask(i,:,:);
        if sum(abs(tmp(:,:)));
            break;
        else
            Z1 = Z1 - 1;
        end
    end

    imageBox = image(X0:X1,Y0:Y1,Z0:Z1);
    maskBox = mask(X0:X1,Y0:Y1,Z0:Z1);
        
end