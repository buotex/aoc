using Test
using Logging
using OffsetArrays
logger = SimpleLogger(stderr, Logging.Info)
global_logger(logger)

function parse_string_array(data)::Array{Int8, 2}
  asteroids = []
  mapping_table = Dict('#' => 1, '.' => 0, 'X' => 2)
  for line in split(data, '\n')
    entries = filter( x -> x != '\r', collect(line))
    asteroid_line = map(x->mapping_table[x], entries)
    if length(asteroid_line) > 0
      push!(asteroids, asteroid_line)
    end
  end
  println(asteroids)
  num_lines = length(asteroids)
  transpose(reshape(vcat(asteroids...),length(asteroids[1]), num_lines))
end

function draw_array(data)
  dims = size(data)
  full_string = ""
  for i in 1:dims[1]
    for j in 1:dims[2]
      x = data[i,j]
      if x == 0
        full_string *= '.'
      elseif x == 1
        full_string *= '#'
      elseif x == 2
        full_string *= 'A'
      end
    end
    full_string *= '\n'
  end
  return full_string
end

input_data = open("input10.txt") do file
  data = read(file, String)
  parse_string_array(data)
end


test_data=
"""
##..
..##
"""
@test parse_string_array(test_data) == [1 1 0 0 ; 0 0 1 1]
println(parse_string_array(test_data))

function first_visible(data, x1, y1, x2, y2)
  diff_x = x2-x1
  diff_y = y2-y1
  the_gcd = gcd(diff_x, diff_y)
  x_stepsize = diff_x ÷ the_gcd
  y_stepsize = diff_y ÷ the_gcd
  for step = 1:the_gcd
    (test_x, test_y) = (x1 + step * x_stepsize, y1 + step * y_stepsize)
    @debug("checked: $test_x, $test_y")
    if data[test_x, test_y] > 0
      return (x=test_x, y=test_y)
    end
  end
  @debug("Visible!")
  return (x=x2, y=y2)
end

function count_visible(data, x, y)
  dims = size(data)
  visible_matrix = zeros(Int8, dims[1], dims[2])
  visible_matrix[x,y] = 2
  count = 0

  for i = 1:dims[1]
    for j = 1:dims[2]
      if x == i && y == j
        continue
      elseif data[i,j] == 0
        continue
      else
        local indices = first_visible(data, x,y,i,j)
        if indices.x == i && indices.y == j
          visible_matrix[i,j] = 1
          count += 1
        end
      end
    end
  end
  (count=count, visible_matrix=visible_matrix)
end

function max_visible_count(data)
  dims = size(data)
  maxcount = 0
  best_indices = undef
  for i = 1:dims[1]
    for j = 1:dims[2]
      if data[i,j] == 0
        continue
      end
      count = count_visible(data, i, j).count
      if count > maxcount
        maxcount = count
        best_indices = (x=i,y=j)
      end
    end
  end
  return (maxcount=maxcount, best_indices=best_indices)
end


function sort_rotating_indices(indices_with_angles)
  return [indices_with_angles[angle].index for angle in sort(collect(keys(indices_with_angles)))]
end

function get_rotating_indices(dimensions, start)
    angles = Dict()
		for i in 1:dimensions[1]
			for j in 1:dimensions[2]
        diff_x = i - start.x
        diff_y = j - start.y
        if diff_x == 0 && diff_y == 0
          continue
        end
        dist = diff_x ^ 2 + diff_x ^ 2
        angle = mod2pi(atan(diff_y, -diff_x))
        if haskey(angles, angle) && dist <= angles[angle].dist
          continue
        else
          angles[angle] = (index=(x=i,y=j), dist=dist)
        end
			end
		end

    sorted_indices = sort_rotating_indices(angles)
    return sorted_indices
end

function draw_indices(dimensions, sorted_angles)
  arr = zeros(Int64, dimensions[1], dimensions[2])
  for (i, indices) in enumerate(sorted_angles)
    arr[indices.x, indices.y] = i
  end
  return arr
end

function laser_blasting(data, laser_x, laser_y, target_x, target_y)
  copied_data = copy(data)
  indices = first_visible(data, laser_x, laser_y, target_x, target_y)
  copied_data[indices.x, indices.y] = 0
  return copied_data
end

function laser_destruction(_data, start_index)
  data = copy(_data)
  sorted_indices = get_rotating_indices(size(data), start_index)
  destroyed = 0
  while destroyed < 200
    for index in sorted_indices
      indices = first_visible(data, start_index.x, start_index.y, index.x, index.y)
      if data[indices.x, indices.y] == 1
        destroyed += 1
        data[indices.x, indices.y] = 0
        if destroyed == 200
          display(indices)
        end
      end
    end
  end
end

test_data1 = 
"""
.#..#
.....
####X
....#
...##
"""
parsed_test_data1 = parse_string_array(test_data1)
@test parsed_test_data1[1,2] == 1
@test parsed_test_data1[5,4] == 1
#@test count_visible(parsed_test_data1, 5, 4) == 8
@test count_visible(parsed_test_data1, 1, 5).count == 7
@test max_visible_count(parsed_test_data1).maxcount == 8

test_data2 =
"""
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
"""
#@test max_visible_count(parse_string_array(test_data2)) == (maxcount=33, best_indices=(9,6))
print(draw_array(count_visible(parse_string_array(test_data2), 2, 1).visible_matrix))




solution1 = max_visible_count(input_data)
#@test laser_blasting(parsed_test_data1, )
best_indices = solution1.best_indices
println("The best indices are $best_indices")
test_indices = get_rotating_indices((5,5), (x=2,y=2))
display(test_indices)
display(draw_indices((5,5), test_indices))
laser_destruction(input_data, best_indices)
