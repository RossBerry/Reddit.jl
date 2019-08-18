module Reddit

export AuthorizedCredentials,
       Credentials,
       Subreddit,
       User,
       about,
       authorize,
       blocked,
       comments,
       credentials,
       downvoted,
       friends,
       gilded,
       hidden,
       karma,
       me,
       overview,
       preferences,
       saved,
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

const REDDIT_URL = "https://www.reddit.com"
const SHORT_URL = "https://redd.it"
const OATH_URL = "https://oauth.reddit.com"
const CONFIG = "config/config.ini"

abstract type AbstractCredentials end

struct Credentials <: AbstractCredentials
    id::String
    secret::String
    useragent::String
    username::String
    password::String
end

struct AuthorizedCredentials <: AbstractCredentials
    id::String
    secret::String
    useragent::String
    username::String
    password::String
    token::String
end

struct Subreddit
    name::String
end

struct User
    name::String
end

# get information about current user
function about(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/about", ac))
end

# get information about a User
function about(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/about", ac))
end

# get information about a Subreddit
function about(sub::Subreddit, ac::AuthorizedCredentials)
    JSON.parse(get("/r/$(sub.name)/about", ac))
end

# get token with Credentials & return AuthorizedCredentials with token
function authorize(c::Credentials)
    AuthorizedCredentials(c.id, c.secret, c.useragent,
        c.username, c.password, token(c))
end

# get token with user details & return AuthorizedCredentials with token
function authorize(id::AbstractString,
                   secret::AbstractString,
                   useragent::AbstractString,
                   username::AbstractString,
                   password::AbstractString)
    AuthorizedCredentials(id, secret, useragent, username, password,
                          token(id, secret, useragent, username, password))
end

# get users blocked by current user
function blocked(ac::AuthorizedCredentials)
    JSON.parse(get("/prefs/blocked", ac))
end

# get all comments by current user
function comments(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/comments", ac))
end

# get all comments by a user
function comments(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/comments", ac))
end

# create new Credentials from ini file
function credentials(name::AbstractString; config=CONFIG)
    conf = ConfParse(config)
    parse_conf!(conf)
    id = retrieve(conf, name, "client_id")
    secret = retrieve(conf, name, "client_secret")
    useragent = retrieve(conf, name, "user_agent")
    username = retrieve(conf, name, "username")
    password = retrieve(conf, name, "password")
    Credentials(id, secret, useragent, username, password)
end

# get all threads a user has downvoted
function downvoted(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/downvoted", ac))
end

# encode string to base64
function encode(s::AbstractString)
    io = IOBuffer()
    io64_encode = Base64EncodePipe(io)
    for char in s
        write(io64_encode, char)
    end
    close(io64_encode)
    String(take!(io))
end

# get friends of current user
function friends(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/friends", ac))
end

# send GET request to api
function get(api::AbstractString, c::AuthorizedCredentials)
    resp = HTTP.request("GET", OATH_URL*api,
        ["Authorization" => "bearer "*c.token,
        "User-Agent" => c.useragent])
    String(resp.body)
end

# get all threads current user has gilded
function gilded(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/gilded", ac))
end

# get all threads a user has gilded
function gilded(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/gilded", ac))
end

# get all threads current user has hidden
function hidden(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/hidden", ac))
end

# get karma breakdown for current user
function karma(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/karma", ac))
end

# get identity information for current user
function me(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me", ac))
end

# get an overview for current user
function overview(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/overview", ac))
end

# get an overview for a user
function overview(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/overview", ac))
end

# get all preferences for current user
function overview(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/prefs", ac))
end

# get all posts a user has saved
function saved(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/saved", ac))
end

# get all posts current user has submitted
function submitted(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/submitted", ac))
end

# get all posts a user has submitted
function submitted(user::User, ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(user.name)/submitted", ac))
end

# get total number of subscribers for a subreddit by name
function subscribers(sub::AbstractString, ac::AuthorizedCredentials)
    about(Subreddit(sub), ac)["data"]["subscribers"]
end

# get total number of subscribers for a subreddit with Subreddit type
function subscribers(sub::Subreddit, ac::AuthorizedCredentials)
    about(sub, ac)["data"]["subscribers"]
end

# get token with Credentials
function token(c::Credentials)
    token(c.id, c.secret, c.username, c.password)
end

# get token with client_id, client_secret, username, and password
function token(id::AbstractString, secret::AbstractString,
    username::AbstractString, password::AbstractString)
    auth = encode("$(id):$(secret)")
    resp = HTTP.request("POST", REDDIT_URL*"/api/v1/access_token",
        ["Authorization" => "Basic $(auth)"],
        "grant_type=password&username=$(username)&password=$(password)")
    body = String(resp.body)
    JSON.parse(body)["access_token"]
end

# get all trophies for current user
function trophies(ac::AuthorizedCredentials)
    JSON.parse(get("/api/v1/me/trophies", ac))
end

# get all posts a user has upvoted
function upvoted(ac::AuthorizedCredentials)
    JSON.parse(get("/user/$(ac.username)/upvoted", ac))
end

end # module
