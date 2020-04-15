#===========================================================================
    Blotto Games, this script only serves to get some intuition
    to the problem.
===========================================================================#
# Setting working directory
cd("/home/gxyau/Documents/github/blotto_game/")

# Import packages
using Random, Statistics

function randomresponse(size::Int64, total::Int64)::Array{Int64, 1}
    # Each soldier is assigned into one troop somewhere from 1 to size
    assignment = rand(1:size, total)
    # Empty array to count the number of soldiers in one troop
    response   = Int64[]

    for i in 1:size
        push!(response, sum(assignment .== i) )
    end

    return response
end

function threeinarow(result::BitArray{1})::BitArray{1}
    modified = Array{Int64,1}()
    counter  = 0
    value    = 0

    for i in 1:length(result)
        if abs(counter) == 3
            push!(modified, value)
        else
            push!(modified, result[i])
            counter += 2*result[i]-1
            value += abs(counter) == 3 ? result[i] : 0
        end
    end

    return modified
end

function evaluate(response::Array{Int64, 1}, unitsize::Int64 = 10)::Int64
    # Number of castles/rounds
    len      = length(response)
    # Generate random opponent response
    opponent = randomresponse(len, unitsize*len)
    return sum( threeinarow(response .> opponent) .* collect(1:len) )
end
