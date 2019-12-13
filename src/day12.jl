using Plots
using Test
using StaticArrays
using LinearAlgebra


mutable struct Moon
  pos::SVector{3, Int32}
  vel::SVector{3, Int32}
  pot::Int32
  kin::Int32
end


function updateEnergy!(m::Moon)
  m.pot = sum(abs.(m.pos))
  m.kin = sum(abs.(m.vel))
end
function totalEnergy(m::Moon)
  return m.pot * m.kin
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

function updatePosition!(moon::Moon)
  moon.pos += moon.vel
  updateEnergy!(moon)
end
function updateVelocity!(moon1::Moon, moon2::Moon)
  diff_pos = moon2.pos .- moon1.pos
  normalized_diff = map(x-> pseudoNormalize(x), diff_pos)
  moon1.vel += normalized_diff
  moon2.vel -= normalized_diff
  return
end

function step!(arr::Array{Moon, 1})
  num_moons = length(arr)
  for i = 1:num_moons
    for j = 1:num_moons
      if j > i
        updateVelocity!(arr[i], arr[j])
      end
    end
  end
  updatePosition!.(arr)
end

function test_step()
  moon1 = Moon(SVector(1,2,3), SVector(4,5,6), 0,0)
  moon2 = Moon(SVector(11,22,3), SVector(44,55,66), 0,0)
  step!([moon1, moon2])
  @test moon1.vel == SVector(5,6,6)
  @test moon1.pos == SVector(6,8,9)
  @test moon2.vel == SVector(43,54,66)
  @test moon2.pos == SVector(54,76,69)
  @test moon1.pot == sum([6,8,9])
  @test moon1.kin == sum([5,6,6])

end

test_step()

function initializeMoon(x, y, z)
  moon = Moon(SVector(x,y,z), SVector(0,0,0), 0,0)
  updateEnergy!(moon)
  return moon
end

function test_simulation(steps)
  moon1 = initializeMoon(-1,0,2)
  moon2 = initializeMoon(2,-10,-7)
  moon3 = initializeMoon(4,-8,8)
  moon4 = initializeMoon(3,5,-1)
  arr = [moon1, moon2, moon3, moon4]

  for i in 1:steps
    step!(arr)
    total_energies = sum(totalEnergy.(arr))
    for moon in arr
      println(moon)
    end
    println(total_energies)
  end
end
function run_moon_simulation(steps=200)
  moon1 = initializeMoon(-10,-13,7)
  moon2 = initializeMoon(1,2,1)
  moon3 = initializeMoon(-15,-3,13)
  moon4 = initializeMoon(3, 7,-4)
  arr = [moon1, moon2, moon3, moon4]

  for i in 1:steps
    step!(arr)
    total_energies = sum(totalEnergy.(arr))
    println(total_energies)
  end
end
#run_moon_simulation(1000)
#test_simulation(10)


function get_frequency(_arr::Array{Moon, 1}, dimension)
  arr = deepcopy(_arr)

  steps = 0
  begin
    @label repeat 
    step!(arr)
    steps += 1
    for (i, moon) in enumerate(arr)
      if moon.vel[dimension] != 0 || moon.pos[dimension] != _arr[i].pos[dimension]
        @goto repeat
      end
    end
  end
  return steps
end

#moon1 = initializeMoon(-1,0,2)
#moon2 = initializeMoon(2,-10,-7)
#moon3 = initializeMoon(4,-8,8)
#moon4 = initializeMoon(3,5,-1)

#moon1 = initializeMoon(-8,-10,0)
#moon2 = initializeMoon(5,5,10)
#moon3 = initializeMoon(2,-7,3)
#moon4 = initializeMoon(9,-8,-3)
moon1 = initializeMoon(-10,-13,7)
moon2 = initializeMoon(1,2,1)
moon3 = initializeMoon(-15,-3,13)
moon4 = initializeMoon(3, 7,-4)
arr = [moon1, moon2, moon3, moon4]
x_freq = get_frequency(arr, 1)
y_freq = get_frequency(arr, 2)
z_freq = get_frequency(arr, 3)
println(lcm(x_freq,y_freq,z_freq))
