CONFIG = Dict{String, String}()
CONFIG["proxy"] = "http://127.0.0.1:7890"

function parse(startpage::String, dict::Dict{String, T}) where T <: Any
  response = nothing
  if haskey(CONFIG, "proxy")
    proxy = CONFIG["proxy"]
    response = HTTP.get(startpage, proxy = proxy)
  else
    response = HTTP.get(startpage)
  end

  if response.status != 200
    throw("fetching page error on $startpage")
  end

  parsed = parsehtml(String(response.body))
  selector = Selector("div.work-content>p>a>img")
  images = eachmatch(selector, parsed.root)
  
  @sync for image in images
    directory = dict["startpath"]
    if !isdir(directory)
      mkdir(directory)
    end
    
    path = joinpath(directory, string(dict["startfrom"]) * ".jpg")
    dict["startfrom"] += 1

    url = image.attributes["src"]
    # @async pipeline(url, path)
    @async pipeline(url, path)
  end

  selector = Selector("div.work-content p a")
  page = last(eachmatch(selector, parsed.root))
  href = urljoin(startpage, page.attributes["href"])

  if endswith(href, "html")
    parse(href, dict)
  end
end


function pipeline(image::String, path::String)
  if haskey(CONFIG, "proxy")
    proxy = CONFIG["proxy"]
    response = HTTP.get(image, proxy = proxy)
  else
    response = HTTP.get(image)
  end

  if response.status != 200
    throw("downloading error on $path")
  end
  
  fp = open(path, "w")
  write(fp, response.body)
  close(fp)

end