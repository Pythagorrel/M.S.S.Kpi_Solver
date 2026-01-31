#------------------------------Defining the structure and the specific instance to be defined by the user---------------------------------------------------------

mutable struct KPI_parameters
    ϵ::Float64
    R::Int
    nᵥ::Int
    Rᵥ::Float64

    function KPI_parameters()
        # Initialize all fields to 0.0 (or any default value)
        new(0.0, 0.0, 0.0, 0.0)
    end
end

perf = KPI_parameters()
#------------------------------Prompting and accepting user input-------------------------------------------------------------------------------------------------------
println("Welcome to the M.S.S. KPI solver. Please enter the assumed efficiency of SIIE: [Number must be between 0 and 1]")
perf.ϵ =parse(Float64,readline())
println("Please enter the required number of volunteer hours for each scholarship student: ") #add safety checks later
perf.R = parse(Float64, readline())
println("Please enter the number of volunteers for this semester: ")
perf.nᵥ = parse(Float64, readline())
println("Please enter the number of volunteer hours provided by the club per student: ")
perf.Rᵥ = parse(Float64, readline())

#------------------------------------------------------------Defining the constants derived from the struct values-------------------------------------------------------
const tᵣₑ = perf.R * perf.nᵥ
const tᵥ = perf.Rᵥ*perf.nᵥ
const E = perf.ϵ*100
No =0.0
i = 0
# remember to define i after running pSRRI as nv-no
#-------------------------------------------------------------KPI 1------------------------------------------------------------------------------------------------------
using Roots
function pSRRI() 
    global No
    #Rᵥ is the target rate of volunteering by the club(s); nᵥ is the total expected number of volunteers in that semester

    F(nᵥᵥ) = ((perf.ϵ .* tᵣₑ) ./ (perf.R .- perf.Rᵥ)) .- nᵥᵥ
    a = perf.nᵥ .+ 100
    No = round(fzero(F, 0.0, a), digits=3)
    Nₚᵣₒ = round(((No ./ perf.nᵥ) .* 100.0), digits=3)
    if Nₚᵣₒ >= perf.nᵥ
        x = println("All $(perf.nᵥ) volunteers will have their hours fulfilled at the enterred rate.")
        return x
    else
        y = println("\nIf the Multinational Student Society accomodates $(perf.nᵥ) students this semester, and provides $(perf.Rᵥ) volunteer hours per student, 
    then $Nₚᵣₒ% of volunteers will have their scholarship hours fulfilled, 
    given that the SIIE operates at $E% efficiency. 
    In this case, it works out to $No students from a total of $(perf.nᵥ) volunteers.")
        return y
    end
end
#------------------------------------------------------------KPI 2---------------------------------------------------------------------------------
#Assumption: Every student volunteers at the Rᵥ given the tᵥ and nᵥ from M.S.S. records. [applies on a semesterly basis] 

using PyPlot

function rSRRI()  #=where: nᵥ is the number of M.S.S. volunteers
                                     tᵥ is the total number of hours volunteered 
                                     ϵ is assumed efficiency of SIIE in providing remaining volunteering hours =#

    a = perf.nᵥ ./ 1000 #creating intial # of students 

    if a < 1 #minimum number of students is 1 
        a = a .* (1 ./ a)
    end

    NV = (a:0.1:perf.nᵥ) #numerical values of students 

    t_v = (perf.Rᵥ .* NV) .+ (perf.ϵ .* tᵣₑ) #expression for volunteered time as a function of number of students 

    t_r = perf.R .* NV #expression for required volunteer hours for students 

    curve = plot(NV, t_v, NV, t_r)
    xlabel(" Number of Students")
    ylabel("Number of Volunteer Hours")
    PyPlot.title("Graph Showing Maximum Number of Students with Completed Scholarship Hours")
    grid("on")
    legend(["Hours from M.S.S.", "Hours Required by SIIE"])
    return curve

end

#-----------------------------------------------------------------------KPI 3------------------------------------------------------------------
#This function tells the number of hours required, as well as the rate at which they must be supplied for each student over the max limit of M.S.S. at a given ϵ

using PyPlot

function pRSRRI()   #=where: nᵥ is the number of M.S.S. volunteers
                                     tᵥ is the total number of hours volunteered 
                                     ϵ is assumed efficiency of SIIE in providing remaining volunteering hours
                                     i is the remaining number of students with unfulfilled hours=#

    NV = (1.0:1.0:perf.nᵥ) #numerical values of students 


    nV = [(1:1.0:perf.nᵥ);]

    tv = [(perf.Rᵥ .* NV) .+ (perf.ϵ .* tᵣₑ);]

    tr = [perf.R .* NV;]

    REM = [(tr[findall(tr .> tv)] .- tv[findall(tv .< tr)]);] #number of total hours required per successive student 

    AVG = [(tr[findall(tr .> tv)] .- tv[findall(tv .< tr)]) ./ (1.0 .+ ((nV[findall(tv .< tr)] .- nV[findfirst(tv .< tr)])));] #average number of hours required per successive student 

    ver = length(REM)

    if i .> ver

        ab = print("\nInvalid number of remaining students. Remaining students must be less than or equal to ")
        bc = print(ver)
        cd = print(".")
        return ab, bc, cd
    end
    if i ≠ 0
        x = print("\nIn order to fulfill the scholarship hours for the next $i of the remaining students who volunteered this semester through the M.S.S., a total of ")
        y = print(round(REM[i], digits=3))
        z = print(" hours will be required at a rate of ")
        α = print(round(AVG[i], digits=3))
        Β = print(" hours per student.")
        return x, y, z, α, Β
    end
end

#------------------------------------------Execution Block---------------------------------------------------------------------------------------------------------------
pSRRI()
i = Int(round.(perf.nᵥ .- No))
inp_str =""

if No <perf.nᵥ
    pRSRRI()
    println("\n Type 1 to see this data represented visually by a graph.")
    inp_str = readline()
    if strip(inp_str) == "1"
        rSRRI()
        println("Press Enter to close.")
        readline()
    end

end