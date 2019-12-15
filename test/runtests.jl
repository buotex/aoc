using Revise
using Test
import AoC2019

@testset "computer.jl" begin
    # Write your own tests here.
    @test AoC2019.run_program([3,0,99]).data[0:2] == [1,0,99]
    @test AoC2019.run_program([3,9,8,9,10,9,4,9,99,-1,8]).output == [0]
    @test AoC2019.run_program([3,9,8,9,10,9,4,9,99,-1,8],input=[8]).output == [1]
    @test AoC2019.run_program([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]).output == [1]
    @test AoC2019.run_program([3,3,1105,-1,9,1101,0,0,12,4,12,99,1]).output == [1]
    @test AoC2019.run_program([104,1125899906842624,99]).output == [1125899906842624]
    @test AoC2019.run_program([1102,34915192,34915192,7,4,7,99,0]).output == [1219070632396864]
    @test AoC2019.run_program([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]).output == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    @test AoC2019.run_program([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]).output ==  [999]
    @test AoC2019.run_program([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], input=[8]).output ==  [1000]
    @test AoC2019.run_program([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], input=[9]).output ==  [1001]
end

