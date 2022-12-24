module ITUPatterns

using Plots
gr()

include("./APERR_001V01.jl")
include("./APEREC005V01.jl")
include("./APERR_002V01.jl")
include("./APEND_099V01.jl")
include("./APERR_006V01.jl")
include("./APERR_007V01.jl")
include("./APERR_008V01.jl")
include("./APERR_009V01.jl")
include("./APERR_010V01.jl")
include("./APERR_011V01.jl")
include("./APERR_012V01.jl")
include("./APEREC013V01.jl")
include("./APEREC015V01.jl")
include("./APEREC022V01.jl")
include("./APEREC025V01.jl")
include("./APEREC026V01.jl")
include("./APEREC028V01.jl")
include("./APEREC029V01.jl")
include("./APEEST256V01.jl")
include("./APEUAE229V01.jl")
include("./APEUAE233V01.jl")
include("./APEUAE234V01.jl")
include("./APENST806V01.jl")
include("./APSEST640V01.jl")
include("./APSEST634V01.jl")
include("./APSREC412V01.jl")

export APERR_001V01, APERR_002V01, APEREC005V01, APERR_006V01,
APERR_007V01, APERR_008V01, APERR_009V01, APERR_010V01, APERR_011V01,
APERR_012V01, APEREC013V01, APEREC015V01, APEREC022V01, APEREC025V01,
APEREC028V01, APEREC029V01, APSREC412V01


end # ITUPatterns