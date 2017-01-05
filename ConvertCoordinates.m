function CoordList = ConvertCoordinates(OrigCenter, NewCenter, CoordList)
% function Converted = ConvertCoordinates(OrigCenter, NewCenter, CoordList)

    for i = 1:size(CoordList)
        CoordList{i}(1) = NewCenter(1) - (OrigCenter(1) - CoordList{i}(1));
        CoordList{i}(2) = NewCenter(2) - (OrigCenter(2) - CoordList{i}(2));
    end
end
        
