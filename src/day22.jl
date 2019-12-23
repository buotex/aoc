import AoC2019
using Test
task_commands = AoC2019.read_lines("input22.txt")
test_commands1 = """deal with increment 7
deal into new stack
deal into new stack
Result: 0 3 6 9 2 5 8 1 4 7"""
test_commands2 = """deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1"""


function do_commands_helper(commands; num_cards, track_card, do_reverse=false, iterations=1)::Array{Int128,1}
  current_num::Int128 = track_card
  operations = Int128[1,0]
  if do_reverse
    commands = reverse(commands)
  end
  for command in commands
    println(command)
    tokens = split(command)
    if tokens[1] == "deal"
      if tokens[2] == "into"
        current_num = (num_cards - 1) - current_num
        #current_num = mod(-current_num, num_cards)
        operations[2] = (num_cards -1) - operations[2]
        operations[1] *= -1
      elseif tokens[2] == "with"
        local N = parse(Int, tokens[4])
        if ! do_reverse
          current_num = mod(current_num * N, num_cards)
          operations .*= N
        else
          # find inverse to N mod num_cards
          N_inv = invmod(N, num_cards)
          current_num = mod(current_num * N_inv, num_cards)
          operations .*= N_inv
        end
      end
    elseif tokens[1] == "cut" 
      local N = parse(Int, tokens[2])
      if ! do_reverse
        current_num = mod(current_num - N, num_cards)
        operations[2] -= N
      else
        current_num = mod(current_num + N, num_cards)
        operations[2] += N
      end
    end
    operations = mod.(operations, num_cards)
    println("operations: $operations")
    println("Current_num: $current_num")
    current_num_alt = mod(track_card * operations[1] + operations[2], num_cards)
    println("current_num_alt: $current_num_alt")
  end
  #println(operations)
  return operations
end


function fast_exp(kernel_operation::Array{Int128, 1}; iterations::Int64, modulo::Int64)::Array{Int128, 1}
  binary = bitstring(iterations)
  combined_operation::Array{Int128, 1} = kernel_operation
  new_operation::Array{Int128, 1} = Int128[1,0]
  for entry in reverse(digits(iterations, base=2))[2:end]
    new_operation = copy(combined_operation)
    new_operation .*= combined_operation[1]
    new_operation[2] += combined_operation[2]
    new_operation = mod.(new_operation, modulo)
    if entry == 1
      new_operation .*= kernel_operation[1]
      new_operation[2] += kernel_operation[2]
    end
    new_operation = mod.(new_operation, modulo)
    combined_operation = new_operation
  end
  return map(x -> Int128(x), combined_operation)
end


@test fast_exp(Int128[2,1], iterations=Int64(2), modulo=Int64(50)) == [4,3]
@test fast_exp(Int128[2,1], iterations=Int64(3), modulo=Int64(50)) == [8,7]
@test fast_exp(Int128[2,1], iterations=Int64(4), modulo=Int64(50)) == [16,15]
@test fast_exp(Int128[2,2], iterations=Int64(2), modulo=Int64(50)) == [4, 6]
@test fast_exp(Int128[2,2], iterations=Int64(4), modulo=Int64(50)) == [16, 30]
@test fast_exp(Int128[2,2], iterations=Int64(3), modulo=Int64(50)) == [8,14]


function do_commands(commands; num_cards, track_card, do_reverse=false, iterations=1)::Int128
  operations::Array{Int128, 1} = do_commands_helper(commands, num_cards=num_cards, track_card=track_card, do_reverse=do_reverse, iterations=iterations)
  operations = fast_exp(operations, iterations=iterations, modulo=num_cards)
  println(operations)
  return mod(track_card * operations[1] + operations[2], num_cards)
end

task_result = do_commands(task_commands, num_cards=10007, track_card=2019, do_reverse=false)
@test task_result == 7860

@test do_commands(split(test_commands1, '\n'), num_cards=10, track_card=7) == 9
@test do_commands(split(test_commands1, '\n'), num_cards=10, track_card=9, do_reverse=true) == 7

test_result1 = do_commands(split(test_commands2, '\n'), num_cards=10007, track_card=2019, do_reverse=false)
test_result2 = do_commands(split(test_commands2, '\n'), num_cards=10007, track_card=test_result1, do_reverse=false)
test_result2_alt = do_commands(split(test_commands2, '\n'), num_cards=10007, track_card=2019, do_reverse=false, iterations=2)
@test test_result2 == test_result2_alt

test_result3 = do_commands(split(test_commands2, '\n'), num_cards=10007, track_card=test_result2, do_reverse=false)
test_result3_alt = do_commands(split(test_commands2, '\n'), num_cards=10007, track_card=2019, do_reverse=false, iterations=3)
@test test_result3 == test_result3_alt

test_result1_back = do_commands(split(test_commands2, '\n'), num_cards=10007, track_card=test_result2, do_reverse=true)
test_result0_back = do_commands(split(test_commands2, '\n'), num_cards=10007, track_card=test_result1_back, do_reverse=true)
@test test_result0_back == 2019


iterations= 101741582076661
num_cards = 119315717514047


task_operations_1 = do_commands(task_commands, num_cards=119315717514047, track_card=2020, do_reverse=true, iterations=1)
task_operations_2 = do_commands(task_commands, num_cards=119315717514047, track_card=task_operations_1, do_reverse=true, iterations=1)
task_operations_2_alt = do_commands(task_commands, num_cards=119315717514047, track_card=2020, do_reverse=true, iterations=2)
@test task_operations_2 == task_operations_2_alt

task_operations_3 = do_commands(task_commands, num_cards=119315717514047, track_card=task_operations_2, do_reverse=true, iterations=1)
task_operations_3_alt = do_commands(task_commands, num_cards=119315717514047, track_card=2020, do_reverse=true, iterations=3)
@test task_operations_3 == task_operations_3_alt
task_operations_4 = do_commands(task_commands, num_cards=119315717514047, track_card=task_operations_3, do_reverse=true, iterations=1)
task_operations_4_alt = do_commands(task_commands, num_cards=119315717514047, track_card=2020, do_reverse=true, iterations=4)
@test task_operations_4 == task_operations_4_alt
task_operations_7 = do_commands(task_commands, num_cards=119315717514047, track_card=task_operations_4, do_reverse=true, iterations=3)
task_operations_7_alt = do_commands(task_commands, num_cards=119315717514047, track_card=2020, do_reverse=true, iterations=7)
@test task_operations_7 == task_operations_7_alt
task_operations_0_back = do_commands(task_commands, num_cards=119315717514047, track_card=task_operations_7, do_reverse=false, iterations=7)
@test task_operations_0_back == 2020

task_operations = do_commands(task_commands, num_cards=119315717514047, track_card=2020, do_reverse=true, iterations=iterations)
#fast_exp(task_operations, UInt64(iterations), UInt64(num_cards))
println(UInt64(task_operations))

