using Test
import AoC2019

input_data = AoC2019.read_chars("./input16.txt")


function generate_multipliers(phase, length_of_input)
  base_pattern = Int8[0,1,0,-1]
  multipliers = zeros(Int8, length_of_input)
  stretched_pattern = Iterators.flatten(map(x -> Iterators.repeated(x, phase), base_pattern))
  whole_pattern = Iterators.cycle(stretched_pattern)
  #skip first
  for (i, v) in enumerate(whole_pattern)
    i == 1 && continue
    multipliers[i-1] = v
    i > length_of_input && break
  end
  return multipliers
end


@test generate_multipliers(1, 8) == [1,0,-1,0,1,0,-1,0]
@test generate_multipliers(2, 8) == [0,1,1,0,0,-1,-1,0]
@test generate_multipliers(8, 8) == [0,0,0,0,0,0,0,1]

function get_digit(input, num_entry::Int64)

  base_pattern = Int8[0,1,0,-1]

  digit::Int64 = 0
  #println(multipliers)
  for i in 1:num_entry
    digit += sum(input[i-1+num_entry:4*num_entry:end])
    digit -= sum(input[i-1+num_entry + 2*num_entry:4*num_entry:end])

  end
  return abs(digit % 10)
end

function fft_step(input)
  new_digits = Array{Int8, 1}(undef, length(input))
  for (i, digit) in enumerate(input)
    new_digits[i] = get_digit(input, i)
  end
  return new_digits 
end

function my_fft(initial_input::Array{Int8, 1}, num_phases::Int64)
  # generate multipliers
  
  for i in 1:num_phases
    initial_input = fft_step(initial_input)
  end
  return initial_input
end

function my_fft_big(initial_input::Array{Int8, 1}, num_phases::Int64, replication_factor::Int64)
  my_big_input = collect(Iterators.flatten(Iterators.repeated(initial_input, replication_factor)))
  for i in 1:num_phases
    println("Iteration: $i")
    my_big_input = fft_step(my_big_input)
    println(my_big_input)
  end
  return my_big_input 
end

test_input1 = Int8[1,2,3,4,5,6,7,8]
@test fft_step(test_input1) == Int8[4,8,2,2,6,1,5,8]
@test my_fft(test_input1, 4) == Int8[0,1,0,2,9,4,9,8]
test_input2 = Int8[8,0,8,7,1,2,2,4,5,8,5,9,1,4,5,4,6,6,1,9,0,8,3,2,1,8,6,4,5,5,9,5]
test_input3 = Int8[1,9,6,1,7,8,0,4,2,0,7,2,0,2,2,0,9,1,4,4,9,1,6,0,4,4,1,8,9,9,1,7]
@test my_fft(test_input2, 100)[1:8] == [2,4,1,7,6,1,7,6]
my_fft(input_data, 100)
#my_fft_big(input_data, 100, 1)
#@assert my_fft(input_data, 100) == my_fft_big(input_data, 100,1)

#test_input4 = Int8[0,3,0,3,6,7,3,2,5,7,7,2,1,2,9,4,4,0,6,3,4,9,1,5,6,5,4,7,4,6,6,4]
#test_input5 = Int8[1,2,3,4,5,6]
#@assert my_fft_big(input_data, 1, 2)[303673+1:313673+8] == [8,4,4,6,2,0,2,6]


