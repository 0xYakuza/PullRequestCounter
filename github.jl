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

DotEnv.config()

configPath = ARGS[1]

configFileAsString = open(f->read(f, String), configPath)

config = JSON.parse(configFileAsString)

myauth = GitHub.authenticate(ENV["GITHUB_AUTH"])

myparams = Dict("state" => "all")

for repo in config["repos"]
    print("REPO: ", repo, "\n")

    requests, page_data = GitHub.pull_requests(repo, params = myparams, auth = myauth)
    result = Dict{String, Dict}()

    for (index, request) in Iterators.enumerate(requests)
        ymd = Dates.yearmonth(request.created_at)
        if getkey(result, request.user.login, false) !== false && getkey(result[request.user.login], ymd, false) !== false
            result[request.user.login][ymd] += 1
        else
            get!(result, request.user.login, Dict(ymd => 1))
            get!(result[request.user.login], ymd, 1)
        end
    end

    printTotalPullRequests(result)
end
