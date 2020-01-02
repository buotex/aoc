module AoC2019

include("./computer.jl")
include("./graph_algorithms.jl")


function read_numbers(filename)
  input_data = open(filename) do file
    data = readline(file)
    entries = split(data, ",")
    numbers = map(x->parse(Int64, x), entries)
    return numbers
  end
end

function read_lines(filename)
  input_data = open(filename) do file
      data = readlines(file)
      return data
  end
end

function read_strings(filename)
  input_data = open(filename) do file
      data = readlines(file)
      entries = map(x -> split(x, ","), data)
      return entries
  end
end

function read_numbers_lines(filename)
  input_data = open(filename) do file
    all_numbers = Int64[]
    data = readlines(file)
    for line in data
        entries = collect(line)
        numbers = map(x->parse(Int64, x), entries)
        append!(all_numbers, numbers)
    end
    return all_numbers
  end
end

function read_chars(filename)
  input_data = open(filename) do file
    all_numbers = Int8[]
    while !eof(file)
      c = read(file, Char)
      if c == '\n'
        continue
      end
      digit = parse(Int8, c) 
      push!(all_numbers, digit)
    end
    return all_numbers
  end
end


function matlab2c(image, width, height)
  return transpose(reshape(image, width, height))
end

function visualizeArray(array, mapping)
  my_string = ""
  dims = size(array)
  local arr = map(x -> mapping[x], array)
  for i in 1:dims[1]
    for j in 1:dims[2]
      my_string *= arr[i,j]
    end
    my_string *= '\n'
  end
  return my_string
end

function pseudoNormalize(x::T)::Int32 where T<:Number
  if x > 0
    return 1
  elseif x < 0
    return -1
  else 
    return 0
  end
end

function arr2text(arr)
  (x_dim, y_dim) = size(arr)
  output_str = ""
  for x in 1:x_dim
    for y in 1:y_dim
      output_str *= arr[x,y]
    end
    output_str *= '\n'
  end
  return output_str[1:end-1]
end

function text2arr(input_data)::Array{Char, 2}
  line_length = findfirst(x -> (x == '\n'), input_data) - 1
  input_data_filtered = collect(filter(x -> x != '\n', input_data))
  reshaped = reshape(input_data_filtered, line_length, :)
  return permutedims(reshaped) 
end

end # module
