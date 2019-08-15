module Reddit

using Revise
using HTTP
using TimeSeries
using ConfParser

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
    return conf
end

end # module
