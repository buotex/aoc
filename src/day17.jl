import AoC2019
input_data = AoC2019.read_numbers("input17.txt")

out = AoC2019.run_program(input_data)

out_string = map(x -> Char(x), out.output)
arr = AoC2019.text2arr(out_string)
println(AoC2019.arr2text(arr))

function find_intersections(arr)
  intersections = []
  dims = size(arr)
  for x=2:dims[1]-1
    for y=2:dims[2]-1
      if arr[x,y] == '#' && arr[x+1, y] == '#' && arr[x-1,y] == '#' && arr[x,y+1] == '#' && arr[x,y-1] == '#'
        push!(intersections, (x,y))
      end
    end
  end
  alignments = map(x -> (x[1]-1) * (x[2]-1), intersections)
  return sum(alignments)
end
find_intersections(arr)

inst_A = map(x->Int(x), collect("L,6,R,8,L,4,R,8,L,12"))
inst_B = map(x->Int(x), collect("L,12,L,6,L,4,L,4"))
inst_C = map(x->Int(x), collect("L,12,R,10,L,4"))
moves = map(x->Int(x), collect("A,C,C,B,C,B,C,B,A,A"))
robot_input = vcat(moves, 10, inst_A, 10, inst_B, 10, inst_C, 10, Int('n'), 10)

println(robot_input)

input_data[1] = 2
out = AoC2019.run_program(input_data, input=robot_input)
