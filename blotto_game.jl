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
function randomresponsemiddle(size::Int64, total::Int64)::Array{Int64, 1}
    # upper and lower bound
    middlelower = Int64(floor(size/3))
    middleupper = Int64(floor(2*size/3))
    # Each soldier is assigned into one troop somewhere from 1 to size
    assignment = rand(middlelower:middleupper, total)
    # Empty array to count the number of soldiers in one troop
    response   = Int64[]

    for i in 1:size
        if middlelower <= i <= middleupper
            push!(response, sum(assignment .== i) )
        else
            push!(response, 0)
        end
    end

    return response
end

function threeinarow(result::BitArray{1})::Array{Int64,1}
    modified = Array{Int64,1}()
    counter  = 0
    previous = result[1]
    value    = 0

    for i in 1:length(result)
        if counter == 3
            push!(modified, value)
        else
            push!(modified, result[i])
            counter  = (result[i] == previous) ? counter + 1 : 1
            value   += counter == 3 ? result[i] : 0
            previous = result[i]
        end
    end

    return modified .* 1
end

function evaluate(player::Array{Int64, 1}, opponent::Array{Int64, 1},
    weight::Array{Int64,1}=collect(1:length(player)), # repeat([1], length(response))
    unitsize::Int64 = 10)::Int64

    if length(player) != length(opponent)
        error("player and opponent has different input length.")
    elseif length(player) != length(weight)
        error("player and weight has different input length.")
    end

    return sum( threeinarow(player .> opponent) .* weight )
end

#=======================================================================
    Ideas playground
=======================================================================#
Random.seed!(1)
strategy1      = repeat([10], 10)
strategy2      = randomresponse(10, 100)
greedystrategy = append!(Int64[34,33,33], repeat([0],7))
middlestrategy = Int64[0,0,35,25,25,15,0,0,0,0]
battles1       = Int64[]
battles2       = Int64[]
battlesgreedy  = Int64[]
battlesmiddle  = Int64[]
repetitions    = 1000000

for i in 1:repetitions
    opponent = randomresponse(10,100)
    push!(battles1, evaluate(strategy1, opponent))
    push!(battles2, evaluate(strategy2, opponent))
    push!(battlesgreedy, evaluate(greedystrategy, opponent))
    push!(battlesmiddle, evaluate(middlestrategy, opponent))
end

avg1      = mean(battles1)
avg2      = mean(battles2)
avggreedy = mean(battlesgreedy)
avgmiddle = mean(battlesmiddle)

println("The means are: $avg1, $avg2, $avggreedy, $avgmiddle")

Random.seed!(1234)
battlesmiddle  = Int64[]
battlesgreedy  = Int64[]
battlesopp      = Int64[]
for i in 1:repetitions
    opponent = randomresponsemiddle(10,100)
    push!(battlesmiddle, evaluate(middlestrategy, opponent))
    push!(battlesgreedy, evaluate(greedystrategy, opponent))
    push!(battlesopp, evaluate(opponent, middlestrategy))
end
avgmiddle = mean(battlesmiddle)
avggreedy = mean(battlesgreedy)
avgopp    = mean(battlesopp)

println("Middle: $avgmiddle, Greedy: $avggreedy, Opponent: $avgopp")
