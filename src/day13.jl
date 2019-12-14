#include("./computer.jl")
import AoC2019

mutable struct BoardState
  dims
  my_display::Array{Int8, 2}
  current_score
end

function update_board_state!(state, x, y, arg)
  if x == -1 && y == 0
      state.current_score = arg 
  else
    state.my_display[y+1, x+1] = arg
  end
end

function move_controller(state)
  the_ball = findfirst(x -> (x == 4), state.my_display)
  the_pad = findfirst(x -> (x == 3), state.my_display)
  #println(the_ball)
  #println(the_pad)
  direction = pseudoNormalize(the_ball[2] - the_pad[2])
  #println(stderr, direction)
  return direction 
end

function draw_state(state)
  color_map = Dict(0 => ' ', 1 => 'w', 2 => 'b', 3 => '-', 4 => 'o')
  println(AoC2019.visualizeArray(state.my_display, color_map))
end

function arcade_cabinet(input_data)

  game_input = Channel{Int64}()
  game_output = Channel{Int64}()
  #dims = (24, 42)
  dims = (60, 60)
  my_display = zeros(Int8, dims...)
  current_score = 0

  state = BoardState((50,50), my_display, current_score)
  input_data[1] = 2
  condition=Condition()

  @sync begin
    my_program = @async AoC2019.run_program_async(input_data, game_input, game_output; condition=condition)

    @async while true
      #println(stderr, "Reading X")

      x = take!(game_output)
      #println(stderr, "Reading Y")
      y = take!(game_output)
      #println(stderr, "Reading Arg")
      arg = take!(game_output)
      #println(stderr, "X: $x, Y: $y, arg: $arg")
      #println(stderr, "X == -1: $(x == -1)")
      update_board_state!(state, x, y, arg)
      #      #display(plot!(state.my_display))
    end
    @async while true
      try
        wait(condition)
        draw_state(state)
        sleep(0.033)
        direction = move_controller(state)
        put!(game_input, direction)
        yield()
      catch 
        break
      end
    end
  end

  println("Game finished")
  draw_state(state)

  return state.current_score
end

input_data = read_numbers("src/input13.txt")
println("Good luck")
out = arcade_cabinet(input_data)
println(out)

