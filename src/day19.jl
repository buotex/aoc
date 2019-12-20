using Test
using Logging
logger = SimpleLogger(stderr, Logging.Info)
global_logger(logger)

import AoC2019
using OffsetArrays
input_data = AoC2019.read_numbers("input19.txt")


function check_beam(input_data)

  dims = (20, 20)
  beam_map = OffsetArray(zeros(Int8, dims...), 0:dims[1]-1, 0:dims[2]-1)
  println("Let's start")

  min_x = OffsetVector(zeros(Int32, 1000), 0:999)
  max_x = OffsetVector(zeros(Int32, 1000), 0:999)
  max_x[0] = 1
  @test AoC2019.run_program(input_data, input=[0,0]).output[1] == 1

  for x in 0:dims[1]-1
    for y in 0:dims[2]-1
      beam_map[y, x] = AoC2019.run_program(input_data, input=[x,y]).output[1]
    end
  end

  y = 5
  min_x[4] = findfirst(x -> x == 1, beam_map[y, :])
  max_x[4] = findlast(x -> x == 1, beam_map[y, :]) + 1
  while y < 1000
    println(stderr, y)

    current_left_border = min_x[y-1] 
    current_right_border = max_x[y-1]
    println(stderr, "$current_left_border, $current_right_border")
    while AoC2019.run_program(input_data, input=[current_left_border,y]).output[1] == 0
      current_left_border += 1
    end
    min_x[y] = current_left_border
    while AoC2019.run_program(input_data, input=[current_right_border,y]).output[1] == 1
      println(stderr, "right border: $current_right_border")
      current_right_border += 1
    end
    max_x[y] = current_right_border

    #beam_map[y, current_left_border:current_right_border] .= 1
    #plt = heatmap(beam_map, yflip=true)
    #gui(plt)
    if y > 100
      println(stderr, "left border: $current_left_border")
      println(stderr, "Old y: $(y-99)")
      if max_x[y-99] - min_x[y] >= 100
        println("min_x: $(min_x[y]), max_x: $(max_x[y-99] - 1), min_y: $(y-99), max_y: $y")
        @assert AoC2019.run_program(input_data, input=[min_x[y],y-99]).output[1] == 1
        @assert AoC2019.run_program(input_data, input=[max_x[y-99]-1,y]).output[1] == 1
        @assert AoC2019.run_program(input_data, input=[max_x[y-99]-1,y-99]).output[1] == 1
        @assert AoC2019.run_program(input_data, input=[min_x[y],y]).output[1] == 1
        return (min_x[y] * 10000 + (y-99))
        break
      end
    end
    y += 1
  end
  return y
end
solution = check_beam(input_data)
