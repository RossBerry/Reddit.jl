# Reddit.jl
Reddit API wrapper for Julia.

## Prerequisites
* Reddit account: A Reddit account is required to access Reddit's API.  Create one at [reddit.com](https://reddit.com).
* Client ID & Client Secret: These two values are needed to access Reddit's API as a [script application](https://github.com/reddit-archive/reddit/wiki/oauth2-app-types#script), which is currently the only aplication type supported by this package. If you don’t already have a client ID and client secret, follow Reddit’s [First Steps Guide](https://github.com/reddit/reddit/wiki/OAuth2-Quick-Start-Example#first-steps) to create them.
* User Agent: A user agent is a unique identifier that helps Reddit determine the source of network requests. To use Reddit’s API, you need a unique and descriptive user agent. The recommended format is `<platform>:<app ID>:<version string> (by /u/<Reddit username>)`.  For example, `android:com.example.myredditapp:v1.2.3 (by /u/kemitche)`. Read more about user-agents at [Reddit’s API wiki page](https://github.com/reddit/reddit/wiki/API).


## Installation
This package is currently unregistered, so it must be installed with the repo URL.
```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/kennethberry/Reddit.jl"))
```

## Project Status
This package is new and most of the planned functionality is yet to be implemented.

## Usage
This package contains a `Credentials` type which contains the fields:
* id::String
* secret::String
* useragent::String
* username::String
* password::String

The `id`, `secret`, and `useragent` fields correspond to the client ID, client secret, and user agent mentioned above in the prerequisites section. The `username` and `password` fields correspond to the username and password of the user associated with the script application.

Credentials can be manually created with Strings entered into the fields:
```julia
creds = Credentials("CLIENT_ID", "CLIENT_SECRET", "USER_AGENT", "USER_NAME", "PASSWORD")
```
The `credentials()` function can be used to read account information from the default `config.ini` or a specified `.ini`.
```julia
# read credentials from default config.ini
creds = credentials("client")
# read credentials from an alternate ini
creds = credentials("CLIENT_NAME", config="PATH/TO/ALTERNATE.ini")
```
The default `config.ini` looks like:
```
[client]
client_id=CLIENT_ID
client_secret=CLIENT_SECRET
user_agent=USER_AGENT
password=PASSWORD
username=USER_NAME
```

Before accessing Reddit's API, the `Credentials` need to be authorized to receive an access token.  The `authorize()` function can be used with the `Credentials` to get back an `AuthorizedCredentials` type, which contains the same fields as `Credentials` with the addition of a `token` field.
```julia
authcreds = authorize(creds)
```
The `token()` function can also be called with `Credentials` to get the access token without creating an `AuthorizedCredentials` type.
```julia
accesstoken = token(creds)
```
The `AuthorizedCredentials` can then be used in the various API call functions:
```julia
# get current user identity information
myinfo = me(authcreds)

# get karma breakdown for current user
mykarma = karma(authcreds)

# get number of subscribers for /r/julia
subcount = subscribers("Julia", authcreds)
```
