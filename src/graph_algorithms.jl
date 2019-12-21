using LightGraphs, SimpleWeightedGraphs

function bfs_depth(input_data, start_position, go_condition, stop_condition=(x->false))
  status = zeros(Int32, size(input_data)...)
  queue::Array{NamedTuple{(:position, :depth),Tuple{CartesianIndex, Int32}},1} = []
  if typeof(start_position) <: Tuple
    start_position = CartesianIndex(start_position)
  end
  push!(queue, (position=start_position, depth=0))
  while length(queue) > 0
    (position, depth) = popfirst!(queue)
    #println(position)
    if status[position] != 0
      continue
    end
    status[position] = depth
    if ! stop_condition(input_data[position])
      for movement in [CartesianIndex(-1,0), CartesianIndex(1,0), CartesianIndex(0,-1), CartesianIndex(0,1)]
        new_pos = position + movement
        if go_condition(input_data[new_pos]) 
          push!(queue, (position=new_pos, depth=depth + 1))
        end
      end
    end
  end
  return status
end

function generate_distance_graph(distances)
  println("distances: $distances")
  tokens = keys(distances)
  my_tokens = Set()
  for token in tokens
    push!(my_tokens, token[1])
    push!(my_tokens, token[2])
  end
  #g = path_graph(maximum(my_tokens))
  mg = SimpleWeightedDiGraph(maximum(my_tokens))
  for token in tokens
    println("Adding: $(token[1]), $(token[2]), $(distances[token])")
    add_edge!(mg, token[1], token[2], distances[token])
  end
  return mg
end

function dijkstra(distances, start_token)
  mg = generate_distance_graph(distances)

  ds = dijkstra_shortest_paths(mg, start_token)
  println(ds.dists)
  
  return ds.dists

end
