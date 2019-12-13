input_data = open("input03.txt") do file
    data = readlines(file)
    entries = map(x -> [String(y) for y in split(x, ",")], data)
    #numbers = map(x->parse(Int64, x), entries)
    #numbers
    entries
end

struct Point
    x::Int
    y::Int
end

function parse_prefix(path::Array{Point, 1}, inst::String) :: Array{Point, 1}
    prefix = inst[1]
    current_ending = path[end]
    distance = parse(Int64, inst[2:end])
    if prefix == 'R'
        push!(path, Point(current_ending.x + distance, current_ending.y))
    elseif prefix == 'L'
        push!(path, Point(current_ending.x - distance, current_ending.y))

    elseif prefix == 'D'
        push!(path, Point(current_ending.x, current_ending.y + distance))

    elseif prefix == 'U'
        push!(path, Point(current_ending.x, current_ending.y - distance))
    else
        error("Somehow, prefix broken")
    end
    return path
end

function orientation(inst::Tuple{Point, Point})
    if inst[1].x == inst[2].x  # x stays the same
        return 1
    else
        return 2
    end
end

function colinear(inst1::Tuple{Point, Point}, inst2::Tuple{Point, Point})
  #println(inst1, inst2)
  (x_dist, y_dist) = (Inf, Inf)
    if inst1[1].x >= min(inst2[1].x, inst2[2].x) && inst1[1].x <= max(inst2[1].x, inst2[2].x)
      x_dist = inst1[1].x
    elseif inst2[1].x >= min(inst1[1].x, inst1[2].x) && inst2[1].x <= max(inst1[1].x, inst1[2].x)
      x_dist = inst2[1].x
    end
    if inst1[1].y >= min(inst2[1].y, inst2[2].y) && inst1[1].y <= max(inst2[1].y, inst2[2].y)
      y_dist = inst1[1].y
    elseif inst2[1].y >= min(inst1[1].y, inst1[2].y) && inst2[1].y <= max(inst1[1].y, inst1[2].y)
      y_dist = inst2[1].y
    end
    #println("colinear", (x_dist, y_dist))
    return (x_dist, y_dist)
end

function cross_intersect(inst1::Tuple{Point, Point}, inst2::Tuple{Point, Point})
  # assume that inst1 has static x value and inst2 has static y value
  (x_dist, y_dist) = (Inf, Inf)
  #println(inst1, inst2)
  if inst1[1].x <= max(inst2[1].x, inst2[2].x) && inst1[1].x >= min(inst2[1].x, inst2[2].x) &&
    inst2[1].y <= max(inst1[1].y, inst1[2].y) && inst2[1].y >= min(inst1[1].y, inst1[2].y) 
    x_dist = inst1[1].x
    y_dist = inst2[1].y
  end

  #println("cross", (x_dist, y_dist))
  return (x_dist, y_dist)
end

function test_intersect(inst1::Tuple{Point, Point}, inst2::Tuple{Point, Point}) :: Tuple{Bool, Point}
  x_dist = Inf
  y_dist = Inf
    if orientation(inst1) == orientation(inst2)
      (x_dist, y_dist) = colinear(inst1, inst2)
    else #different orientation
      #println(orientation(inst1))
      if orientation(inst1) == 1
        (x_dist, y_dist) = cross_intersect(inst1, inst2)
      else
        (x_dist, y_dist) = cross_intersect(inst2, inst1)
      end
    end
    

    if x_dist != Inf && y_dist != Inf
      return (true, Point(x_dist, y_dist))
    end
    return (false, Point(0,0))
end

function algorithm(input::Array{Array{String,1},1})
    inp1 = foldl(parse_prefix, input[1]; init=[Point(0,0)] )
    inp2 = foldl(parse_prefix, input[2]; init=[Point(0,0)] )
    best_guess = Inf
    for i = 2:length(inp1)-1
        for j = 2:length(inp2)-1
            entry1 = (inp1[i], inp1[i+1])
            entry2 = (inp2[j], inp2[j+1])
            check = test_intersect(entry1, entry2)
            #println(check)
            if check[1] == true
              best_guess = min(best_guess, manhattan_dist(check[2]))
            end
        end
    end
    best_guess
end

function manhattan_dist(p1::Point, p2::Point = Point(0,0)) :: Int64
  return abs(p2.x - p1.x) + abs(p2.y - p1.y)
end


function algorithm2(input::Array{Array{String,1},1}) :: Int64
    inp1 = foldl(parse_prefix, input[1]; init=[Point(0,0)] )
    inp2 = foldl(parse_prefix, input[2]; init=[Point(0,0)] )
    best_guess = Inf
    manhattan1 = [manhattan_dist(inp1[2], inp1[1])]
    for i = 2:length(inp1)-1
      manhattan2 = [manhattan_dist(inp2[2], inp2[1])]
        for j = 2:length(inp2)-1
            entry1 = (inp1[i], inp1[i+1])
            entry2 = (inp2[j], inp2[j+1])
            check = test_intersect(entry1, entry2)
            #println(check)
            if check[1] == true
              println(manhattan1)
              println(manhattan2)
              intersect_diff = manhattan_dist(inp1[i], check[2]) + manhattan_dist(inp2[j], check[2])
              #best_guess = min(best_guess, manhattan_dist(check[2]))
              best_guess = min(best_guess, sum(manhattan1) + sum(manhattan2) + intersect_diff)
            end
          push!(manhattan2, manhattan_dist(inp2[j+1], inp2[j]))
        end
      push!(manhattan1, manhattan_dist(inp1[i+1], inp1[i]))
    end
    best_guess
end


using Test
example_input1 = [["R8","U5","L5","D3"], ["U7","R6","D4","L4"]]
example_input2 = [["R75","D30","R83","U83","L12","D49","R71","U7","L72"],
["U62","R66","U55","R34","D71","R55","D58","R83"]]
@test parse_prefix([Point(0,0)], "R75") == [Point(0,0), Point(75,0)]
@test parse_prefix([Point(75, 0)], "D30") == [Point(75,0), Point(75, 30)]
@test algorithm(example_input1) == 6
@test algorithm(example_input2) == 159
@test algorithm2(example_input1) == 30
println(input_data)
println(algorithm(input_data))
println(algorithm2(input_data))
