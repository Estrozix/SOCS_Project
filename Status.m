classdef Status < double
    enumeration
        S (0) %suceptible
        E (1) %exposed
        I (2) %infected (symptomatic)
        A (3) %infected (asymptomatic)
        R (4) %recovered
        D (5) %dead
        V (6) %vaccinated
    end
end