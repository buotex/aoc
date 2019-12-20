import AoC2019
using Test
using LightGraphs, SimpleWeightedGraphs
#using Plots
input_data = read(open("input20.txt"), String)
test_input = """
         A           
         A           
  #######.#########  
  #######.........#  
  #######.#######.#  
  #######.#######.#  
  #######.#######.#  
  #####  B    ###.#  
BC...##  C    ###.#  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE..#######...###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       
"""
test_input2 = """
                   A               
                   A               
  #################.#############  
  #.#...#...................#.#.#  
  #.#.#.###.###.###.#########.#.#  
  #.#.#.......#...#.....#.#.#...#  
  #.#########.###.#####.#.#.###.#  
  #.............#.#.....#.......#  
  ###.###########.###.#####.#.#.#  
  #.....#        A   C    #.#.#.#  
  #######        S   P    #####.#  
  #.#...#                 #......VT
  #.#.#.#                 #.#####  
  #...#.#               YN....#.#  
  #.###.#                 #####.#  
DI....#.#                 #.....#  
  #####.#                 #.###.#  
ZZ......#               QG....#..AS
  ###.###                 #######  
JO..#.#.#                 #.....#  
  #.#.#.#                 ###.#.#  
  #...#..DI             BU....#..LF
  #####.#                 #.#####  
YN......#               VT..#....QG
  #.###.#                 #.###.#  
  #.#...#                 #.....#  
  ###.###    J L     J    #.#.###  
  #.....#    O F     P    #.#...#  
  #.###.#####.#.#####.#####.###.#  
  #...#.#.#...#.....#.....#.#...#  
  #.#####.###.###.#.#.#########.#  
  #...#.#.....#...#.#.#.#.....#.#  
  #.###.#####.###.###.#.#.#######  
  #.#.........#...#.............#  
  #########.###.###.#############  
           B   J   C               
           U   P   P               """

test_input3 = """
             Z L X W       C                 
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M                     """



function find_token(arr, position)
  dims = size(arr)
  pos_vectors = [CartesianIndex(0,1), CartesianIndex(1,0)]
  neg_vectors = [CartesianIndex(0,-1), CartesianIndex(-1,0)]
  token = ""
  for vec in pos_vectors
    if isuppercase(arr[(position + vec)])
      token = arr[(position + vec)] * arr[(position + 2 * vec)]
    end
  end
  for vec in neg_vectors
    if isuppercase(arr[(position + vec)])
      token = arr[(position + 2 * vec)] * arr[(position + vec)]
    end
  end
  if token != ""
    if position[1] == 3 || position[1] == dims[1] - 2 || position[2] == 3 || position[2] == dims[2] - 2
      return (token, false)
    else
      return (token, true)
    end
  end
  return ("", false)
end

function convert_labyrinth(arr)
  found_symbols_offset = 2
  lookup_table = Dict("" => 1)
  dims = size(arr)
  labyrinth_int = zeros(Int16, dims...)

  for x = 3:dims[1]-2
    for y = 3:dims[2]-2
      if arr[x,y] == '.'
        (token, inside) = find_token(arr, CartesianIndex(x,y)) 
        if token ∉ keys(lookup_table)
          lookup_table[token] = found_symbols_offset
          found_symbols_offset += 1
        end
        if ! inside
          labyrinth_int[x,y] = lookup_table[token]
        else
          labyrinth_int[x,y] = lookup_table[token] + 100
        end

      end
    end
  end
  return (labyrinth=labyrinth_int, tokens=lookup_table)
end


function create_edges(input_data, tok)
  reverse_tok= Dict(value => key for (key, value) in tok)
  mapping = Dict()
  tokens = unique(input_data)
  println(tokens)
  
  for i in tokens
    if i ∉ [0,1]
      start_pos = findfirst(x -> x == i, input_data)
      distances = AoC2019.bfs_depth(input_data, start_pos, x -> x != 0)
      portal_map = map(x -> x ∉ [0,1,i], input_data)
      distances .*= portal_map
      target_positions = findall(x -> x != 0, distances)
      for target_pos in target_positions
        mapping[(i, input_data[target_pos])] = distances[target_pos]
      end
      #println(reverse_tok[rem(i,100)])
      if reverse_tok[rem(i, 100)] ∉ ["AA", "ZZ"]
        other_token = (i < 100) ? i + 100 : i - 100
        #println(other_token)
        mapping[(i, other_token)] = 1
        mapping[(other_token, i)] = 1
      end
      # find all paths
    end
  end
  return mapping
end

function debug_labyrinth(arr, status, mapping)
  for current_counter = 1:maximum(status)
    pos = findfirst(x-> x == current_counter, status)
    if arr[pos] ∉ [0,1]
      suffix = (arr[pos] < 100) ? "_i" : "_o"
      println("Portal: $(mapping[rem(arr[pos], 100)])$(suffix)" )
    end
  end
end
function workflow(text)
  labyrinth_arr = AoC2019.text2arr(text)
  (lab, tok) = convert_labyrinth(labyrinth_arr)
  println(lab)
  println(tok)
  println(unique(lab))
  status = bfs_depth_warping(lab, findfirst(x -> x == tok["AA"], lab), x-> x == (tok["ZZ"]))
  reverse_mapping = Dict(value => key for (key, value) in tok)
  debug_labyrinth(lab, status, reverse_mapping)
  return maximum(status)
end

function workflow_dijkstra(text)
  labyrinth_arr = AoC2019.text2arr(text)
  (lab, tok) = convert_labyrinth(labyrinth_arr)
  distances = create_edges(lab, tok)
  println(distances)
  shortest_distances = AoC2019.dijkstra(distances, tok["AA"])
  return shortest_distances[tok["ZZ"]]
end


function workflow_recursive_dijkstra(text, do_recursive=true)
  labyrinth_arr = AoC2019.text2arr(text)
  (lab, tok) = convert_labyrinth(labyrinth_arr)
  println(tok)
  reverse_tok = Dict(value => key for (key, value) in tok)

  distances = create_edges(lab, tok)
  mg = AoC2019.generate_distance_graph(distances)

  if do_recursive
    lab_outer = deepcopy(lab)
    lab_inner = deepcopy(lab)

    lab_outer[findall(x -> x ∉ [tok["AA"], tok["ZZ"], 0, 1] && x < 100, lab_outer)] .= 0
    lab_inner[findall(x -> x in [tok["AA"], tok["ZZ"]], lab_inner)] .= 0

    distances_outer = create_edges(lab_outer, tok)
    #println(distances_outer)
    distances_inner = create_edges(lab_inner, tok)
    println("creating outer edges")
    mg_outer = AoC2019.generate_distance_graph(distances_outer)
    println(mg_outer)
    println(mg_outer.weights[113,13])
    println("creating inner edges")
    mg_inner = AoC2019.generate_distance_graph(distances_inner)
    println(mg_inner)
  end

  ind_beg = tok["AA"]
  ind_end = tok["ZZ"]

  heap = []
  push!(heap, (ind_beg, 0, 0, (ind_beg, 0, 0)))
  predecessors = Dict()

  while length(heap) > 0
    (index, num_steps, depth, pred) = popfirst!(heap) 
    if (index, depth) in keys(predecessors)
      continue
    end
    predecessors[(index, depth)] = pred
    #println("$(reverse_tok[rem(index, 100)]), $num_steps, $depth")
    if index == ind_end
      return (steps=num_steps, pred=predecessors, tok=tok, mg_outer=mg_outer, mg_inner=mg_inner)
    end
    if do_recursive
      if depth > 0
        mg = mg_inner
      else 
        mg = mg_outer
      end
    end
    for neighbor in outneighbors(mg, index)
      new_num_steps = num_steps + mg.weights[index, neighbor]
      if mg.weights[index, neighbor] == 0
        #error("$index, $neighbor has weight 0")
      end
      #if neighbor == 13
      #  println(mg.weights[index, neighbor])
      #  println(depth)
      #  break
      #end
      dist = neighbor - index
      if dist == 100
        new_depth = depth - 1
      elseif dist == -100
        new_depth = depth + 1
      else
        new_depth = depth
      end
      if do_recursive
        push!(heap, (neighbor, new_num_steps, new_depth, (index, depth, Int(mg.weights[index, neighbor]))))
      else
        push!(heap, (neighbor, new_num_steps, depth, (index, depth, Int(mg.weights[index, neighbor]))))
      end
    end
    sort!(heap, by=x->x[2])

  end
  error("Path not found")
end


function print_predecessors(predecessors, start, tok)
  #println(predecessors)
  reverse_tok = Dict(value => key for (key, value) in tok)
  current_node = (start, 0)
  while true
    #println(current_node)
    if reverse_tok[rem(current_node[1], 100)] == "AA"
      break
    end
    current_node = predecessors[current_node[1], current_node[2]]
    nodename = reverse_tok[rem(current_node[1], 100)]
    suffix = (current_node[1] < 100) ? "_o" : "_i"
    println("node: $(nodename)$(suffix), depth=$(current_node[2]), steps=$(current_node[3])")
  end
end



#@test workflow_dijkstra(test_input) == 23
#@test workflow_recursive_dijkstra(test_input, false).steps == 23
##@test workflow(test_input) == 23
#@test workflow_recursive_dijkstra(test_input2, false).steps == 58
#@test workflow_recursive_dijkstra(test_input, true).steps == 26
#@test workflow_recursive_dijkstra(test_input3, true).steps == 396
results = workflow_recursive_dijkstra(test_input3, true)
#print_predecessors(results.pred, results.tok["ZZ"], results.tok)

#results = workflow_recursive_dijkstra(input_data, true)
print_predecessors(results.pred, results.tok["ZZ"], results.tok)
#status = workflow(input_data)
