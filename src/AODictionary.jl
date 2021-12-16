module AODictionary

"""
I initially forked this from https://gist.github.com/bzinberg/fb3981dd2251fb25cdbcd4f90b8b9a72
but that makes a gist, which doesn't really play nicely with Julia's packaging system
https://gist.github.com/lawless-m/4812e1aef4b4782302c2866761f2f3e0
So now it's here.
"""

export AODict

"""
Append-only dictionary that:

* Preserves insertion order
* Supports concise and efficient linear indexing into the sequence of `(key,
  value)` pairs
* Supports concise and efficient linear indexing into the sequence of values.

Example:

```jldoctest
>>> d = AODict(:a => 2, :b => 4, :c => 6);
>>> d[:b]
4
>>> d.seq[2]
:b => 4
>>> d.seqvals[2]
4
>>> d.seqvals[2:end]
2-element Array{Int64,1}:
 4
 6
```
"""
struct AODict{K, V} <: AbstractDict{K, V}
  dict::Dict{K, V}
  keys::Vector{K}
  index::Dict{K, Int}
end

function AODict{K, V}(kvs) where {K, V}
  ks = collect(map(first, kvs))
  dict = Dict{K, V}(kvs)
  idx = Dict([k=>i for (i,k) in enumerate(ks)])
  return AODict{K, V}(dict, ks, idx)
end
AODict{K, V}(kvs::Pair...) where {K, V} = AODict{K, V}(kvs)
AODict(kvs::Pair{K, V}...) where {K, V} = AODict{K, V}(kvs)
AODict(kvs) = AODict{Any, Any}(kvs)

function Base.iterate(d::AODict)
  s = Base.iterate(d.keys)
  if isnothing(s); return nothing; end
  (k, state) = s
  return (k => d.dict[k], state)
end

function Base.iterate(d::AODict, state)
  s = Base.iterate(d.keys, state)
  if isnothing(s); return nothing; end
  (k, state) = s
  return (k => d.dict[k], state)
end

Base.length(d::AODict) = Base.length(d.keys)

Base.getindex(d::AODict{K}, key::K) where K = d.dict[key]

function Base.setindex!(d::AODict{K, V}, val::V, key::K) where {K, V}
  @assert key ∉ keys(d.dict)
  d.dict[key] = val
  push!(d.keys, key)
  return val
end

# Custom overload of `getproperty` so that we can write `d.seq` and `d.seqvals`
function Base.getproperty(d::AODict, prop::Symbol)
  if prop == :seq
    return _SequentialAOOD(d)
  elseif prop == :seqvals
    return _SequentialAOODVals(d)
  end
  return Base.getfield(d, prop)
end

Base.propertynames(d::AODict) = [Base.fieldnames(d)..., :seq, :seqvals]

"""
Read-only, array-like indexable accessor for the `(key, value)` pairs of an
`AODict`.
"""
struct _SequentialAOOD
  d::AODict
end

function Base.iterate(seq::_SequentialAOOD)
  s = Base.iterate(seq.d.keys)
  if isnothing(s); return nothing; end
  (k, state) = s
  return (k => seq.d.dict[k], state)
end

function Base.iterate(seq::_SequentialAOOD, state)
  s = Base.iterate(seq.d.keys, state)
  if isnothing(s); return nothing; end
  (k, state) = s
  return (k => seq.d.dict[k], state)
end

Base.length(seq::_SequentialAOOD) = Base.length(seq.d)

function Base.getindex(seq::_SequentialAOOD, i::Integer)
  k = seq.d.keys[i]
  return k => seq.d.dict[k]
end

function Base.getindex(seq::_SequentialAOOD, r::AbstractRange)
  ks = seq.d.keys[r]
  return [k => seq.d.dict[k] for k in ks]
end

Base.firstindex(seq::_SequentialAOOD) = Base.firstindex(seq.d.keys)
Base.lastindex(seq::_SequentialAOOD) = Base.lastindex(seq.d.keys)


"""
Read-only, array-like indexable accessor for the values of an
`AODict`.
"""
struct _SequentialAOODVals
  d::AODict
end

function Base.iterate(seq::_SequentialAOODVals)
  s = Base.iterate(seq.d.keys)
  if isnothing(s); return nothing; end
  (k, state) = s
  return (seq.d.dict[k], state)
end

function Base.iterate(seq::_SequentialAOODVals, state)
  s = Base.iterate(seq.d.keys, state)
  if isnothing(s); return nothing; end
  (k, state) = s
  return (seq.d.dict[k], state)
end

Base.length(seq::_SequentialAOODVals) = Base.length(seq.d)

function Base.getindex(seq::_SequentialAOODVals, i::Integer)
  k = seq.d.keys[i]
  return seq.d.dict[k]
end

function Base.getindex(seq::_SequentialAOODVals, r::AbstractRange)
  ks = seq.d.keys[r]
  return [seq.d.dict[k] for k in ks]
end

Base.firstindex(seq::_SequentialAOODVals) = Base.firstindex(seq.d.keys)
Base.lastindex(seq::_SequentialAOODVals) = Base.lastindex(seq.d.keys)

function getorset(aod::AODict, key, val)
  i = get(aod.index, key, 0)
  if i == 0
    aod[key] = val
    i = aod.index[k]
  end
  i
end

###
end