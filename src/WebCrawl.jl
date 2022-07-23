using HTTP, Gumbo, Cascadia

module WebCrawl
include("urljoin.jl")
include("meitulu.jl")

export parse, pipeline
end