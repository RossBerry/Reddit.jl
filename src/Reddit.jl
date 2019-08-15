module Reddit

using Revise
using HTTP
using TimeSeries
using ConfParser

function readconfig()
    conf = ConfParse("config/config.ini")
    parse_conf!(conf)
    return conf
end

end # module
