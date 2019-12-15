module AoC2019

include("./computer.jl")

using OffsetArrays
using Logging
logger = SimpleLogger(stderr, Logging.Debug)
global_logger(logger)

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

function read_strings()
  input_data = open(filename) do file
      data = readlines(file)
      entries = map(x -> split(x, ","), data)
      return entries
  end
end

function read_numbers_lines()
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

end # module
