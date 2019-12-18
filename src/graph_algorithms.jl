function bfs_depth(input_data, start_position, go_condition, stop_condition=(x->false))
  status = zeros(Int32, size(input_data)...)
  queue::Array{NamedTuple{(:position, :depth),Tuple{Tuple{Int64,Int64}, Int32}},1} = []
  push!(queue, (position=start_position, depth=0))
  while length(queue) > 0
    (position, depth) = popfirst!(queue)
    #println(position)
    if status[position...] != 0
      continue
    end
    status[position...] = depth
    if ! stop_condition(input_data[position...])
      for movement in [(-1,0), (1,0), (0,-1), (0,1)]
        new_pos = position .+ movement
        if go_condition(input_data[new_pos...]) 
          push!(queue, (position=new_pos, depth=depth + 1))
        end
      end
    end
  end
  return status
end

