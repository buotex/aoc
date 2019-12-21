import AoC2019
intcode_program = AoC2019.read_numbers("input21.txt")

intcode_input_short = 
map(x->Int(x), collect(
"""NOT T T
AND A T
AND B T
AND C T
NOT T J
AND D J
WALK
"""
))

result = AoC2019.run_program(intcode_program, input=intcode_input_short)
try
  println(join(map(x->Char(x), result.output)))
catch err
  println(result.output)
end

intcode_input_long = 
map(x->Int(x), collect(
"""NOT T T
AND A T
AND B T
AND C T
NOT T J
AND D J
OR E T
OR H T
AND T J
RUN
"""
))

result = AoC2019.run_program(intcode_program, input=intcode_input_long)
try
  println(join(map(x->Char(x), result.output)))
catch err
  println(result.output)
end
