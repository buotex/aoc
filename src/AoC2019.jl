module AoC2019
include("./computer.jl")
export run_program
export run_program_async
include("./day13.jl")
export draw_arcade

function read_numbers(filename)
  input_data = open(filename) do file
    data = readline(file)
    entries = split(data, ",")
    numbers = map(x->parse(Int64, x), entries)
    return numbers
  end
end
export read_numbers

function read_lines(filename)
  input_data = open(filename) do file
      data = readlines(file)
      return data
  end
end
export read_lines

function read_strings()
  input_data = open(filename) do file
      data = readlines(file)
      entries = map(x -> split(x, ","), data)
      return entries
  end
end
export read_strings

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
export read_numbers_lines

function matlab2c(image, width, height)
  return transpose(reshape(image, width, height))
end
export matlab2c

function drawArray(array, mapping)
  dims = size(array)
  local arr = map(x -> mapping[x], array)
  for i in 1:dims[1]
    for j in 1:dims[2]
      print(arr[i,j])
    end
    print('\n')
  end
end

export drawArray

end # module
