using AODictionary
using Test

@testset "AODictionary.jl" begin
    @test AODict(:a => 2, :b => 4, :c => 6)[:b] == 4
    @test AODict(:a => 2, :b => 4, :c => 6).seq[2] == (:b => 4)
    @test AODict(:a => 2, :b => 4, :c => 6).seqvals[2] == 4
    @test AODict(:a => 2, :b => 4, :c => 6).seqvals[2:end] == [4,6]
    @test AODict(:a => 2, :b => 4, :c => 6).index[:b] == 2
    @test (AODict{Int,Int}()[1]=2) == 2
end
