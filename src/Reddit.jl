module Reddit

export Authorized,
       Credentials,
       Subreddit,
       User,
       about,
       authorize,
       blocked,
       comments,
       readconfig,
       default,
       default!,
       delete,
       downvoted,
       friends,
       gilded,
       hidden,
       karma,
       me,
       overview,
       preferences,
       reply,
       saved,
       searchusers,
       submitted,
       subscribers,
       token,
       trophies,
       upvoted

# dependencies
using ConfParser
using HTTP
using JSON
using Revise
import Base64.Base64EncodePipe

# Reddit URLs
const REDDIT_URL = "https://www.reddit.com"
const SHORT_URL = "https://redd.it"
const OATH_URL = "https://oauth.reddit.com"

# default config file
const CONFIG = "config/config.ini"

# included types and functions
include("authorization.jl")
include("subreddits.jl")
include("users.jl")
include("utils.jl")

# default session for setting default credentials
const DEFAULT_SESSION = Session()

end # module
