import AoC2019
using LightGraphs, MetaGraphs


test_input = """
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL
"""

example_13312 = """
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
"""

function create_mapping(lines)
    mapping = Dict()
    names_set = Set{String}()
    min_produce = Dict("ORE" => 1)
    for line in lines
      if line == ""
        continue
      end
      entries = split(line, " => ")
      @assert length(entries) == 2
      inputs = split(entries[1], ", ")
      outputs = entries[2]
      out_count = split(outputs, " ")[1]
      out_name = split(outputs, " ")[2]
      push!(names_set, out_name)
      min_produce[out_name] = parse(UInt8, out_count)
      for inp in inputs
        inp_count = split(inp, " ")[1]
        inp_name = split(inp, " ")[2]
        mapping[(inp_name, out_name)] = parse(UInt8, inp_count)
        push!(names_set, inp_name)
      end
    end
    names=collect(names_set)
    min_produce_list = map(x -> min_produce[x], names)

    return (mapping=mapping, names=names, min_produce = min_produce_list)
end

lines = AoC2019.read_lines(".julia/dev/AoC2019/src/input14.txt")

function generate_fuel(lines, fuel_count=1)
  (mapping, names, min_produce) = create_mapping(lines) 
  #println(stderr, names)
  g = MetaDiGraph(length(names))

  for m in keys(mapping)
    #add_edge!(g, findfirst(isequal())
    inp_ind = findfirst(isequal(m[1]), names)
    out_ind = findfirst(isequal(m[2]), names)

    add_edge!(g, inp_ind, out_ind)
    set_props!(g, Edge(inp_ind, out_ind), Dict(:conv =>mapping[m]))

  end

  #start out with Fuel
  fuel_ind = findfirst(isequal("FUEL"), names)
  ore_ind = findfirst(isequal("ORE"), names)
  queue = Array{Tuple{Int64, Int64}, 1}()
  push!(queue, (fuel_count, fuel_ind))

  produced = zeros(Int64, length(names))
  remainder = zeros(Int64, length(names))

  while length(queue) > 0 
    current_node = popfirst!(queue)
    id = current_node[2]
    current_required = current_node[1]
    extra_required = current_required - remainder[id]
    neighbors = inneighbors(g, current_node[2])

    producing = convert(Int64, ceil(extra_required / min_produce[id])) * min_produce[id]
    remainder[id] = (producing - extra_required)
    #println("Current: $(names[id]), current_required: $current_required, extra_required: $extra_required, producing: $producing")
    
    produced[id] += producing 

    for n in neighbors
      local conversion_rate = get_prop(g, Edge(n, current_node[2]), :conv)
      #remainder = current_required - producing
      local new_val = producing / min_produce[id] * conversion_rate
      push!(queue, (new_val, n))

    end
  end
  queue_converted = map(x -> (x[1], names[x[2]]), queue)
  #for (i, name) in enumerate(names)
  #  println("Resource $name generated $(produced[i]) times")
  #end
  #for (i, name) in enumerate(names)
  #  println("Resource $name wasted $(remainder[i]) times")
  #end
  return produced[ore_ind]
end

#ore_required = generate_fuel(split(test_input, "\n"))
ore_required = generate_fuel(lines)
