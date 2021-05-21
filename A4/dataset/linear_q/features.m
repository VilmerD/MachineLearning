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
    case 0
        grid_slice = grid(head(1), 1:head(2)-1);
        pos = find(grid_slice == 1, 1, 'last');
        dist = head(2) - pos - 1;
end
if numel(dist) == 0
    dist = 0;
end
end

