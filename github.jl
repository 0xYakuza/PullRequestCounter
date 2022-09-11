using Dates

import GitHub
import DotEnv
import JSON

function printTotalPullRequests(result)
    print("--------- TOTAL pull requests ---------\n")
    for (key, value) in result
        print(key,  " -> " , value, "\n")
    end
    print("---------------------------------------\n")   
end

function getPullRequests(repo::String, params, auth)
    requests, page_data = GitHub.pull_requests(repo, params = params, auth = auth)
    result = Dict{String, Dict}()

    for (index, request) in Iterators.enumerate(requests)
        ym = Dates.yearmonth(request.created_at)

        if getkey(result, request.user.login, false) !== false && getkey(result[request.user.login], ym, false) !== false
            result[request.user.login][ym] += 1
        else
            get!(result, request.user.login, Dict(ym => 1))
            get!(result[request.user.login], ym, 1)
        end
    end

    return result
end

DotEnv.config()

const configPath = ARGS[1]
const filter = begin 
    if length(ARGS) == 2
        ARGS[2]
    else
        false
    end
end

const configFileAsString = open(f->read(f, String), configPath)
const config = JSON.parse(configFileAsString)

const auth = GitHub.authenticate(ENV["GITHUB_AUTH"])

for repo in config["repos"]
    print("REPO: ", repo, "\n")

    if filter == false
        params = Dict("state" => "all")
        getPullRequests(repo, params, auth) |> printTotalPullRequests
    else
        params = Dict("state" => "all")
        requests = getPullRequests(repo, params, auth)
        datefmt = DateFormat("y-m")
        dateFromFilter = Date(filter, datefmt)
        yearAndMonth = Dates.yearmonth(dateFromFilter)
        
        print("---------------------------------------\n")   
        for dev in enumerate(requests)
            println(dev[2][1], " -> ", get(dev[2][2], yearAndMonth, 0))
        end
        print("---------------------------------------\n")   
    end
end
