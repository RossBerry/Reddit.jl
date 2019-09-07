"""
    abstract type AbstractCredentials

Abstract representation of credentials.
"""
abstract type AbstractCredentials end


"""
    struct Credentials

Represents account information for a Reddit script application.
"""
struct Credentials <: AbstractCredentials
    id::AbstractString
    secret::AbstractString
    useragent::AbstractString
    username::AbstractString
    password::AbstractString
end


"""
    struct Authorized

Represents a credentials that has been authorized and recieved an
access token.
"""
struct Authorized <: AbstractCredentials
    id::AbstractString
    secret::AbstractString
    useragent::AbstractString
    username::AbstractString
    password::AbstractString
    token::AbstractString
end

"""
    struct Session

Represents an authorized session with Reddit's API.
"""
mutable struct Session
    creds::Union{Authorized, Array{Authorized}}
    Session() = new()
end

"""
    authorize(c::Credentials)

Use Credentials to request an acess token and return Authorized.
"""
function authorize(c::Credentials)
    Authorized(c.id, c.secret, c.useragent, c.username, c.password, token(c))
end

"""
    authorize(id::AbstractString,
              secret::AbstractString,
              useragent::AbstractString,
              username::AbstractString,
              password::AbstractString)

Use reddit application account information to request an acess token and
return Authorized.
"""
function authorize(id::AbstractString,
                   secret::AbstractString,
                   useragent::AbstractString,
                   username::AbstractString,
                   password::AbstractString)
    Authorized(id, secret, useragent, username, password,
               token(id, secret, useragent, username, password))
end

"""
    readconfig(name::AbstractString)

Create new Credentials from the specified client in the default ini file.
"""
function readconfig(name::AbstractString)
    readconfig(name, CONFIG)
end

"""
    readconfig(name::AbstractString, config::AbstractString)

Create new Credentials from the specified client in the specified ini file.
"""
function readconfig(name::AbstractString, config::AbstractString)
    conf = ConfParse(config)
    parse_conf!(conf)
    id = retrieve(conf, name, "client_id")
    secret = retrieve(conf, name, "client_secret")
    useragent = retrieve(conf, name, "user_agent")
    username = retrieve(conf, name, "username")
    password = retrieve(conf, name, "password")
    Credentials(id, secret, useragent, username, password)
end

"""
    default()

Get the default credentials.
"""
function default()
    if isdefined(DEFAULT_SESSION, :creds)
        DEFAULT_SESSION.creds
    else
        println(
        """
        Error: Default credentials not set.
        Use default!(creds::Union{Authorized, Array{Authorized}})
        to set default credentials.
        """)
    end
end

"""
    default!(creds::Union{Authorized, Array{Authorized}})

Set the default credentials.
"""
function default!(creds::Union{Authorized, Array{Authorized}})
    DEFAULT_SESSION.creds = creds
end

"""
    token(c::Credentials)

Get token with Credentials.
"""
function token(c::Credentials)
    token(c.id, c.secret, c.username, c.password)
end

"""
token(id::AbstractString,
      secret::AbstractString,
      username::AbstractString,
      password::AbstractString)

Get token with client_id, client_secret, username, and password.
"""
function token(id::AbstractString,
               secret::AbstractString,
               username::AbstractString,
               password::AbstractString)
    auth = encode("$(id):$(secret)")
    resp = HTTP.request("POST", REDDIT_URL*"/api/v1/access_token",
        ["Authorization" => "Basic $(auth)"],
        "grant_type=password&username=$(username)&password=$(password)")
    body = String(resp.body)
    JSON.parse(body)["access_token"]
end
