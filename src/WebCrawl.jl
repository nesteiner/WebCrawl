module WebCrawl

using HTTP, Gumbo, Cascadia

import Base: parse, pipeline
include("urljoin.jl")
# include("meitulu.jl")
include("asyncspider.jl")
export eachpage, parse, pipeline, Image
end