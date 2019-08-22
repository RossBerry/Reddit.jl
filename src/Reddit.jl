module Reddit

export AuthorizedCredentials,
       Credentials,
       Session,
       Subreddit,
       User,
       about,
       authorize,
       blocked,
       comments,
       credentials,
       default,
       default!,
       downvoted,
       friends,
       gilded,
       hidden,
       karma,
       me,
       overview,
       preferences,
       saved,
       searchusers,
       submitted,
       subscribers,
       token,
       trophies,
       upvoted

using ConfParser
using HTTP
using JSON
using Revise
import Base64.Base64EncodePipe

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
    id::String
    secret::String
    useragent::String
    username::String
    password::String
end


"""
    struct AuthorizedCredentials

Represents a credentials that has been authorized and recieved an
access token.
"""
struct AuthorizedCredentials <: AbstractCredentials
    id::String
    secret::String
    useragent::String
    username::String
    password::String
    token::String
end

"""
    struct Session

Represents an authorized session with Reddit's API.
"""
mutable struct Session
    creds::Union{AuthorizedCredentials, Array{AuthorizedCredentials}}
    Session() = new()
end

"""
    struct Subreddit

Represents a subreddit on Reddit.
"""
struct Subreddit
    name::String
end

"""
    struct User

Represents a user on Reddit.
"""
struct User
    name::String
end

const REDDIT_URL = "https://www.reddit.com"
const SHORT_URL = "https://redd.it"
const OATH_URL = "https://oauth.reddit.com"
const CONFIG = "config/config.ini"
const DEFAULT_SESSION = Session()

"""
    about()

Get information about default user(s).
"""
function about()
    about(default())
end

"""
    about(ac::AuthorizedCredentials)

Get information about the current user.
"""
function about(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/about", ac))["data"]
end

"""
    about(user::User)

Get information about a specified user using default credentials.
"""
function about(user::User)
    about(user, default())
end

"""
    about(user::User, ac::AuthorizedCredentials)

Get information about a specified user.
"""
function about(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/about", ac))["data"]
end

"""
    about(sub::Subreddit)

Get information about a specified subreddit using default credentials.
"""
function about(sub::Subreddit)
    about(sub, defualt())
end

"""
    about(sub::Subreddit, ac::AuthorizedCredentials)

Get information about a specified subreddit.
"""
function about(sub::Subreddit, ac::AuthorizedCredentials)
    JSON.parse(get("/r/$(sub.name)/about", ac))
end

"""
    authorize(c::Credentials)

Use Credentials to request an acess token and return AuthorizedCredentials.
"""
function authorize(c::Credentials)
    AuthorizedCredentials(c.id, c.secret, c.useragent,
        c.username, c.password, token(c))
end

"""
    authorize(id::AbstractString,
              secret::AbstractString,
              useragent::AbstractString,
              username::AbstractString,
              password::AbstractString)

Use reddit application account information to request an acess token and
return AuthorizedCredentials.
"""
function authorize(id::AbstractString,
                   secret::AbstractString,
                   useragent::AbstractString,
                   username::AbstractString,
                   password::AbstractString)
    AuthorizedCredentials(id, secret, useragent, username, password,
                          token(id, secret, useragent, username, password))
end

"""
    blocked()

Get users blocked by default user(s).
"""
function blocked()
    blocked(default())
end

"""
    blocked(ac::AuthorizedCredentials)

Get users blocked by current user.
"""
function blocked(ac::AuthorizedCredentials)
    JSON.parse(get("/prefs/blocked", ac))
end

"""
    comments()

Get all comments by default user(s).
"""
function comments()
    comments(default())
end

"""
    comments(ac::AuthorizedCredentials)

Get all comments by current user.
"""
function comments(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/comments", ac))
end

"""
    comments(user::User)

Get all comments by a user, using default credentials.
"""
function comments(user::User)
    comments(user, default())
end

"""
    comments(user::User, ac::AuthorizedCredentials)

Get all comments by a user.
"""
function comments(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/comments", ac))
end

"""
    credentials(name::AbstractString)

Create new Credentials from the specified client in the default ini file.
"""
function credentials(name::AbstractString)
    credentials(name, CONFIG)
end

"""
    credentials(name::AbstractString, config::AbstractString)

Create new Credentials from the specified client in the specified ini file.
"""
function credentials(name::AbstractString, config::AbstractString)
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
        Use default!(creds::Union{AuthorizedCredentials, Array{AuthorizedCredentials}})
        to set default credentials.
        """)
    end
end

"""
    default!(creds::Union{AuthorizedCredentials, Array{AuthorizedCredentials}})

Set the default credentials.
"""
function default!(creds::Union{AuthorizedCredentials, Array{AuthorizedCredentials}})
    DEFAULT_SESSION.creds = creds
end

"""
    downvoted()

Get all threads downvoted by default user(s).
"""
function downvoted()
    downvoted(default())
end

"""
    downvoted(ac::AuthorizedCredentials)

Get all threads a user has downvoted.
"""
function downvoted(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/downvoted", ac))
end

"""
    encode(s::AbstractString)

Encode string to base64.
"""
function encode(s::AbstractString)
    io = IOBuffer()
    io64_encode = Base64EncodePipe(io)
    for char in s
        write(io64_encode, char)
    end
    close(io64_encode)
    String(take!(io))
end

"""
    friends()

Get friends of default user(s).
"""
function friends()
    friends(default())
end

"""
    friends(ac::AuthorizedCredentials)

Get friends of current user.
"""
function friends(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/friends", ac))
end

"""
    get(api::AbstractString, ac::AuthorizedCredentials)

Send GET request to api.
"""
function get(api::AbstractString, ac::AuthorizedCredentials)
    resp = HTTP.request("GET", OATH_URL*api,
        ["Authorization" => "bearer "*ac.token,
        "User-Agent" => ac.useragent])
    String(resp.body)
end

"""
    gilded()

Get all threads gilded by default user(s).
"""
function gilded()
    gilded(default())
end

"""
    gilded(ac::AuthorizedCredentials)

Get all threads current user has gilded.
"""
function gilded(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/gilded", ac))
end

"""
    gilded(user::User)

Get all threads a user has gilded, using default credentials.
"""
function gilded(user::User)
    gilded(user, default())
end

"""
    gilded(user::User, ac::AuthorizedCredentials)

Get all threads a user has gilded.
"""
function gilded(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/gilded", ac))
end

"""
    hidden()

Get all threads hidden by default user(s).
"""
function hidden()
    hidden(default())
end

"""
    hidden(ac::AuthorizedCredentials)

Get all threads current user has hidden.
"""
function hidden(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/hidden", ac))
end

"""
    karma()

Get karma breakdown for default user(s).
"""
function karma()
    karma(default())
end

"""
    karma(ac::AuthorizedCredentials)

Get karma breakdown for current user.
"""
function karma(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/karma", ac))
end

"""
    me()

Get identity information for default user(s).
"""
function me()
    me(default())
end

"""
    me(ac::AuthorizedCredentials)

Get identity information for current user.
"""
function me(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me", ac))
end

"""
    overview()

Get an overview for default user(s).
"""
function overview()
    overview(default())
end

"""
    overview(ac::AuthorizedCredentials)

Get an overview for current user.
"""
function overview(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/overview", ac))
end

"""
    overview(user::User)

Get an overview for a user, using default credentials.
"""
function overview(user::User)
    overview(user, default())
end

"""
    overview(user::User, ac::AuthorizedCredentials)

Get an overview for a user.
"""
function overview(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/overview", ac))
end

"""
    post(api::AbstractString, data::AbstractString)

Send POST request to API, using default credentials.
"""
function post(api::AbstractString, data::AbstractString)
    post(api, data, default())
end

"""
    post(api::AbstractString, data::AbstractString, ac::AbstractCredentials)

Send POST request to API.
"""
function post(api::AbstractString, data::AbstractString, ac::AbstractCredentials)
     resp = HTTP.request(
         "POST", OATH_URL*api,
         ["Authorization" => "bearer "*ac.token,
         "User-Agent" => ac.useragent], data)
     String(resp.body)
end

"""
    preferences()

Get all preferences for default user(s).
"""
function preferences()
    preferences(default())
end

"""
    preferences(ac::AuthorizedCredentials)

Get all preferences for current user.
"""
function preferences(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/prefs", ac))
end

"""
    saved()

Get all posts saved by default user(s).
"""
function saved()
    saved(default())
end

"""
    saved(ac::AuthorizedCredentials)

Get all posts a user has saved.
"""
function saved(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/saved", ac))
end

"""
    searchusers(name::AbstractString)

Search for all users with usernames matching input string, using credentials set
as defualt.
"""
function searchusers(name::AbstractString)
    searchusers(name, default())
end

"""
    searchusers(name::AbstractString, ac::AuthorizedCredentials)

Search for all users with usernames matching input string.
"""
function searchusers(name::AbstractString, ac::AuthorizedCredentials)
    JSON.parse(post("/api/search_reddit_names", "query=$(name)", ac))
end

"""
    submitted()

Get all posts current submitted by default user(s).
"""
function submitted()
    submitted(default())
end

"""
    submitted(ac::AuthorizedCredentials)

Get all posts current user has submitted.
"""
function submitted(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/submitted", ac))
end

"""
    submitted(user::User)

Get all posts a user has submitted, using default credentials.
"""
function submitted(user::User)
    submitted(user, default())
end

"""
    submitted(user::User, ac::AuthorizedCredentials)

Get all posts a user has submitted.
"""
function submitted(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/submitted", ac))
end

"""
    subscribers(sub::AbstractString)

Get total number of subscribers for a subreddit by name, using default credentials.
"""
function subscribers(sub::AbstractString)
    subscribers(sub, default())
end

"""
    subscribers(sub::AbstractString, ac::AuthorizedCredentials)

Get total number of subscribers for a subreddit by name.
"""
function subscribers(sub::AbstractString, ac::AuthorizedCredentials)
    about(Subreddit(sub), ac)["data"]["subscribers"]
end

"""
    subscribers(sub::Subreddit)

Get total number of subscribers for a subreddit with Subreddit type.
"""
function subscribers(sub::Subreddit)
    subscribers(sub, default())
end

"""
    subscribers(sub::Subreddit, ac::AuthorizedCredentials)

Get total number of subscribers for a subreddit with Subreddit type.
"""
function subscribers(sub::Subreddit, ac::AuthorizedCredentials)
    about(sub, ac)["data"]["subscribers"]
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

"""
    trophies()

Get all trophies for default user(s).
"""
function trophies()
    trophies(default())
end

"""
    trophies(ac::AuthorizedCredentials)

Get all trophies for current user.
"""
function trophies(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/trophies", ac))
end

"""
    upvoted()

Get all posts upvoted by default user(s).
"""
function upvoted()
    upvoted(default())
end

"""
    upvoted(ac::AuthorizedCredentials)

Get all posts a user has upvoted.
"""
function upvoted(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/upvoted", ac))
end

end # module
