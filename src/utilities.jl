function readconfig()
    conf = ConfParse("config/config.ini")
    parse_conf!(conf)
    return conf
end
