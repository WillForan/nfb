function Perms = PrintAllPermutations(NumList)
% function Perms = PrintAllPermutations(NumList)

    Perms = [];
    Perms = DoSolve(NumList, [], Perms);
end

function Perms = DoSolve(Available, InList, Perms)

    if ~isempty(Available)
        for i = 1:length(Available)
            Tmp = Available;
            Tmp(i) = [];
            Perms = DoSolve(Tmp, [InList Available(i)], Perms);
        end
    else
        Perms = [Perms; InList];
    end

end
    
        
        
