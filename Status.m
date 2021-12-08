classdef Status < double
    enumeration
        S (0) %suceptible
        E (1) %exposed
        I (2) %infected
        R (3) %recovered
        D (4) %dead
        V (5) %vaccinated
    end
end