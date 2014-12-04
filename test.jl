#=
    test
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

using Match

function for_to_test(item)

    @label start
    @match item begin
        "boo"                      =>   begin
                                            print(1)
                                            item="who"
                                            @goto start
                                        end
        "who"                      =>   begin
                                            print(2)
                                            item="nothing to cry about"
                                            @goto start
                                        end
        "nothing to cry about"     =>   begin
                                            print(3)
                                            item=""
                                            @goto start
                                        end
        _                          =>   print(4)
    end
end
