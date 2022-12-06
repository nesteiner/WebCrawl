using WebCrawl, Test

# @testset "test fetch meitulu" begin
#   dict = Dict("startfrom" => 1,
#               "startpath" => "/home/steiner/Downloads/evelyn/[MyGirl美媛馆] 性感嫩模Evelyn艾莉 - 女仆厨娘装制服诱惑系列写真 Vol.157")
#   startpage = "https://www.meitu131.com/meinv/5287/index.html"
#   try
#     WebCrawl.parse(startpage, dict)
#   catch error
#     print(stderr, error)
#   end

# end

@testset "test fetch meitulu" begin
  startpage = "https://meitulu.me/item/6433.html"

  channel = Channel{Image}(10)
  @sync begin
    @async WebCrawl.parse(channel, startpage)
    @async WebCrawl.pipeline(channel)
    @async begin
      t = Timer((_) -> close(channel), 20)
    end
  end
end