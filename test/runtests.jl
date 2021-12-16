using AODictionary
using Test

function fromdoctest()


end


@testset "AODictionary.jl" begin
    @test AODict(:a => 2, :b => 4, :c => 6)[:b] == 4
    @test AODict(:a => 2, :b => 4, :c => 6).seq[2] == (:b => 4)
    @test AODict(:a => 2, :b => 4, :c => 6).seqvals[2] == 4
    @test AODict(:a => 2, :b => 4, :c => 6).seqvals[2:end] == [4,6]
end
