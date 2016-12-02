function mean_RMSE = meanRMSE(RMSE, no_detect )
%MEANRMSE �˴���ʾ�йش˺�����ժҪ
%   purpose:    calculate mean RMSE based on no_detect matrix
%   parameters: RMSE - RMSE matrix
%               no_detect - matrix containing whether a data cell is used
%   output:     mean_RMSE - RMSE of all matrix that is included in the
%                           study
    
    count = 0;
    sum = 0;
    
    [lo, la] = size(RMSE);
    
    for i=1:lo
        for j=1:la
            if (~no_detect(i, j))
                sum = sum + RMSE(i, j);
                count = count+1;
            end
        end
    end
    
    mean_RMSE = sum/count;
end

