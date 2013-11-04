module Utils

    def self.roundup( value )
        #Round values up depending on their magnitude so that the make more sense for
        #weights in shopping lists.
        roundfactor = 1.0
        roundfactor = 5.0 if (value > 50)
        roundfactor = 10.0 if (value > 500)
        roundfactor = 50.0 if (value > 2000)
        roundfactor = 100.0 if (value > 5000)

        newvalue = (value/roundfactor).ceil * roundfactor

        return newvalue
    end

end
