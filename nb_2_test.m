%Program for CSC522 course project: Precipitation prediction of
%Northwestern United States
%run after day_data_preprocessing
%10-fold cross validation model selection 
feature_matrix = correlation_matrix;
edges = [0, 0.1, 2.5, 10, 25, 50, 100, 400];
%mod_sel_dis_data = discretize(mod_sel_data, edges);

test_loss = zeros(length(lon), length(lat));
AUC = zeros(length(lon), length(lat));
BS = zeros(length(lon), length(lat));
[~, ~, d, ~] = size(feature_matrix);
[lo, la, dat] = size(mod_sel_data);

%mypool = parpool(4);
paroptions = statset('UseParallel',true);
%nbt = templateNaiveBayes('DistributionNames', 'mvmn');

%train_data = [];
%for i=1:dats
%    tp = mod_sel_data(:, :, i);
%    train_data = [train_data, tp(~no_detect)];
%end
%train_data = train_data';

total_predict_label = [];
total_test_label = [];

parfor m=1:lo
    for n=1:la
        if (~no_detect(m, n))
            %prepare training data (including cv data)
            cur_cost_matrix = cost_matrix;
            
            train_labels = reshape(mod_sel_labels(m, n, :), [length(mod_sel_labels), 1]);
            
            lb = [sum(train_labels==1), sum(train_labels==2), sum(train_labels==3), sum(train_labels==4), sum(train_labels==5)];
            
            for i=0:(length(lb)-1)
                tar = length(lb)-i;
                if (lb(tar)==0)
                    cur_cost_matrix(tar, :) = [];
                    cur_cost_matrix(:, tar) = [];
                end
            end
            train_data = [];
            for j=1:(d-1)
                cm = feature_matrix(m, n, j, 2);
                cn = feature_matrix(m, n, j, 3);
                train_data = [train_data; mod_sel_data(cm, cn, :)];
            end
            
            train_data = reshape(train_data, [(d-1), length(mod_sel_data)]);
            %tmp = train_data;
            %train_data = [mean(train_data, 1); max(train_data, [], 1); min(train_data, [], 1); std(train_data, 0, 1)];
            train_data = train_data';
            
            %prepare test data
            testl = reshape(test_labels(m, n, :), [length(test_labels), 1]);
            testd = [];
            for j=1:(d-1)
                cm = feature_matrix(m, n, j, 2);
                cn = feature_matrix(m, n, j, 3);
                testd = [testd; test_data(cm, cn, :)];
            end
            
            testd = reshape(testd, [(d-1), length(test_data)]);
            testd = testd';
            
            
            %nbmd = fitcecoc(train_data, train_labels, 'Learners', nbt,'Options', paroptions, 'Coding', 'ordinal', 'CrossVal', 'on', 'KFold', 5);
            nbmd = fitcnb(train_data, train_labels, 'DistributionNames', 'mvmn', 'CrossVal', 'off');
            %nbmd = fitcnb(train_data, train_labels, 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'));
            [predictl,postp,~] = predict(nbmd, testd);
            
            total_predict_label = [total_predict_label; predictl];
            total_test_label = [total_test_label; testl];
            
            testloss = 0;
            for i=1:length(testl)
               testloss = testloss + cost_matrix(testl(i), predictl(i));
            end
            testloss = testloss/length(testl);
            disp(testloss);
            test_loss(m, n) = test_loss(m, n)+testloss;
            
            frq = [sum(testl==1), sum(testl==2)]/length(testl);
            bs = 0;
            [~, csize] = size(postp);
            for i=1:length(postp)
                for j=1:2
                    bs = bs + (postp(i, j)-frq(j))^2;
                end    
            end
            BS(m, n) = bs/(length(postp));
            
            [~,~,~,auc] = perfcurve(predictl, testl, 1);
            AUC(m, n) = AUC(m, n)+auc;
            
            
            
        end
        
    end
end

confusion_matrix = confusionmat(total_test_label, total_predict_label);

%delete mypool