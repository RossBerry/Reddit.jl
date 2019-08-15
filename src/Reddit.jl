module Reddit

using Revise
using HTTP
using TimeSeries
using ConfParser
using JSON

mutable struct Client
    id::String
    secret::String
	user_agent::String
    password::String
    username::String
end

mutable struct Session
    url::String
    shorturl::String
    oath::String
    clients::Dict{String, Client}
end

function readconfig()
    conf = ConfParse("config/config.ini")
    parse_conf!(conf)
    sections = collect(keys(conf._data))
    names = [s for s in sections if occursin("client", s)]
    clients = Dict{String, Client}()
    for name in names
        id = retrieve(conf, name, "client_id")
        secret = retrieve(conf, name, "client_secret")
        password = retrieve(conf, name, "password")
        username = retrieve(conf, name, "username")
        if !haskey(clients, name)
            clients[name] = Client(name, id, secret, password, username)
        end
    end
    default = conf._data["default"]
    url = default["reddit_url"][1]
    shorturl = default["short_url"][1]
    oathurl = default["oauth_url"][1]
    Session(url, shorturl, oathurl, clients)
end

end # module
