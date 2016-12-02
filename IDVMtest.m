%CSC522 Project spatial interpolation test
%using RMSE to evaluate the performance

%index of date when the data matrix in longitude*latitude has no missing
%data
dates_full_data = spatialInterpolationDataSelection(data, no_detect, miss_val);
distance_matrix = d_distance(data,no_detect,lat,lon,10);

SSE = zeros(length(lon), length(lat), length(dates_full_data));

for i=1:length(dates_full_data)
    date = dates_full_data(i);
    [lo, la, dts] = size(data);
    
    for m=1:lo
        for n=1:la
            if (~no_detect(m, n))
                fill = IDVM(data, no_detect, miss_val, distance_matrix, n, m, date, 2, 4);
                SSE(m, n, i) = (fill-data(m, n, date))^2;
            end
        end
    end
    
end    

SSE = sum(SSE, 3);

MSE = SSE./(length(dates_full_data));

RMSE = sqrt(MSE);

mean_RMSE = meanRMSE(RMSE, no_detect);
