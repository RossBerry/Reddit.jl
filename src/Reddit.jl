module Reddit

export AuthorizedCredentials,
	   Credentials,
	   credentials,
	   checkusername,
	   subscribers,
	   token,
	   authorize,
	   trending,
	   userinfo

using Revise
using HTTP
using ConfParser
using JSON
using StructuralInheritance
import Base64.Base64EncodePipe

const DEFAULT_INI = "config/config.ini"
const REDDIT_URL = "https://www.reddit.com"
const SHORT_URL = "https://redd.it"
const OATH_URL = "https://oauth.reddit.com"

@protostruct struct Credentials
    id::String
    secret::String
	useragent::String
	username::String
    password::String
end

@protostruct struct AuthorizedCredentials <: Credentials
	token::String
end

# get token with Credentials & return AuthorizedCredentials with token
function authorize(c::Credentials)
	AuthorizedCredentials(c.id, c.secret, c.username, c.useragent, c.password, token(c))
end

# TODO Fix - not working
# # check if a specified username is available
# function checkusername(c::Credentials, username::AbstractString)
# 	resp = HTTP.request("GET", OATH_URL*"/api/username_available",
# 		["Authorization" => "bearer "*c.token,
# 		"User-Agent" => c.useragent],
# 		"user=$(username)")
# end

# create a new c from name in ini file
function credentials(name::AbstractString; config=DEFAULT_INI)
	# parse config file
    conf = ConfParse(config)
    parse_conf!(conf)
	# extract c settings
    id = retrieve(conf, name, "client_id")
    secret = retrieve(conf, name, "client_secret")
	useragent = retrieve(conf, name, "user_agent")
	username = retrieve(conf, name, "username")
    password = retrieve(conf, name, "password")
	Credentials(id, secret, useragent, username, password)
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

# get number of subscribers for subreddit by name
function subscribers(sub::AbstractString)
	resp = HTTP.get("https://www.reddit.com/r/"*sub*"/about.json")
	JSON.parse(String(resp.body))["data"]["subscribers"]
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

# return the identity information for user associated with c
function userinfo(c::AuthorizedCredentials)
	resp = HTTP.request("GET", OATH_URL*"/api/v1/me",
		["Authorization" => "bearer "*c.token,
		"User-Agent" => c.useragent])
	body = String(resp.body)
	JSON.parse(body)
end

function userkarma(c::AuthorizedCredentials)
	resp = HTTP.request("GET", OATH_URL*"/api/v1/me/karma",
		["Authorization" => "bearer "*c.token,
		"User-Agent" => c.useragent])
	body = String(resp.body)
	JSON.parse(body)
end

# TODO Fix - Error 400 Bad Request
# function trending(c::AuthorizedCredentials)
# 	resp = HTTP.request("GET", OATH_URL*"/api/trending_subreddits",
# 		["Authorization" => "bearer "*c.token,
# 		"User-Agent" => c.useragent])
# 	body = String(resp.body)
# 	JSON.parse(body)
# end

end # module
