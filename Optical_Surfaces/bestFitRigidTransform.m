function [R, t] = bestFitRigidTransform(P, Q)
% Finds R (3x3) and t (3x1) minimizing sum || R*P_i + t - Q_i ||^2
% P, Q are Nx3.

    assert(size(P,2)==3 && size(Q,2)==3, 'P and Q must be Nx3');
    assert(size(P,1)==size(Q,1), 'P and Q must have same N');

    % Centroids
    cP = mean(P, 1);
    cQ = mean(Q, 1);

    % Centered
    P0 = P - cP;
    Q0 = Q - cQ;

    % Covariance
    H = P0.' * Q0;

    % SVD
    [U, ~, V] = svd(H);

    R = V * U.';

    % Fix reflection if needed
    if det(R) < 0
        V(:,3) = -V(:,3);
        R = V * U.';
    end

    t = cQ.' - R * cP.';
end
