# Reddit
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
Credentials can also be generated from an `.ini` file. The default `config.ini` looks like:
```
[client]
client_id=CLIENT_ID
client_secret=CLIENT_SECRET
user_agent=USER_AGENT
password=PASSWORD
username=USER_NAME
```
The `credentials` function is used to read the specified client's fields from the default `config.ini` or a specified `.ini`:
```julia
# default config.ini
creds = credentials("client")
# alternate .ini
creds = credentials("CLIENT_NAME", config="PATH/TO/ALTERNATE_CONFIG.ini")
```

Before accessing Reddit's API, we need to authorize the `Credentials` and recieve an access token.  We can use the `authorize` function on the `Credentials` to get back an `AuthorizedCredentials` type, which contains the same fields as `Credentials` with the addition of a `token` field.
```julia
authcreds = authorize(creds)
```
The `token` function can also be called with `Credentials` to get the access token without creating `AuthorizedCredentials`.
```julia
accesstoken = token(creds)
```
The `AuthorizedCredentials` can then be used in the various API call functions:
```julia
# get user identity information
info = userinfo(authcreds)
```

