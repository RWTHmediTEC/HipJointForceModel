function muscleListDostal = Johnston1979toDostal1981(muscleListJohnston, LE)

muscleListDostal = fieldnames(LE(1).Muscle);

for m=1:size(muscleListJohnston,1)
    mIdx = contains(muscleListDostal(:,1),muscleListJohnston{m,1});
    muscleListDostal(mIdx,5)={muscleListJohnston{m,2}/sum(mIdx)};
end

NoM = size(muscleListDostal,1);

muscleListDostal(:,1) = cellfun(@(x) x(1:end-1), muscleListDostal(:,1),'uni',0);
muscleListDostal(:,2) = mat2cell(round(rand(NoM,3),4),ones(NoM,1));
muscleListDostal(:,3) = {[1 2]};
muscleListDostal(:,4) = {1};
    

end





