using URIs: resolvereference

function urljoin(base::AbstractString, ref::AbstractString)
  return string(
    resolvereference(base, ref)
  )
end