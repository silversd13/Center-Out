function inFlag = InTarget(Cursor,Target,TargetSize)
% function inFlag = InTarget(Cursor,Target,TargetSize)
% function to tell if cursor is inside of target
cursorpos = Cursor.Position;
targetpos = [mean(Target([1,3])),mean(Target([2,4]))];
dist = sqrt((cursorpos-targetpos).^2);
inFlag = dist<TargetSize;
end

