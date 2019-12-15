function run_program_async(_data::Array{Int64, 1}, channel_in::Channel{<:Integer}, channel_out::Channel{<:Integer}; memory_size::Int64 = 5000, condition::Condition)
    data = OffsetVector(zeros(Int64, memory_size), 0:memory_size-1)
    data[0:length(_data)-1] = _data
    # state variables
    current_addr = 0
    current_rel_addr = 0


    function do_op!(opcode, arg1, arg2, target)
        @debug("opcode: $opcode, arg1: $arg1, arg2: $arg2, target: $target")
        if opcode == 1
            data[target] = arg1 + arg2
        elseif opcode == 2
            data[target] = arg1 * arg2
        elseif opcode == 7 
            if arg1 < arg2
                data[target] = 1
            else
                data[target] = 0
            end
        elseif opcode == 8
            if arg1 == arg2
                data[target] = 1
            else
                data[target] = 0
            end
        end
    end
    

    
    function do_io!(opcode, target)
        #println(stderr, "opcode: $opcode")
        @debug("opcode: $opcode, target: $target")

        if (opcode == 3)
#          if condition != nothing
#            notify(condition)
#          end
          yield()
          input_val = take!(channel_in)
      @debug("input_val: $input_val, target: $target")
            data[target] = input_val
        elseif (opcode == 4)
          @debug("output_val: $(data[target])")
            put!(channel_out, data[target])
        end
    end
    
    function do_jump!(opcode, arg1, arg2)
        @debug("opcode: $opcode, arg1: $arg1, arg2: $arg2")
        if (opcode == 5 && arg1 != 0) ||
           (opcode == 6 && arg1 == 0)
            current_addr = arg2
        else
            current_addr += 3
        end
    end

    function get_addr(arg_mode, addr)
      @debug("arg_mode: $arg_mode, addr: $addr")

      if arg_mode == 0
        return data[addr]
      elseif arg_mode == 1
        return addr
      elseif arg_mode == 2
        return data[addr] + current_rel_addr
      end
    end

    function get_val(arg_mode, addr)
      local this_addr = get_addr(arg_mode, addr)
      return data[this_addr]
    end
    
    while true
        @debug("iter")
        opcode_all = data[current_addr]
        opcode_digits = digits(opcode_all)
        while length(opcode_digits) < 5
            push!(opcode_digits, 0)
        end
        opcode = opcode_digits[1] + 10 * opcode_digits[2]

        arg1_mode = opcode_digits[3]
        arg2_mode = opcode_digits[4]
        @assert arg1_mode in [0,1,2]
        @assert arg2_mode in [0,1,2]
        target_mode = opcode_digits[5]
        @debug("opcode: $opcode")
        @debug("arg1_mode: $arg1_mode")
        @debug("arg2_mode: $arg2_mode")

        if opcode == 99
            break
        elseif opcode == 1 || opcode == 2 || opcode == 7 || opcode == 8
            @debug("do_op")
            arg1 = get_val(arg1_mode, current_addr+1)
            arg2 = get_val(arg2_mode, current_addr+2)
            target = get_addr(target_mode, current_addr+3)
            do_op!(opcode, arg1, arg2, target)
            current_addr += 4
        elseif opcode == 3 || opcode == 4
            @debug("do_io")
            target = get_addr(arg1_mode, current_addr+1)
            @debug("target: $target")
            do_io!(opcode, target)
            current_addr += 2
        elseif opcode == 5 || opcode == 6
            arg1 = get_val(arg1_mode, current_addr+1)
            arg2 = get_val(arg2_mode, current_addr+2)
            do_jump!(opcode, arg1, arg2)
        elseif opcode == 9
          current_rel_addr += get_val(arg1_mode, current_addr+1)
          current_addr += 2
        end
    end
    close(channel_out)
    close(channel_in)
#    if condition != nothing
#      notify(condition)
#    end
    return data
end


function run_program(_data::Array{Int64, 1}; input::Array{Int64, 1}=[1])
  channel_in = Channel{Int64}()
  channel_out = Channel{Int64}()
  output = Int64[]

  data = @sync begin
    @async for i in input
      try
        put!(channel_in, i)
      catch
        break
      end
    end
    @async while true #isready(channel_out)
      try
        push!(output, take!(channel_out))
      catch
        break
      end
    end
    fetch(@async data = run_program_async(_data, channel_in, channel_out))
  end
  return (output=output, data=data)

end


