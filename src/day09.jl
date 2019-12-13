using Test
include("./computer.jl")
input_data = open("input09.txt") do file
    data = readline(file)
    entries = split(data, ",")
    numbers = map(x->parse(Int64, x), entries)
    numbers
end

@test run_program([104,1125899906842624,99]).output == [1125899906842624]
