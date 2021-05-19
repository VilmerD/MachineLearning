function [state_action_feats, prev_grid, previous_head_location] = extract_state_action_features(prev_grid, grid, previous_head_location, nbr_feats)
%
% Code may be changed in this function, but only where it states that it is
% allowed to do so.
%
% Function to extract state-action features, based on current and previous
% grids (game screens).
%
% Input:
%
% prev_grid     - Previous grid (game screen), N-by-N matrix. If initial
%                 time-step: prev_grid = grid, else: prev_grid != grid.
% grid          - Current grid (game screen), N-by-N matrix. If initial
%                 time-step: prev_grid = grid, else: prev_grid != grid.
% prev_head_loc - The previous location of the head of the snake (from the
%                 previous time-step). If initial time-step: Assumed known,
%                 else: inferred in function "update_snake_grid.m" (so in
%                 practice it will always be known in this function).
% nbr_feats     - Number of state-action features per action. Set this
%                 value appropriately in the calling script "snake.m", to
%                 match the number of state-action features per action you
%                 end up using.
%
% Output:
%
% state_action_feats - nbr_feats-by-|A| matrix, where |A| = number of
%                      possible actions (|A| = 3 in Snake), and nbr_feats
%                      is described under "Input" above. This matrix
%                      represents the state-action features extracted given
%                      the current and previous grids (game screens).
% prev_grid          - The previous grid as seen from one step in the
%                      future, i.e., prev_grid is set to the input grid.
% prev_head_loc      - The previous head location as seen from one step
%                      in the future, i.e., prev_head_loc is set to the
%                      current head location (the current head location is
%                      inferred in the code below).
%
% Bugs, ideas etcetera: send them to the course email.

% --------- DO NOT CHANGE ANYTHING BELOW UNLESS OTHERWISE NOTIFIED! -------

% Extract grid size.
N = size(grid, 1);

% Initialize state_action_feats to nbr_feats-by-3 matrix.
state_action_feats = nan(nbr_feats, 3);

% Based on how grid looks now and at previous time step, infer head
% location.
change_grid = grid - prev_grid;
prev_grid   = grid; % Used in later calls to "extract_state_action_features.m"

% Find head location (initially known that it is in center of grid).
if nnz(change_grid) > 0 % True, except in initial time-step
    [head_loc_m, head_loc_n] = find(change_grid > 0);
else % True only in initial time-step
    head_loc_m = round(N / 2);
    head_loc_n = round(N / 2);
end
head_location = [head_loc_m, head_loc_n];

% Previous head location.
prev_head_loc_m = previous_head_location(1);
prev_head_loc_n = previous_head_location(2);

% Infer current movement directory (N/E/S/W) by looking at how current and previous
% head locations are related
if prev_head_loc_m == head_loc_m + 1 && prev_head_loc_n == head_loc_n     % NORTH
    movement_dir = 1;
elseif prev_head_loc_m == head_loc_m && prev_head_loc_n == head_loc_n - 1 % EAST
    movement_dir = 2;
elseif prev_head_loc_m == head_loc_m - 1 && prev_head_loc_n == head_loc_n % SOUTH
    movement_dir = 3;
else                                                                      % WEST
    movement_dir = 4;
end

% The current head_loc will at the next time-step be prev_head_loc.
previous_head_location = head_location;

% ------------- YOU MAY CHANGE SETTINGS BELOW! --------------------------

% HERE BEGINS YOUR STATE-ACTION FEATURE ENGINEERING. THE CODE BELOW IS
% ALLOWED TO BE CHANGED IN ACCORDANCE WITH YOUR CHOSEN FEATURES.
% Some skeleton code is provided to help you get started. Also, have a
% look at the function "get_next_info" (see bottom of this function).
% You may find it useful.

for action = 1 : 3 % Evaluate all the different actions (left, forward, right).
    
    % Feel free to uncomment below line of code if you find it useful.
    [next_head_location, next_movement_dir] = ...
        get_next_info(action, movement_dir, head_location);
    
    % Replace this to fit the number of state-action features per features
    % you choose (3 are used below), and of course replace the randn()
    % by something more sensible.
    
    % angle to apple?
    state_action_feats(1, action) = ...
        apple_angle(grid, head_location, next_movement_dir);
    % Angle is 1 if snake is moving towards apple, -1 if moving away. Thus
    % a good weight is positive. Also, it only cares if the angle is
    % positive or negative, so it moves in straight lines.
    
    % obsticle if taking action
    state_action_feats(2, action) = obstacles(grid, next_head_location);
    % The snake should avoid obstacles, so a good action this feat is
    % negative, and thus a good weight is negative.
    
    state_action_feats(3, action) = scan22(grid, head_location, ...
        next_movement_dir);
    
    state_action_feats = state_action_feats(1:nbr_feats, :);
end
end

% Movement direction
function d = vectorized_movement_direction(move_dir)
% Input:    move_dir
% Returns:  vectorized movement direction in 2d
move_dir = mod(move_dir, 4);
switch move_dir
    case 1
        d = [-1, 0];
    case 2
        d = [0, 1];
    case 3
        d = [1 0];
    case 0
        d = [0 -1];
end
end

% Angle to apple
function cb = apple_angle(grid, head_location, movement_direction)
% Input:    grid, head_location, movement_direction
% Returns:  (binary) 1 if the snake is moving towards the apple and
%           -1 if it is moving away from the apple
[rows_apple, cols_apple] = find(grid == -1);
apple = [rows_apple, cols_apple];
v = apple-head_location;
vn = v/norm(v);

d = vectorized_movement_direction(movement_direction);  % Vectorized
c = vn*d';                                              % cos(angle)
cb = (c > 0) - (c == -1);
end

% How many obstacles there are at a position in the grid
function on = obstacles(grid, pos)
% Input:    grid, pos
% Returns:  (binary) -1 if there is no obstacle at pos, and 1 if
%           there is an obstacle at pos
obs = grid(pos(1), pos(2)) == 1;
on = obs;
end

function davrg = scan3(grid, head_location, movement_direction)
[M, N] = size(grid);
A = M*N;
dmax = N/4;
dmin = 8;
% Ignoring walls and head location, so the snake only avoids it's own body
grid(:, 1) = 0; grid(:, N) = 0;
grid(1, :) = 0; grid(M, :) = 0;
grid(head_location(1), head_location(2)) = 0;
h = sub2ind(size(grid), head_location(1), head_location(2));

skip1 = (N+1);
s1 = sign(1 - (movement_direction - 2.5)^2);
iend = A*(s1>0) + 1*(s1<0);
L1 = grid(h:s1*skip1:iend);
d1 = find(L1 == 1, 1, 'first')*sqrt(2);
if numel(d1) == 0
    d1 = dmax;
end

skip2 = (N-1);
s2 = sign(2.5 - movement_direction);
iend = A*(s2>0) + 1*(s2<0);
L2 = grid(h:s2*skip2:iend);
d2 = find(L2 == 1, 1, 'first')*sqrt(2);
if numel(d2) == 0
    d2 = dmax;
end

r = (mod(movement_direction, 2) == 0);
skip3 = N*r + 1*~r;
s3 = s1;
n = abs(head_location(1*~r + 2*r) - N*(s2 > 0));
iend = max(min(h + s3*skip3*n, A), 1);
L3 = grid(h:s3*skip3:iend);
d3 = find(L3 == 1, 1, 'first');
if numel(d3) == 0
    d3 = dmax;
end

d = [d1; d2; d3]/dmax;
d = min(d, ones(3, 1));
d = d.*(d > dmin/dmax);

davrg = 2*max(d) - 1;
end

function davrg = scan2(grid, head_location, movement_direction)
[M, N] = size(grid);
A = M*N;
dmax = N/2;
dmin = N/7;
% Ignoring walls and head location, so the snake only avoids it's own body
grid(:, 1) = 0; grid(:, N) = 0;
grid(1, :) = 0; grid(M, :) = 0;
grid(head_location(1), head_location(2)) = 0;
h = sub2ind(size(grid), head_location(1), head_location(2));

skip1 = (N+1);
s1 = sign(1 - (movement_direction - 2.5)^2);
iend = A*(s1>0) + 1*(s1<0);
L1 = grid(h:s1*skip1:iend);
d1 = find(L1 == 1, 1, 'first');
if numel(d1) == 0
    d1 = dmax;
end

skip2 = (N-1);
s2 = sign(2.5 - movement_direction);
iend = A*(s2>0) + 1*(s2<0);
L2 = grid(h:s2*skip2:iend);
d2 = find(L2 == 1, 1, 'first');
if numel(d2) == 0
    d2 = dmax;
end
d = [d1-1; d2-1]/(dmax-1);
d = min(d, ones(2, 1));
d = (d > dmin/dmax*ones(2, 1));

davrg = max(d);
end

function davrg = scan22(grid, head_location, movement_direction)
[M, N] = size(grid);
dmax = 6;
dmin = 0;
% Ignoring walls and head location, so the snake only avoids it's own body
grid(:, 1) = 0; grid(:, N) = 0;
grid(1, :) = 0; grid(M, :) = 0;
hr = head_location(1);
hc = head_location(2);
grid(hr, hc) = 0;
h = sub2ind(size(grid), head_location(1), head_location(2));

step = -(N-1);
imax = h + step*min(hr, hc);
imax = max(1, min(N, imax));
LL1 = grid(h:step:imax);

step = (N-1);
imax = h + step*(N-max(hr, hc));
imax = max(1, min(N, imax));
LL2 = grid(h:step:imax);

step = (N+1);
imax = h + step*min(hr, hc);
imax = max(1, min(N, imax));
LL3 = grid(h:step:imax);

step = -(N+1);
imax = h + step*(N-max(hr, hc));
imax = max(1, min(N, imax));
LL4 = grid(h:step:imax);
switch movement_direction
    case 1
        L1 = LL1;
        L2 = LL2;
        L3 = grid(hr, hc:-1:1);
    case 2
        L1 = LL2;
        L2 = LL3;
        L3 = grid(hr:N, hc);
    case 3
        L1 = LL3;
        L2 = LL4;
        L3 = grid(hr, hc:M);
    case 4
        L1 = LL4;
        L2 = LL1;
        L3 = grid(hr:-1:1, hc);
end
d1 = find(L1 == 1, 1, 'first');
d2 = find(L2 == 1, 1, 'first');
d3 = find(L3 == 1, 1, 'first');

if numel(d1) == 0 d1 = dmax; end
if numel(d2) == 0 d2 = dmax; end
if numel(d3) == 0 d3 = dmax; end
d = ([d1; d2; d3] -1)/(dmax-1);
d = min(d, ones(3, 1));
d = d.*(d > dmin/dmax*ones(3, 1));

davrg = max(d(1:2));
end
% Gets the information for the next state
function [next_head_loc, next_move_dir] = get_next_info(action, movement_dir, head_loc)
% Function to infer next haed location and movement direction

% Extract relevant stuff
head_loc_m = head_loc(1);
head_loc_n = head_loc(2);

if movement_dir == 1 % NORTH
    if action == 1     % left
        next_head_loc_m = head_loc_m;
        next_head_loc_n = head_loc_n - 1;
        next_move_dir   = 4;
    elseif action == 2 % forward
        next_head_loc_m = head_loc_m - 1;
        next_head_loc_n = head_loc_n;
        next_move_dir   = 1;
    else               % right
        next_head_loc_m = head_loc_m;
        next_head_loc_n = head_loc_n + 1;
        next_move_dir   = 2;
    end
elseif movement_dir == 2 % EAST
    if action == 1
        next_head_loc_m = head_loc_m - 1;
        next_head_loc_n = head_loc_n;
        next_move_dir   = 1;
    elseif action == 2
        next_head_loc_m = head_loc_m;
        next_head_loc_n = head_loc_n + 1;
        next_move_dir   = 2;
    else
        next_head_loc_m = head_loc_m + 1;
        next_head_loc_n = head_loc_n;
        next_move_dir   = 3;
    end
elseif movement_dir == 3 % SOUTH
    if action == 1
        next_head_loc_m = head_loc_m;
        next_head_loc_n = head_loc_n + 1;
        next_move_dir   = 2;
    elseif action == 2
        next_head_loc_m = head_loc_m + 1;
        next_head_loc_n = head_loc_n;
        next_move_dir   = 3;
    else
        next_head_loc_m = head_loc_m;
        next_head_loc_n = head_loc_n - 1;
        next_move_dir   = 4;
    end
else % WEST
    if action == 1
        next_head_loc_m = head_loc_m + 1;
        next_head_loc_n = head_loc_n;
        next_move_dir   = 3;
    elseif action == 2
        next_head_loc_m = head_loc_m;
        next_head_loc_n = head_loc_n - 1;
        next_move_dir   = 4;
    else
        next_head_loc_m = head_loc_m - 1;
        next_head_loc_n = head_loc_n;
        next_move_dir   = 1;
    end
end
next_head_loc = [next_head_loc_m, next_head_loc_n];
end