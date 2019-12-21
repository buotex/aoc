using Test
import AoC2019


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

testdata6 = 
"""#######
#a.#Cd#
##@#@##
#######
##@#@##
#cB#Ab#
#######"""

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

function generate_combinations(items, num_samples)
  combinations = collect(Iterators.product((items for i=1:num_samples)...))
  combinations = filter((x->allunique(x)), combinations)
  combinations = map(x->Tuple(sort!(collect(x))), combinations)
  return unique(combinations)
end

function do_labyrinth(arr)
  queue = []
  #start_pos = findall(x -> x == '@', arr)
  start_pos = findfirst(x -> x == '@', arr)
  num_robots = length(start_pos)
  #println(start_pos)
  number_of_keys = length(filter(x->islowercase(x), arr))
  println("Number of keys: $number_of_keys")
  stack = [(start_pos=start_pos, found_keys = [], steps_done = 0)]
  counter = 0
  #combinations = generate_combinations('a':'z', num_robots)
  #known_paths = Dict(x => Set() for x in combinations)
  known_paths = Dict(x => Set() for x in 'a':'z')
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
    sort!(stack, by=x->x.steps_done, rev=true)
    counter += 1
    println(max_length)
  end
end

function multiply_robots!(arr)
  start_pos = Tuple(findfirst(x -> x == '@', arr))
  arr[start_pos...] = '#'
  for movement in [(-1,0), (1,0), (0,-1), (0,1)]
    new_pos = start_pos .+ movement
    arr[new_pos...] = '#'
  end
  for movement in [(-1,-1), (1,1), (1,-1), (-1,1)]
    new_pos = start_pos .+ movement
    arr[new_pos...] = '@'
  end
  return arr
end

function do_labyrinth_multiple(arr)
  queue = []
  start_pos = map(x -> Tuple(x), findall(x -> x == '@', arr))
  #start_pos = findfirst(x -> x == '@', arr)
  num_robots = length(start_pos)
  #println(start_pos)
  number_of_keys = length(filter(x->islowercase(x), arr))
  println("Number of keys: $number_of_keys")
  stack = [(start_pos=start_pos, found_keys = [], steps_done = 0)]
  counter = 0
  #combinations = generate_combinations('a':'z', num_robots)
  #known_paths = Dict(x => Set() for x in combinations)
  known_paths = Dict(x => Set() for x in 'a':'z')
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
    for (i, robot_pos) in enumerate(start_pos)
      paths = search_labyrinth(arr, robot_pos, found_keys)
      indices = findall(x -> x != 0, paths)
      for index in indices
        #new_start_pos = index
        new_start_pos = vcat(start_pos[1:i-1], start_pos[i+1:end], [index])
        new_found_keys = push!(copy(found_keys), arr[index])
        new_steps_done = steps_done + paths[index]
        push!(stack, (start_pos=new_start_pos, found_keys=new_found_keys, steps_done=new_steps_done))
      end
    end
    sort!(stack, by=x->x.steps_done, rev=true)
    println(max_length)
  end
end
@test do_labyrinth(AoC2019.text2arr(testdata1)) == 8
@test do_labyrinth(AoC2019.text2arr(testdata2)) == 86
@test do_labyrinth(AoC2019.text2arr(testdata3)) == 132
@test do_labyrinth(AoC2019.text2arr(testdata4)) == 136
@test do_labyrinth(AoC2019.text2arr(testdata5)) == 81
#steps_done = do_labyrinth(labyrinth_arr)
#steps_done = do_labyrinth_multiple(AoC2019.text2arr(testdata6))

input_data = read(open("input18.txt"), String)
labyrinth_arr = AoC2019.text2arr(input_data)

labyrinth_arr = multiply_robots!(labyrinth_arr)
steps_done = do_labyrinth_multiple(labyrinth_arr)
println(steps_done)

