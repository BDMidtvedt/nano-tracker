function backpropagate(obj, field)
    FieldN = zeros(size(obj.Indexes.C), 'gpuArray');
    x = gpuArray(obj.Indexes.NQ(1)+1:obj.Indexes.size(1)+obj.Indexes.NQ(1)); % TODO Precalculate these in initializeParameters
    y = gpuArray(obj.Indexes.NQ(2)+1:obj.Indexes.size(2)+obj.Indexes.NQ(2));

    F = field;
    FINT = field.*obj.Indexes.TzC;
    setzero = gpuArray(obj.Indexes.C == 1);
    for kk=1:obj.Indexes.size(3)
        
        FieldN(setzero) = F.*obj.Indexes.Tmat{kk};
        Field = ifft2(FieldN);
        obj.State.S{kk} = (Field(x,y));
       
        FieldN(setzero) = FINT.*obj.Indexes.Tmat{kk};
        Field = ifft2(FieldN);
        obj.State.SI(:,:,kk)=(Field(x,y));
    end
end