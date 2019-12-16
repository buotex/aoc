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
    i-1 > length_of_input && break
    i == 1 && continue
    multipliers[i-1] = v
  end
  return multipliers
end


@test generate_multipliers(1, 8) == [1,0,-1,0,1,0,-1,0]
@test generate_multipliers(2, 8) == [0,1,1,0,0,-1,-1,0]
@test generate_multipliers(8, 8) == [0,0,0,0,0,0,0,1]

function get_digit(input, multipliers)::Int8
  digit::Int8 = 0
  println(multipliers)
  for (i, m) in zip(input, multipliers)
    digit += (i * m)
    digit %= 10
  end
  return abs(digit)
end

function fft_step(input)
  new_digits = Array{Int8, 1}(undef, length(input))
  for (i, digit) in enumerate(input)
    multipliers = generate_multipliers(i, length(input))
    new_digits[i] = get_digit(input, multipliers)
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

test_input1 = Int8[1,2,3,4,5,6,7,8]
@test fft_step(test_input1) == Int8[4,8,2,2,6,1,5,8]
@test my_fft(test_input1, 4) == Int8[0,1,0,2,9,4,9,8]
test_input2 = Int8[8,0,8,7,1,2,2,4,5,8,5,9,1,4,5,4,6,6,1,9,0,8,3,2,1,8,6,4,5,5,9,5]
my_fft(test_input2, 1)
#my_fft(input_data, 1)
