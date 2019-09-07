
"""
    struct Sub

Represents a subreddit on Reddit.
"""
struct Subreddit
    name::String
end

"""
    about(sub::Subreddit)

Get information about a specified subreddit using default credentials.
"""
function about(sub::Subreddit)
    about(sub, default())
end

"""
    about(sub::Subreddit, a::Authorized)

Get information about a specified subreddit.
"""
function about(sub::Subreddit, a::Authorized)
    JSON.parse(get("/r/$(sub.name)/about", a))["data"]
end

"""
    subscribers(sub::AbstractString)

Get total number of subscribers for a subreddit by name, using default
credentials.
"""
function subscribers(sub::AbstractString)
    subscribers(sub, default())
end

"""
    subscribers(sub::Subreddit)

Get total number of subscribers for a subreddit with Subreddit type.
"""
function subscribers(sub::Subreddit)
    subscribers(sub.name, default())
end

"""
    subscribers(sub::Subreddit, a::Authorized)

Get total number of subscribers for a subreddit with Subreddit type.
"""
function subscribers(sub::Subreddit, a::Authorized)
    subscribers(sub.name, a)
end

"""
    subscribers(sub::AbstractString, a::Authorized)

Get total number of subscribers for a subreddit by name.
"""
function subscribers(sub::AbstractString, a::Authorized)
    about(Subreddit(sub), a)["subscribers"]
end
