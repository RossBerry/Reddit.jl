
# Reddit.jl
[![Build Status](https://travis-ci.org/kennethberry/Reddit.jl.svg?branch=master)](https://travis-ci.org/kennethberry/Reddit.jl)

Reddit API wrapper for Julia. This package is still a work in progress, and most of the planned functionality is yet to be implemented.

## Prerequisites
**Reddit account** - A Reddit account is required to access Reddit's API.  Create one at [reddit.com](https://reddit.com).

**Client ID** & **Client Secret** - These two values are needed to access Reddit's API as a [script application](https://github.com/reddit-archive/reddit/wiki/oauth2-app-types#script), which is currently the only aplication type supported by this package. If you don’t already have a client ID and client secret, follow Reddit’s [First Steps Guide](https://github.com/reddit/reddit/wiki/OAuth2-Quick-Start-Example#first-steps) to create them.

**User Agent** - A user agent is a unique identifier that helps Reddit determine the source of network requests. To use Reddit’s API, you need a unique and descriptive user agent.
<br>
The recommended format is:
<br>
`<platform>:<app ID>:<version string> (by /u/<Reddit username>)`.
<br>
For example:
<br>
`android:com.example.myredditapp:v1.2.3 (by /u/kemitche)`.
<br>
Read more about user-agents at [Reddit’s API wiki page](https://github.com/reddit/reddit/wiki/API).


## Installation
The package can be installed with Julia's package manager,
either by using the Pkg REPL mode (press `]` to enter):
```
pkg> add Reddit
```
or by using Pkg functions
```julia
julia> using Pkg; Pkg.add("Reddit")
```


## Usage
The Reddit script application and user account credentials mentioned in the prerequisites section can be used to create a `Credentials` object:
```julia
creds = Credentials("CLIENT_ID", "CLIENT_SECRET", "USER_AGENT", "USER_NAME", "PASSWORD")
```

The information required to create `Credentials` can be stored in an ini file. The example config file, [config.ini](/config/config.ini), contains two example clients named **client1** and **client2**, with placeholders for the information.
```
[client1]
client_id=CLIENT_ID_1
client_secret=CLIENT_SECRET_1
user_agent=USER_AGENT_1
password=PASSWORD_1
username=USER_NAME_1

[client2]
client_id=CLIENT_ID_2
client_secret=CLIENT_SECRET_2
user_agent=USER_AGENT_2
password=PASSWORD_2
username=USER_NAME_2
```

The `readconfig()` function can be used to read credentials information from an ini file.
```julia
# read credentials from default config.ini
creds = readconfig("CLIENT_NAME")

# read credentials from an alternate ini
creds = readconfig("CLIENT_NAME", "PATH/TO/ALTERNATE.ini")
```

In order to access Reddit's API, the `Credentials` need to be authorized. The `authorize()` function can be used with `Credentials` to get an `Authorized` type, which contains the same fields as `Credentials` with the addition of a `token` representing the Oauth access token needed to interact with most of Reddit's API.
```julia
auth = authorize(creds)
```

The `token()` function can also be called with `Credentials` to get the access token without creating an `Authorized` type.
```julia
accesstoken = token(creds)
```

The `Authorized` credentials can then be used in the various API call functions included in this project.


### Examples
Get information about user account used to create the script application.
```julia
myinfo = me(auth)
```

Get karma breakdown for user account used to create the script application.
```julia
mykarma = karma(auth)
```

Get the number of subsribers for /r/Julia
```julia
subcount = subscribers("Julia", auth)
```

Get an array of friends for the user account associated with the script application.
```julia
f = friends(auth)
```

An `Authorized` object can also be set as the default using the `default!()` function.  When the default credentials are set, the same API call functions can be used without specifying the `Authorized` to use.
```julia
default!(auth)

myinfo = me()

mykarma = karma()

subcount = subscribers(Subreddit("Julia"))

f = friends()
```

Get comments made by users.
```julia
# get comments made by default user
mycomments = comments()

# get comments made by /user/_____USER_NAME_____
theircomments = comments(User("_____USER_NAME_____"))
```

The Reddit API will only return up to 1000 items in a listing, so the `comments()` function will return a max of 1000 comments.  The number of comments to fetch and the sorting can be specified with the `count` and `sort` parameters.
```julia
# get top 100 comments by /user/_____USER_NAME_____
topcomments = comments(User("_____USER_NAME_____"), count=100, sort="top")
```

Get the body text of user's latest comment. Default sorting is by new.
```julia
text = comments(User("_____USER_NAME_____"), count=1)[1]["body"]
```

A simple script that replies to a user's latest comment
```julia
using Reddit
default!(authorize(readconfig("CLIENT", "PATH/TO/ALT/CONFIG.ini")))
reply(comments(User("_____USER_NAME_____"), count=1)[1]["name"], "Hello 👋")
```
