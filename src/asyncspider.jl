using HTTP, Gumbo, Cascadia
CONFIG = Dict{String, Any}(
                           "startfrom" => 1,
                           "startpath" => "/home/steiner/Downloads/evelyn/[MyGirl美媛馆] 性感嫩模Evelyn艾莉 - 女仆厨娘装制服诱惑系列写真 Vol.157")

struct Image
  src::String
  path::String
end

function eachpage(starturl::String)::Vector{String}
  _eachpage(starturl::String, result::Vector{String}) = begin
    response = nothing
    if haskey(CONFIG, "proxy")
      response = HTTP.get(starturl, proxy = CONFIG["proxy"])
    else
      response = HTTP.get(starturl)
    end

    if response.status != 200
      error("fetch page error on $(starturl)")
    end

    parsed = parsehtml(String(response.body))
    selector = Selector("a.page-link")
    pages = eachmatch(selector, parsed.root)
    nextpage = last(pages)
    if haskey(nextpage.attributes, "href")
      nextpage = urljoin(starturl, nextpage.attributes["href"])
      push!(result, nextpage)
      _eachpage(nextpage, result)
    else
      return result
    end
  end

  return _eachpage(starturl, String[starturl])
  
end

function parse(channel::Channel{Image}, url::String)
  response = nothing
  if haskey(CONFIG, "proxy")
    response = HTTP.get(url, proxy = CONFIG["proxy"])
  else
    response = HTTP.get(url)
  end

  if response.status != 200
    error("fetch page error on $(url)")
  end

  parsed = parsehtml(String(response.body))
  
  selector = Selector("div.mb-4.container-inner-fix-m img")
  images = eachmatch(selector, parsed.root)

  for image in images
    id = CONFIG["startfrom"]
    CONFIG["startfrom"] += 1
    src = urljoin("https://meitulu.me", image.attributes["src"])
    path = joinpath(CONFIG["startpath"], string(id) * ".jpg")

    image′ = Image(src, path)
    put!(channel, image′)
  end

end

function pipeline(channel::Channel{Image})
  for image in channel
    @async download(image.src, image.path)
  end
end

function download(url::String, path::String)
  println("downloading $(url) to $(path)....") # STUB

  response = nothing
  if haskey(CONFIG, "proxy")
    response = HTTP.get(url, proxy = CONFIG["proxy"])
  else
    response = HTTP.get(url)
  end

  if response.status != 200
    throw("downloading error on $(url)")
  end

  fp = open(path, "w")
  try
    write(fp, response.body)
  finally
    close(fp)
  end
  
  println("downloaded $(url) to $(path)....") # STUB
end