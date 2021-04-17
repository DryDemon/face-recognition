
for i=1:246

    if ~exist("trainingImages/"+i+"/" + , 'dir') &  exist("validationImages/"+i+"/" + , 'dir')
        disp("Missing Class in training" + i)
    end

    if exist("trainingImages/"+i+"/" + , 'dir') &  ~exist("validationImages/"+i+"/" + , 'dir')
        disp("Missing Class in validation" + i)
    end
end