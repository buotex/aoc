using Plots
gr()
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

function move_robot!(state, command, result)
  println("moving robot")
  if command == 1
    position_aimed = state.current_position .+ (-1, 0)
  elseif command == 2
    position_aimed = state.current_position .+ (1, 0)
  elseif command == 3
    position_aimed = state.current_position .+ (0, -1)
  elseif command == 4
    position_aimed = state.current_position .+ (0, 1)
  else
    error("Not implemented")
  end
  if result == 0
    state.labyrinth[position_aimed...] = 3
    # say that this way is bad
  elseif result == 1 || result == 2
    # take over state of previous way for previous direction
    state.labyrinth[state.current_position...] = 1
    state.current_position = position_aimed
    if result == 2
      state.labyrinth[position_aimed...] = 2
    end
  end
end


function generate_directions!(state, stack, steps_done)
  reverse_direction = Dict(1 => 2, 2 => 1, 3 => 4, 4 => 3)
  for i in 1:4
    if i == 1
      position_aimed = state.current_position .+ (-1, 0)
    elseif i == 2
      position_aimed = state.current_position .+ (1, 0)
    elseif i == 3
      position_aimed = state.current_position .+ (0, -1)
    elseif i == 4
      position_aimed = state.current_position .+ (0, 1)
    end
    if state.labyrinth[position_aimed...] == 1
      continue
    end
    push!(stack, (reverse_direction[i], steps_done))
    push!(stack, (i, steps_done + 1))
  end
  state.labyrinth[state.current_position...] = 1

end

function robot_searcher(input_data)

  robot_input = Channel{Int64}()
  robot_output = Channel{Int64}()
  #dims = (24, 42)
  dims = (50, 50)
  labyrinth = zeros(Int8, dims...)
  current_score = 0
  current_position = dims .÷ 2
  labyrinth[current_position...] = 4

  state = BoardState(dims, labyrinth, dims .÷ 2)


  #commands = [(1,0), (4,1), (1,0), (2,0), (4,0), (3,1), (3,0), (2,1), (2,0), (3,2)]
  #  for command in commands
  #    move_robot(state, command...)
  #  end
  #  @sync begin
  #    draw_state(state)
  #  end

  stack::Array{Tuple{Int8, Int32}} = []
  generate_directions!(state, stack, 0)
  println("Let's start")
  position_goal = (0,0)
  steps_needed = -1
  @sync begin
    @async AoC2019.run_program_async(input_data, robot_input, robot_output)

    @async while true
      try
        # inputting random direction
        if length(stack) == 0
          state.labyrinth[position_goal...] = 2
          close(robot_input)
          break
        end
        command = pop!(stack)
        direction = command[1]
        steps_done = command[2]
        put!(robot_input, direction)
        # get result
        result = take!(robot_output)
        if result == 0
          #didn't move, remove backtrace as well
          pop!(stack)
        end
        move_robot!(state, direction, result)
        if state.labyrinth[state.current_position...] == 2
          #close(robot_input)
          position_goal = state.current_position
          steps_needed = steps_done
        end
        if state.labyrinth[state.current_position...] == 0
          generate_directions!(state, stack, steps_done)
        end

        state.labyrinth[state.current_position...] = 4

        println("Position of goal: $position_goal, steps_needed = $steps_needed")
        plt = heatmap(state.labyrinth, yflip=true)
        gui(plt)
        #draw_state(state)
      catch err
        close(robot_input)
        close(robot_output)
        rethrow(err)
      end
    end
  end
  return state.labyrinth
end

labyrinth = robot_searcher(input_data)
#oxygen_generator = findfirst(x -> x == 2, labyrinth)
#status = AoC2019.bfs_depth(labyrinth, oxygen_generator, x->!isequal(x, 3))
