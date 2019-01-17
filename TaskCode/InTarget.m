function inFlag = InTarget(Cursor,Target,TargetSize)
% function inFlag = InTarget(Cursor,Target,TargetSize)
% function to tell if cursor is inside of target
cursor_ctr = Cursor.Position;
target_ctr = [mean(Target([1,3])),mean(Target([2,4]))];
dist = sqrt(sum((cursor_ctr-target_ctr).^2));
inFlag = dist<TargetSize;
end % InTarget

