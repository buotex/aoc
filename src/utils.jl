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

function drawArray(array)
  dims = size(array)
  local arr = map(x -> Dict(255 => ' ', 0=> ' ', 1 => '■')[x], array)
  for i in 1:dims[1]
    for j in 1:dims[2]
      print(arr[i,j])
    end
    print('\n')
  end
end

