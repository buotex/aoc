import AoC2019
input_data = AoC2019.read_numbers("input15.txt")


mutable struct BoardState
  dims
  labyrinth::Array{Int8, 2}
  current_position::Tuple{Int16, Int16}
end

function draw_state(state)
  color_map = Dict(0 => ' ', 1 => '.', 2 => 'S', 3 => 'w', 4 => 'D')
  println(AoC2019.visualizeArray(state.labyrinth, color_map))
end

function move_robot(state, command, result)
  if command == 1
    position_aimed = state.current_position .+ (-1, 0)
  elseif command == 2
    position_aimed = state.current_position .+ (1, 0)
  elseif command == 3
    position_aimed = state.current_position .+ (0, -1)
  elseif command == 4
    position_aimed = state.current_position .+ (0, 1)
  end
  if result == 0
    state.labyrinth[position_aimed...] = 3
  elseif result == 1 || result == 2
    state.labyrinth[state.current_position...] = 1
    state.labyrinth[position_aimed...] = 4
    state.current_position = position_aimed
  end

end

function robot_searcher(input_data)

  game_input = Channel{Int64}()
  game_output = Channel{Int64}()
  #dims = (24, 42)
  dims = (50, 50)
  labyrinth = zeros(Int8, dims...)
  current_score = 0
  current_position = dims .÷ 2
  labyrinth[current_position...] = 4

  state = BoardState(dims, labyrinth, dims .÷ 2)
  condition=Condition()

  counter = 0
  commands = [(1,0), (4,1), (1,0), (2,0), (4,0), (3,1), (3,0), (2,1), (2,0), (3,2)]
#  for command in commands
#    move_robot(state, command...)
#  end
#  @sync begin
#    draw_state(state)
#  end
  @sync begin
    my_program = @async AoC2019.run_program_async(input_data, game_input, game_output; condition=condition)

    @async while true

    end
#    @async while true
#      try
#        wait(condition)
#        draw_state(state)
#        sleep(0.033)
#        direction = move_controller(state)
#        put!(game_input, direction)
#        yield()
#      catch 
#        break
#      end
#    end
  end
#
#  println("Game finished")
#  draw_state(state)

  return counter
end

robot_searcher(input_data)
