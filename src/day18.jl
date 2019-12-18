using Test
import AoC2019

input_data = read(open("input18.txt"), String)

function text2arr(input_data)::Array{Char, 2}
  line_length = findfirst(x -> (x == '\n'), input_data) - 1
  input_data_filtered = collect(filter(x -> x != '\n', input_data))
  reshaped = reshape(input_data_filtered, line_length, :)
  return permutedims(reshaped) 
end
labyrinth_arr = text2arr(input_data)
function arr2text(arr)
  (x_dim, y_dim) = size(arr)
  output_str = ""
  for x in 1:x_dim
    for y in 1:y_dim
      output_str *= arr[x,y]
    end
    output_str *= '\n'
  end
  return output_str
end


testdata1 = 
"""#########
#b.A.@.a#
#########"""

testdata2 = 
"""########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################"""
testdata3 = 
"""########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################"""
testdata4 = 
"""#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################"""
testdata5 = 
"""########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################"""

function can_pass(x, keys = [])
  if x == '.'
    return true
  elseif x == '@'
    return true
  elseif islowercase(x)
    return true
  elseif lowercase(x) in keys
    return true
  else
    return false
  end
end


function search_labyrinth(labyrinth_arr, start_pos, keys = [])
  paths = AoC2019.bfs_depth(labyrinth_arr, start_pos, x -> can_pass(x, keys))
  key_filter = map(x -> islowercase(x) && x ∉ keys , labyrinth_arr)
  paths .*= key_filter
  return paths
end


function do_labyrinth(arr)
  queue = []
  start_pos = findfirst(x -> x == '@', arr)
  println(start_pos)
  number_of_keys = length(filter(x->islowercase(x), arr))
  println("Number of keys: $number_of_keys")
  stack = [(start_pos=start_pos, found_keys = [], steps_done = 0)]
  counter = 0
  known_paths = Dict(x => Set() for x in 'a':'z')
  #Set{Array{Char, 1}}()
  max_length = 0
  while length(stack) > 0
    @label start
    (start_pos, found_keys, steps_done) = pop!(stack)
    if length(found_keys) > max_length
      max_length = length(found_keys)
    end
    if length(found_keys) > 0
      dict_entry = sort!(found_keys[1:end-1])
      for entry in known_paths[found_keys[end]]
        if intersect(entry, dict_entry) == dict_entry
          @goto start
        end
      end
      push!(known_paths[found_keys[end]], dict_entry)
    end
    #println(length(known_paths))
    if length(found_keys) == number_of_keys
      return steps_done
    end
    paths = search_labyrinth(arr, start_pos, found_keys)
    indices = findall(x -> x != 0, paths)
    for index in indices
      new_start_pos = index
      new_found_keys = push!(copy(found_keys), arr[index])
      new_steps_done = steps_done + paths[index]
      push!(stack, (start_pos=new_start_pos, found_keys=new_found_keys, steps_done=new_steps_done))
    end
    #println(stack)
    sort!(stack, by=x->x.steps_done, rev=true)
    #println(stack)
    counter += 1
    println(max_length)
    #if counter > 20
      #println(known_paths)
      #break
    #end
  end
end
#@test do_labyrinth(text2arr(testdata1)) == 8
#@test do_labyrinth(text2arr(testdata2)) == 86
#@test do_labyrinth(text2arr(testdata3)) == 132
#@test do_labyrinth(text2arr(testdata4)) == 136
#@test do_labyrinth(text2arr(testdata5)) == 81
#steps_done = do_labyrinth(labyrinth_arr)



