include("./computer.jl")
include("./utils.jl")
input_data = read_numbers("input11.txt")
using Test
using OffsetArrays


function paint_move!(painted, current_coordinates, color, new_direction)
  painted[current_coordinates.x, current_coordinates.y] = color
  new_coordinates = (x=current_coordinates.x + new_direction.x_dir, y=current_coordinates.y + new_direction.y_dir)
  return new_coordinates
end
function angle2direction(angle)
  x_dir = -Int(round(cos(angle)))
  y_dir = Int(round(sin(angle)))
  return (x_dir=x_dir, y_dir=y_dir)
end

function count_painted(arr)
  count_black = count(i -> (i == 0), arr)
  count_white = count(i -> (i == 1), arr)
  return count_black + count_white
end

function robot_controller(view_channel, control_channel, initial_color=0)
  dims = (100,100)
  offset_limits = (-50:49, -50:49)
  println(offset_limits)
  
  painted = OffsetArray(ones(Int8, dims...) * 255, offset_limits)
  current_coordinates = (x=0,y=0)
  current_angle = 0
  current_direction = angle2direction(current_angle)
  color_map = Dict(255 => 0, 0 => 0, 1 => 1)
  function turn_right!()
    current_angle = mod2pi(current_angle + π/2)
    current_direction = angle2direction(current_angle)
  end
  function turn_left!()
    current_angle = mod2pi(current_angle - π/2)
    current_direction = angle2direction(current_angle)
  end

  put!(view_channel, initial_color)
  while true
    @debug(current_coordinates)
    color = take!(control_channel)
    @debug("color: $color")
    if color == 255
      break
    end
    direction = take!(control_channel)
    @debug("direction: $direction")
    if direction == 0
      turn_left!()
    elseif direction == 1
      turn_right!()
    end
    current_coordinates = paint_move!(painted, current_coordinates, color, current_direction)
    @debug("current_coordinates: $current_coordinates")
    view_color = color_map[painted[current_coordinates.x, current_coordinates.y]]
    @debug("view_color: $view_color")
    put!(view_channel, view_color)
  end
  println("Painted pixels: $(count_painted(painted))")
  return painted
end
function robot_program(input_data, view_channel, control_channel)
    run_program_async(input_data, view_channel, control_channel)
    put!(control_channel, 255) #break
end

function robot_state_machine(input_data, initial_color=0)
  
  view_channel = Channel{Int64}(Inf)
  control_channel = Channel{Int64}(Inf)
  output = undef
  
  @sync begin
    @async robot_program(input_data, view_channel, control_channel)
    @async output = robot_controller(view_channel, control_channel, initial_color)
  end

  return output
  
end




function test_robot_program()

  input_data = [3,0,104,1,104,1, 99]
  robot_state_machine(input_data)
  
end
#run_program_async(input_data, view_channel, control_channel)
test_map = ones(Int8, 3,3) * 255
@test paint_move!(test_map, (x=2, y=2), 1, (x_dir=1, y_dir=0)) == (x=3, y=2)
@test test_map[2,2] == 1
println(test_map)
@test count_painted(test_map) == 1

#test_robot_program()
#display(robot_state_machine(input_data))
offset_array = robot_state_machine(input_data, 1)
normal_array = offset_array.parent
drawArray(normal_array)
