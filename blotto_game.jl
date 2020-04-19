#===========================================================================
    Blotto Games, this script only serves to get some intuition
    to the problem.
===========================================================================#
# Setting working directory
cd("/home/gxyau/Documents/github/blotto_game/")

# Import packages
using Distributions, Random, Statistics

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

function randomgreedy(size::Int64, total::Int64)::Array{Int64, 1}
    # Each soldier is assigned into one troop somewhere from 1 to size
    assignment = rand(1:3, total)
    # Empty array to count the number of soldiers in one troop
    response   = Int64[]

    for i in 1:size
        if 1 <= i <= 3
            push!(response, sum(assignment .== i) )
        else
            push!(response, 0)
        end
    end

    return response
end

function threeinarow(result::Array{Int64, 1})::Array{Int64,1}
    modified = Array{Int64,1}()
    counter  = 0
    previous = result[1]
    value    = 0

    for i in 1:length(result)
        if counter == 3
            push!(modified, value)
        elseif result[i] == 0
            counter = 0
            push!(modified, 0)
        else
            push!(modified, result[i])
            counter  = (result[i] == previous) ? counter + 1 : 1
            value   += counter == 3 ? result[i] : 0
            previous = result[i]
        end
    end

    return max.(modified, 0)
end

function evaluate(player::Array{Int64, 1}, opponent::Array{Int64, 1},
    weight::Array{Int64,1}=collect(1:length(player)) )::Int64 # repeat([1], length(response))

    if length(player) != length(opponent)
        error("player and opponent has different input length.")
    elseif length(player) != length(weight)
        error("player and weight has different input length.")
    end

    battle = (player .> opponent) .- (opponent .> player)

    return sum( threeinarow(battle) .* weight)
end

function ballsandbins(totalballs::Int64=100, totalbins::Int64=10,
     from::Int64=0, to::Int64=100)::Float64
     D = Binomial(totalballs, 1/totalbins) # Distribution

     return cdf(D,to) - cdf(D,from)
 end

#=======================================================================
    Ideas playground
=======================================================================#
Random.seed!(1)
strategy1      = repeat([10], 10)
strategy2      = randomresponse(10, 100)
greedystrategy = append!(Int64[34,33,33], repeat([0],7))
middlestrategy = Int64[0,0,40,30,30,0,0,0,0,0]
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
battlesmiddle   = Int64[]
battlesgreedy   = Int64[]
battlesrg       = Int64[]
battlesmiddlerg = Int64[]
battlesopp      = Int64[]
for i in 1:repetitions
    opponent   = randomresponsemiddle(10,100)
    rgstrategy = randomgreedy(10, 100)
    push!(battlesmiddle, evaluate(middlestrategy, opponent))
    push!(battlesgreedy, evaluate(greedystrategy, opponent))
    push!(battlesopp, evaluate(opponent, middlestrategy))
    push!(battlesrg, evaluate(rgstrategy, middlestrategy))
    push!(battlesmiddlerg, evaluate(middlestrategy, rgstrategy))
end
avgmiddle   = mean(battlesmiddle)
avggreedy   = mean(battlesgreedy)
avgopp      = mean(battlesopp)
avgrg       = mean(battlesrg)
avgmiddlerg = mean(battlesmiddlerg)

println("Middle: $avgmiddle, Greedy: $avggreedy, Opponent: $avgopp, Random Greedy: $avgrg, Middle RG: $avgmiddlerg")

#======================================================================
    Probability estimation
======================================================================#
###########################################################################
prob1  = ballsandbins(100,7,36,100) + 3 * ballsandbins(100,7,2,100) * ballsandbins(98,6,30,100)
############################################################################
prob2  = ballsandbins(100,10,36,100) + 2 * ballsandbins(100,10,30,100)
