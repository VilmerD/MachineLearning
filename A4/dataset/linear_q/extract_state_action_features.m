function [state_action_feats, prev_grid, prev_head_loc] = extract_state_action_features(prev_grid, grid, prev_head_loc, nbr_feats)
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
head_loc = [head_loc_m, head_loc_n];

% Previous head location.
prev_head_loc_m = prev_head_loc(1);
prev_head_loc_n = prev_head_loc(2);

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
prev_head_loc = head_loc;

% ------------- YOU MAY CHANGE SETTINGS BELOW! --------------------------

% HERE BEGINS YOUR STATE-ACTION FEATURE ENGINEERING. THE CODE BELOW IS
% ALLOWED TO BE CHANGED IN ACCORDANCE WITH YOUR CHOSEN FEATURES.
% Some skeleton code is provided to help you get started. Also, have a
% look at the function "get_next_info" (see bottom of this function).
% You may find it useful.

for action = 1 : 3 % Evaluate all the different actions (left, forward, right).
    
    % Feel free to uncomment below line of code if you find it useful.
    [next_head_loc, next_move_dir] = get_next_info(action, movement_dir, head_loc);
    
    % Replace this to fit the number of state-action features per features
    % you choose (3 are used below), and of course replace the randn()
    % by something more sensible.
    
    % angle to apple?
    state_action_feats(1, action) = ...
        apple_angle(grid, head_loc, next_move_dir);
    % Angle is 1 if snake is moving towards apple, -1 if moving away. Thus
    % a good weight is positive. Also, it only cares if the angle is
    % positive or negative, so it moves in straight lines.
    
    % obsticle if taking action
    state_action_feats(2, action) = obstacles(grid, next_head_loc);
    % The snake should avoid obstacles, so a good action this feat is
    % negative, and thus a good weight is negative.
    
    state_action_feats(3, action) = moving_towards_itself(grid, ...
        head_loc, next_move_dir);
    
    state_action_feats = state_action_feats(1:nbr_feats, :);
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
cb = (c > 0) - (c < 0);
end

function b = between(u, v, x)
s1 = sign(det([u; v]));
s2 = sign(det([u; x]));
b = s1 == s2;
end

function vis = visible(grid, head, target)
[row, col] = body_position(grid);
pos = [row(2:end), col(2:end)];
vectors = pos - head;
vectors = vectors./sqrt(vectors(:, 1).^2 + vectors(:, 2).^2);
ref = vectors(1, :);
vectors = vectors(2:end, :);
nparts = numel(row) - 2;
for k = 1:nparts
    u = vectors(k, :);
    b = between(ref, u, target);
    if b
        vis = false;
        return
    end
end
vis = true;
end

% How many obstacles there are at a position in the grid
function on = obstacles(grid, pos)
% Input:    grid, pos
% Returns:  (binary) -1 if there is no obstacle at pos, and 1 if
%           there is an obstacle at pos
obs = grid(pos(1), pos(2)) == 1;
on = 2*obs-1;
end

% Finds the body of the snake
function [row, col] = body_position(grid)
[row, col] = find(grid(2:end-1, 2:end-1) == 1);
row = row + 1;
col = col + 1;
end

% Find the mass centrum of the snake
function mc = mass_centrum(grid)
[row_snake, col_snake] = body_position(grid);
mc = mean([row_snake, col_snake], 1);
end

% Finds the angle between mass centrum and snake move direction
function cb = mass_centrum_angle(grid, head_location, movement_direction)
% Input:    grid, head_location, movement_direction
% Returns:  ()
mc = mass_centrum(grid);
v = mc - head_location;
vn = v/norm(v);

d = vectorized_movement_direction(movement_direction);  % Vectorized
c = vn*d';
cb = (c > 0.8660);
end

% Finds if the snake is moving directly towards any of the body parts
function bool = moving_towards_itself(grid, head, movement_direction)
grid(head(1), head(2)) = 0;
[row, col] = body_position(grid);
vectors = [row, col] - head;
vectors = vectors./sqrt(vectors(:, 1).^2 + vectors(:, 2).^2);
d = vectorized_movement_direction(movement_direction);  % Vectorized
v = vectors*d';
bool = sum(v == 1);
end

% Looks in the direction to see if there is an object there
function obj = look(grid, direction, head)
pos = head;
direction = direction / direction(1);
found_obj = false;
while ~found_obj
    pos = pos + direction;
    pos_discrete1 = floor(pos);
    pos_discrete2 = roof(pos);
    try
        obj1 = grid(pos_discrete1(1), pos_discrete1(2));
        obj2 = grid(pos_discrete2(1), pos_discrete2(2));
    catch
        obj1 = 1;
    end
    if obj1 ~= 0
        found_obj = true;
    end
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


function free_directions = is_surrounded(grid, head_loc, movement_dir)
free_left = ~restricted_direction(grid, head_loc, movement_dir - 1);
free_right = ~restricted_direction(grid, head_loc, movement_dir + 1);
free_forward = ~restricted_direction(grid, head_loc, movement_dir);
free_directions = free_left + free_right + free_forward;
end

function restricted = restricted_direction(grid, head, d)
[M, N] = size(grid);
d = mod(d, 4);
if d == 0
    d = 4;
end
switch d
    case 1
        grid_slice = grid(1:head(1)-1, head(2));
        obstacles = grid_slice == 1;
    case 2
        grid_slice = grid(head(1), head(2)+1:N);
        obstacles = grid_slice == 1;
    case 3
        grid_slice = grid(head(1)+1:M, head(2));
        obstacles = grid_slice == 1;
    case 4
        grid_slice = grid(head(1), 1:head(2)-1);
        obstacles = grid_slice == 1;
end
restricted = s(obstacles) > 1;
end

% Computes how long the snake can move in the direction d untill it hits an
% obsticle
function dist = longest_distance(grid, head, d)
[M, N] = size(grid);
d = mod(d, 4);
if d == 0
    d = 4;
end
switch d
    case 1
        grid_slice = grid(1:head(1)-1, head(2));
        pos = find(grid_slice == 1, 1, 'last');
        dist = head(1) - pos - 1;
    case 2
        grid_slice = grid(head(1), head(2)+1:N);
        pos = head(2) + find(grid_slice == 1, 1, 'first');
        dist = pos - head(2) - 1;
    case 3
        grid_slice = grid(head(1)+1:M, head(2));
        pos = head(1) + find(grid_slice == 1, 1, 'first');
        dist = pos - head(1) - 1;
    case 4
        grid_slice = grid(head(1), 1:head(2)-1);
        pos = find(grid_slice == 1, 1, 'last');
        dist = head(2) - pos - 1;
end
if numel(dist) == 0
    dist = 0;
end
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