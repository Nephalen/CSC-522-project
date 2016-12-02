function G = quadric1( U,V )
%QUADRIC1 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    c = 1;
    alpha = 0.2;
    beta = 1;
    
    [m, p] = size(U);
    [n, p] = size(V);
    norm_d = 2;
    
    G = zeros(m, n);
    for i=1:m
        for j=1:n
            U0 = U(i, :);
            V0 = V(j, :);
            G(i, j) = (c+alpha*(norm(U0-V0, norm_d)^2))^(beta*-1);
        end
        
    end
    
end

