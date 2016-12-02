function G = sigmoid1( U, V)
%SIGMOID1 �˴���ʾ�йش˺�����ժҪ
% Sigmoid kernel function with slope gamma and intercept c
    gamma = 0.2;
    c = -1;
    G = tanh(gamma*U*V' + c);

end

