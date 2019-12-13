#include("./computer.jl")
using OffsetArrays

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

function simulate_arcade(data)
  dims = (50,50)
  my_display = zeros(Int16, dims...)
  current_score = 0
  for i in 1:3:length(data)
    if data[i] == -1
      current_score = data[i+2]
      continue
    end
    my_display[data[i+1]+1, data[i]+1] = data[i+2]
  end
  return (display=my_display, score=current_score)
end


function arcade_cabinet(input_data)
  output = run_program(input_data, input=[1])#rand(-1:1, 1000000))
  print(output.output)
  simulation = simulate_arcade(output.output)
  println(count( x -> (x == 2), simulation.display))
  return simulation.display
  
end

