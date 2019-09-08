"""
    struct User

Represents a user on Reddit.
"""
struct User
    name::String
end

"""
    about()

Get information about default user(s).
"""
function about()
    about(default())
end

"""
    about(a::Authorized)

Get information about the current user.
"""
function about(a::Authorized)
    JSON.parse(get("/user/$(a.username)/about", a))["data"]
end

"""
    about(user::User)

Get information about a specified user using default credentials.
"""
function about(user::User)
    about(user, default())
end

"""
    about(user::User, a::Authorized)

Get information about a specified user.
"""
function about(user::User, a::Authorized)
    JSON.parse(get("/user/$(user.name)/about", a))["data"]
end

"""
    blocked()

Get users blocked by default user(s).
"""
function blocked()
    blocked(default())
end

"""
    blocked(a::Authorized)

Get an Array of users blocked by current user.
"""
function blocked(a::Authorized)
    JSON.parse(get("/prefs/blocked", a))["data"]["children"]
end

"""
    comments(; count=nothing, sort="new")

Get all comments by default user(s).
"""
function comments(; count=1000, sort="new")
    a = default()
    comments(User(a.username), a, count=count, sort=sort)
end

"""
    comments(a::Authorized; count=nothing, sort="new")

Get all comments by current user.
"""
function comments(a::Authorized; count=1000, sort="new")
    comments(User(a.username), count=count, sort=sort)
end

"""
    comments(user::User; count=nothing, sort="new)

Get all comments by default user(s).
"""
function comments(user::User; count=1000, sort="new")
    a = default()
    comments(User(user.name), default(), count=count, sort=sort)
end

"""
    comments(user::User, a::Authorized; count=nothing, sort="new")

Get all comments by a user.
"""
function comments(user::User, a::Authorized;
                  count=1000, sort="new")
    fetchedcomments = Array{Dict{String, Any}, 1}()
    fetchedcount = 0
    limit = 100
    after = ""
    if count < 100
        limit = count
    end
    api = "/user/$(user.name)/comments.json?sort=$sort&limit=$limit"
    firstfetched = JSON.parse(get(api, a))
    for fetched in firstfetched["data"]["children"]
        push!(fetchedcomments, fetched["data"])
    end
    after = firstfetched["data"]["after"]
    fetchedcount += firstfetched["data"]["dist"]
    done = false
    while !done && fetchedcount < count
        afterapi = api*"&after=$after&count=$fetchedcount"
        nextfetched = JSON.parse(get(afterapi, a))
        for fetched in nextfetched["data"]["children"]
            push!(fetchedcomments, fetched["data"])
        end
        fetchedcount += nextfetched["data"]["dist"]
        after = nextfetched["data"]["after"]
        if after == nothing
            done = true
        end
    end
    return fetchedcomments
end

"""
    deletecomment(id::AbstractString)

Delete a comment made by the default user(s) by id.
"""
function deletecomment(id::AbstractString)
    comment(id, default())
end

"""
    delete(id::AbstractString, a::Authorized)

Delete a comment by id.
"""
function deletecomment(id::AbstractString, a::Authorized)
    body = "id=$id"
    JSON.parse(post("/api/del", body, a))
end

"""
    downvoted()

Get all threads downvoted by default user(s).
"""
function downvoted()
    downvoted(default())
end

"""
    downvoted(a::Authorized)

Get all threads a user has downvoted.
"""
function downvoted(a::Authorized)
    JSON.parse(get("/user/$(a.username)/downvoted", a))
end

"""
    friends()

Get friends of default user(s).
"""
function friends()
    friends(default())
end

"""
    friends(a::Authorized)

Get friends of current user.
"""
function friends(a::Authorized)
    JSON.parse(get("/api/v1/me/friends", a))["data"]["children"]
end

"""
    gilded()

Get all threads gilded by default user(s).
"""
function gilded()
    gilded(default())
end

"""
    gilded(a::Authorized)

Get all threads current user has gilded.
"""
function gilded(a::Authorized)
    gilded(a.username, a)
end

"""
    gilded(user::User)

Get all threads a user has gilded, using default credentials.
"""
function gilded(user::User)
    gilded(user.name, default())
end

"""
    gilded(user::AbstractString)

Get all threads a user has gilded, using default credentials.
"""
function gilded(user::AbstractString)
    gilded(user, default())
end

"""
    gilded(user::User, a::Authorized)

Get all threads a user has gilded, using default credentials.
"""
function gilded(user::User, a::Authorized)
    gilded(user.name, a)
end

"""
    gilded(user::AbstractString, a::Authorized)

Get all threads a user has gilded.
"""
function gilded(user::AbstractString, a::Authorized)
    JSON.parse(get("/user/$user/gilded", a))["data"]["children"]
end

"""
    hidden()

Get all threads hidden by default user(s).
"""
function hidden()
    hidden(default())
end

"""
    hidden(a::Authorized)

Get all threads current user has hidden.
"""
function hidden(a::Authorized)
    JSON.parse(get("/user/$(a.username)/hidden", a))["data"]["children"]
end

"""
    karma()

Get karma breakdown for default user(s).
"""
function karma()
    karma(default())
end

"""
    karma(a::Authorized)

Get karma breakdown for current user.
"""
function karma(a::Authorized)
    JSON.parse(get("/api/v1/me/karma", a))["data"]
end

"""
    me()

Get identity information for default user(s).
"""
function me()
    me(default())
end

"""
    me(a::Authorized)

Get identity information for current user.
"""
function me(a::Authorized)
    JSON.parse(get("/api/v1/me", a))
end

"""
    overview()

Get an overview for default user(s).
"""
function overview()
    overview(default())
end

"""
    overview(a::Authorized)

Get an overview for current user.
"""
function overview(a::Authorized)
    overview(a.username, a)
end

"""
    overview(user::User)

Get an overview for a user, using default credentials.
"""
function overview(user::User)
    overview(user.name, default())
end

"""
    overview(user::AbstractString)

Get an overview for a user, using default credentials.
"""
function overview(user::AbstractString)
    overview(user, default())
end

"""
    overview(user::User, a::Authorized)

Get an overview for a user.
"""
function overview(user::User, a::Authorized)
    overview(user.name, a)
end

"""
    overview(user::AbstractString, a::Authorized)

Get an overview for a user.
"""
function overview(user::AbstractString, a::Authorized)
    JSON.parse(get("/user/$user/overview", a))["data"]["children"]
end

"""
    preferences()

Get all preferences for default user(s).
"""
function preferences()
    preferences(default())
end

"""
    preferences(a::Authorized)

Get all preferences for current user.
"""
function preferences(a::Authorized)
    JSON.parse(get("/api/v1/me/prefs", a))
end

"""
    reply(parent::AbstractString, text::AbstractString)

Reply to a comment by name, as default user(s).
"""
function reply(parent::AbstractString, text::AbstractString)
    reply(parent, text, default())
end

"""
    reply(parent::AbstractString, text::AbstractString, a::Authorized)

Reply to a comment by name.
"""
function reply(parent::AbstractString, text::AbstractString, a::Authorized)
    body = "api_type=json&text=$text&thing_id=$parent"
    JSON.parse(post("/api/comment", body, a))
end

"""
    saved()

Get all posts saved by default user(s).
"""
function saved()
    saved(default())
end

"""
    saved(a::Authorized)

Get all posts a user has saved.
"""
function saved(a::Authorized)
    JSON.parse(get("/user/$(a.username)/saved", a))["data"]["children"]
end

"""
    searchusers(name::AbstractString)

Search for all users with usernames matching input string, using credentials
set as default.
"""
function searchusers(name::AbstractString)
    searchusers(name, default())
end

"""
    searchusers(name::AbstractString, a::Authorized)

Search for all users with usernames matching input string.
"""
function searchusers(name::AbstractString, a::Authorized)
    JSON.parse(post("/api/search_reddit_names", "query=$name", a))["names"]
end

"""
    submittext(sub::Subreddit,
               title::AbstractString,
               text::AbstractString;
               ad=false,
               flair_id="",
               flair_text="",
               kind="self",
               nsfw=false,
               resubmit=true,
               sendreplies=true,
               spoiler=false)

Submit a post to a Subreddit using the defalut credentials.
"""
function submit(sub::Subreddit,
                title::AbstractString,
                body::AbstractString;
                ad=false,
                flair_id="",
                flair_text="",
                kind="self",
                nsfw=false,
                resubmit=true,
                sendreplies=true,
                spoiler=false)
    submit(sub, title, body, default(), ad=ad, flair_id=flair_id,
           flair_text=flair_text, kind=kind, nsfw=nsfw, resubmit=resubmit,
           sendreplies=sendreplies, spoiler=spoiler)
end

"""
    submit(sub::Subreddit,
           title::AbstractString,
           text::AbstractString,
           a::Authorized;
           ad=false,
           flair_id="",
           flair_text="",
           kind="self",
           nsfw=false,
           resubmit=true,
           sendreplies=true,
           spoiler=false)

Submit a post to a Subreddit.
"""
function submit(sub::Subreddit,
                title::AbstractString,
                body::AbstractString,
                a::Authorized;
                ad=false,
                flair_id="",
                flair_text="",
                kind="self",
                nsfw=false,
                resubmit=true,
                sendreplies=true,
                spoiler=false)
    params = "api_type=json&sr=$(sub.name)&title=$title&kind=$kind"
    if kind == "self"
        params *= "&text=$body"
    elseif kind == "link"
        params *= "&url=$body"
    else
        println("Error: Invalid kind")
        return nothing
    end
    if flair_id != ""
        params *= "&flair_id=$flair_id"
    end
    if flair_text != ""
        params *= "&flair_text=$flair_text"
    end
    params *= "&ad=$ad&nsfw=$nsfw&sendreplies=$sendreplies&spoiler=$spoiler"
    JSON.parse(post("/api/submit", params, a))
end

"""
    submitted()

Get all posts current submitted by default user(s).
"""
function submitted()
    submitted(default())
end

"""
    submitted(a::Authorized)

Get all posts current user has submitted.
"""
function submitted(a::Authorized)
    submitted(User(a.username), a)
end

"""
    submitted(user::AbstractString)

Get all posts a user has submitted, using default credentials.
"""
function submitted(user::AbstractString)
    submitted(User(user), default())
end

"""
    submitted(user::User)

Get all posts a user has submitted, using default credentials.
"""
function submitted(user::User)
    submitted(user, default())
end

"""
    submitted(user::User, a::Authorized)

Get all posts a user has submitted.
"""
function submitted(user::User, a::Authorized)
    JSON.parse(get("/user/$(user.name)/submitted", a))["data"]["children"]
end

"""
    trophies()

Get all trophies for default user(s).
"""
function trophies()
    trophies(default())
end

"""
    trophies(a::Authorized)

Get all trophies for current user.
"""
function trophies(a::Authorized)
    JSON.parse(get("/api/v1/me/trophies", a))["data"]["trophies"]
end

"""
    upvoted()

Get all posts upvoted by default user(s).
"""
function upvoted()
    upvoted(default())
end

"""
    upvoted(a::Authorized)

Get all posts a user has upvoted.
"""
function upvoted(a::Authorized)
    JSON.parse(get("/user/$(a.username)/upvoted", a))["data"]["children"]
end
