function result = test_KalmanFilter()

A = [1, 0.5, 0.25
     0, 1, 0.5
     0, 0, 1];
 
C = [1, 0, 0
    0, 1, 0];

Q = [1, 0, 0
    0, 1, 0
    0, 0, 1];

R = [1, 0
    0, 1];

initial_state = [1, 0.5, 0.5]';
observation = [0.4, 0.4]';
kalmanfilter = KalmanFilter(A, C, Q, R, initial_state);
kalmanfilter = kalmanfilter.predict();
kalmanfilter = kalmanfilter.update(observation);

result = 0;
