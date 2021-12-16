# AODictionary.jl
Append Only Order Preserving Dictionary

I initially forked this from https://gist.github.com/bzinberg/fb3981dd2251fb25cdbcd4f90b8b9a72

but that makes a gist, which doesn't really play nicely with Julia's packaging system

https://gist.github.com/lawless-m/4812e1aef4b4782302c2866761f2f3e0

So now it's here.

And then I discovered it didn't quite do what I wanted

Because I want to know the sequence number for a particular entry

```
    AODict(:a => 2, :b => 4, :c => 6)[:b] == 4
    AODict(:a => 2, :b => 4, :c => 6).seq[2] == (:b => 4)
    AODict(:a => 2, :b => 4, :c => 6).seqvals[2] == 4
    AODict(:a => 2, :b => 4, :c => 6).seqvals[2:end] == [4,6]

    # I added this
    AODict(:a => 2, :b => 4, :c => 6).index[:b] == 2
```