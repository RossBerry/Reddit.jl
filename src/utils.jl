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
    get(api::AbstractString)

Send GET request to api.
"""
function get(api::AbstractString)
    get(api, default())
end


"""
    get(api::AbstractString, a::Authorized)

Send GET request to api.
"""
function get(api::AbstractString, a::Authorized)
    resp = HTTP.request("GET", OATH_URL*api,
        ["Authorization" => "bearer "*a.token,
        "User-Agent" => a.useragent])
    sleep(1) # wait for 1 second to ensure no more than 60 requests per minute
    String(resp.body)
end

"""
    post(api::AbstractString,
         data::AbstractString)

Send POST request to API, using default credentials.
"""
function post(api::AbstractString, body::AbstractString)
    post(api, body, default())
end

"""
    post(api::AbstractString,
         data::AbstractString,
         a::AbstractCredentials)

Send POST request to API.
"""
function post(api::AbstractString, body::AbstractString, a::Authorized)
    resp = HTTP.request("POST", OATH_URL*api,
                        ["Authorization" => "bearer "*a.token,
                         "User-Agent" => a.useragent],
                         body)
    sleep(1) # wait for 1 second to ensure no more than 60 requests per minute
    String(resp.body)
end
