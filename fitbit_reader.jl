using DataFrames, Dates, JSON, ThreadsX

### Function to list all files with specific pattern in directory recursively
function listFiles(dir::String, pattern::String )
	f = String[]
	for (root, dirs, files) in walkdir(dir)
		for file in files
			if split(file, ".")[end] == pattern push!(f, joinpath(root,file)) end	
		end
	end
return(f)
end	

### get files
files = listFiles("./", "json")

### print options for read in's
println("Read In Options: 
	heart_rate
	altitude
	calories
	demographicVO2Max
	distance
	lightly_active_minutes
	moderately_active_minutes
	very_active_minutes
	resting_heart_rate
	run_vo2_max
	sedentary_minutes
	steps
	swim_lengths_data
	time_in_heart_rate_zones
	exercise
	sleep")

##############################################################################################
function read_in(inp::String, files=files, ree=ree)
	f = files[occursin.(Regex(string("/",inp)),files)]
	h = reduce(vcat, ThreadsX.collect(ree(i) for i in f))
	h = DataFrame(h)
	h[!,:dateTime] = try
				DateTime.(h.dateTime, dateformat"mm/dd/yy HH:MM:SS") .+ Dates.Year(2000)
			catch
				 DateTime.(h.dateTime, dateformat"yyyy-mm-ddTHH:MM:SS") 
		 	end
  return(h)
end

#################################################################################################
function ree(x::String)
        dat = JSON.parse(read(x, String))

	if occursin(r"/heart_rate", x) == true
		f= Array{hr}(undef,length(dat))
		@simd for i in 1:length(dat)
            		@inbounds f[i] = hr(dat[i]["dateTime"], dat[i]["value"]["bpm"], dat[i]["value"]["confidence"])
		end
	
	elseif occursin("altitude", x) == true
        	f= Array{alt}(undef,length(dat))
        	[f[i] = alt(dat[i]["dateTime"], parse(Int64,values(dat[i]["value"]))) for i in 1:length(dat)]
	
	elseif occursin("calories", x) == true
        	f= Array{cal}(undef,length(dat))
        	[f[i] = cal(dat[i]["dateTime"], parse(Float64,values(dat[i]["value"]))) for i in 1:length(dat)]
	
	elseif occursin(r"/demographic", x) == true	
        	f= Array{demVM}(undef,length(dat))
        	for i in 1:length(dat)
                	f[i] = demVM(dat[i]["dateTime"],
				 dat[i]["value"]["demographicVO2MaxError"],
			 	dat[i]["value"]["demographicVO2Max"],
			 	dat[i]["value"]["filteredDemographicVO2MaxError"],
			 	dat[i]["value"]["filteredDemographicVO2Max"] )
        	end
	elseif occursin("distance", x) == true
        	f= Array{dist}(undef,length(dat))
        	[f[i] = dist(dat[i]["dateTime"], parse(Int64,values(dat[i]["value"]))) for i in 1:length(dat)]
	
	elseif occursin("lightly_active_minutes" , x) == true
        	f= Array{lam}(undef,length(dat))
        	[f[i] = lam(dat[i]["dateTime"], parse(Int64,values(dat[i]["value"]))) for i in 1:length(dat)]
	
	elseif occursin("moderately_active_minutes", x) == true
        	f= Array{mam}(undef,length(dat))
        	[f[i] = mam(dat[i]["dateTime"], parse(Int64,values(dat[i]["value"]))) for i in 1:length(dat)]
	
	elseif occursin("very_active_minutes", x) == true
        	f= Array{vam}(undef,length(dat))
        	[f[i] = vam(dat[i]["dateTime"], parse(Int64,values(dat[i]["value"]))) for i in 1:length(dat)]
	
	elseif occursin(r"/resting_heart_rate*", x) == true
		f= Array{rest_hr}(undef,length(dat))
       		[f[i] = rest_hr(dat[i]["dateTime"], dat[i]["value"]["value"], dat[i]["value"]["error"]) for i in 1:length(dat)]
	elseif occursin("run_vo2_max", x) == true
        	f= Array{run_vo2}(undef,length(dat))
        	for i in 1:length(dat)
                	f[i] = run_vo2(dat[i]["dateTime"],
                        	 dat[i]["value"]["exerciseId"],
                         	dat[i]["value"]["runVO2MaxError"],
                         	dat[i]["value"]["filteredRunVO2MaxError"],
                         	dat[i]["value"]["filteredRunVO2Max"],
				 dat[i]["value"]["runVO2Max"] )
        	end
	elseif occursin("sedentary_minutes", x) == true
        	f= Array{sed_min}(undef,length(dat))
        	[f[i] = sed_min(dat[i]["dateTime"], parse(Int64,values(dat[i]["value"]))) for i in 1:length(dat)]

	elseif occursin("steps", x) == true
       		f= Array{step}(undef,length(dat))
        	[f[i] = step(dat[i]["dateTime"], parse(Int64,values(dat[i]["value"]))) for i in 1:length(dat)]
	elseif occursin("swim_lengths_data", x) == true
		f= Array{swim}(undef,length(dat))
        	for i in 1:length(dat)
                	f[i] = swim(dat[i]["dateTime"],
                        	 dat[i]["value"]["strokeCount"],
                         	dat[i]["value"]["lapDurationSec"],
                         	dat[i]["value"]["swimAlgorithmType"],
                         	dat[i]["value"]["swimStrokeType"])
        	end
	elseif occursin("time_in_heart_rate_zones", x) == true
		f= Array{tihrz}(undef,length(dat))
        	for i in 1:length(dat)
                	f[i] = tihrz(dat[i]["dateTime"],
                        	dat[i]["value"]["valuesInZones"]["IN_DEFAULT_ZONE_2"],
			 	dat[i]["value"]["valuesInZones"]["BELOW_DEFAULT_ZONE_1"],
                         	dat[i]["value"]["valuesInZones"]["IN_DEFAULT_ZONE_1"],
                         	dat[i]["value"]["valuesInZones"]["IN_DEFAULT_ZONE_3"])
        	end
	elseif occursin("exercise", x) == true
        	f= Array{exercs}(undef,length(dat))
        	for i in 1:length(dat)
			f[i] = exercs(dat[i]["startTime"],
			      	 	dat[i]["calories"],
				 	dat[i]["logType"],
				 	try
				 		dat[i]["steps"]
			 	 	catch
				 		missing
			 	 	end,
				 		dat[i]["manualValuesSpecified"]["calories"],
				 		dat[i]["manualValuesSpecified"]["distance"],
				 		dat[i]["manualValuesSpecified"]["steps"],
				 	try
				 		dat[i]["distanceUnit"]
			 	 	catch
			  	 		missing
			 	 	end,
				 		dat[i]["hasActiveZoneMinutes"],
				 		dat[i]["activeDuration"],
				 		dat[i]["duration"],
				 	try
					 	dat[i]["vo2Max"]["vo2Max"]
				 	catch
						missing
				 	end,
				 	try
			   	 		dat[i]["elevationGain"]
			 	 	catch
				 		missing
			 	 	end,
				 	try
				 		dat[i]["distance"]
			 	 	catch
				 		missing
			 	 	end,
				 		dat[i]["activityName"],
					 try
				  		dat[i]["pace"]
				 	catch
				 		missing
				 	end,
				 		dat[i]["originalDuration"],
				 		dat[i]["shouldFetchDetails"],
				 	try
				 		dat[i]["heartRateZones"][1]["minutes"]
			 	 	catch
				 		missing
			 	 	end,
				 	try
				 		dat[i]["heartRateZones"][2]["minutes"]
			 	 	catch
				 		missing
			 	 	end,
				 	try
				 		dat[i]["heartRateZones"][3]["minutes"]
			 	 	catch
				 		missing
			 	 	end,
				 	try
				 		dat[i]["heartRateZones"][4]["minutes"]
			 	 	catch
				 		missing
			 	 	end,
				 		dat[i]["logId"],
				 		dat[i]["activityTypeId"],
				 	try
				 		dat[i]["averageHeartRate"]
			 	 	catch
				 		missing
			 	 	end,
				 		dat[i]["hasGps"],
				 		dat[i]["activityLevel"][1]["minutes"],
				 		dat[i]["activit,yLevel"][2]["minutes"],
				 	dat[i]["activityLevel"][3]["minutes"],
				 	dat[i]["activityLevel"][4]["minutes"],
				 	try
				 		dat[i]["speed"]
			 	 	catch
				 		missing
			 	 	end,
				 		dat[i]["lastModified"])
        	end
	elseif occursin("sleep", x) == true

		f= Array{sle}(undef,length(dat))
		for i in 1:length(dat)
			f[i] = sle(dat[i]["startTime"][1:19],
			   dat[i]["endTime"],
			   dat[i]["minutesAsleep"],
			   dat[i]["minutesToFallAsleep"],
			   dat[i]["minutesAwake"],
			   dat[i]["duration" ],
			   dat[i]["timeInBed"],
			   dat[i]["mainSleep" ],
			   dat[i]["infoCode"],
			   dat[i]["minutesAfterWakeup"],
			   dat[i]["efficiency"],
			   dat[i]["type"],
			   try
			   	dat[i]["levels"]["summary"]["awake"]["minutes"]
		   	   catch
				dat[i]["levels"]["summary"]["wake"]["minutes"]
		   	   end,
			   try
			   	dat[i]["levels"]["summary"]["asleep"]["minutes"]
			   catch
		           	missing
			   end,
			   try
			   	dat[i]["levels"]["summary"]["restless"]["minutes"]
			   catch
				missing
			   end,
			   try
				dat[i]["levels"]["summary"]["light"]["minutes"]
			   catch
				missing
			  end,
			  try
				dat[i]["levels"]["summary"]["deep"]["minutes"]
			 catch
			 	missing
			 end,
			 try
			       dat[i]["levels"]["summary"]["rem"]["minutes"]
			 catch
			      missing
		      end)
		end
	else
		println("not a metric")

	end

    return(f)
end

###################################################################################################
struct alt
	dateTime::String
	altitude::Int64
end

####################################################################################################
struct cal
	dateTime::String
	calories::Float64
end

###################################################################################################
struct demVM
	dateTime::String
	demographicVO2Error::Float64
	demographicVO2Max::Float64
	filteredDemVO2MaxError::Float64
	filteredDemVO2Max::Float64
end

####################################################################################################
struct dist
	dateTime::String
        distance::Int64
end
	
#####################################################################################################
struct lam
	dateTime::String
	light_active_min::Int64
end

#####################################################################################################
struct mam
        dateTime::String
        moderately_active_min::Int64
end

####################################################################################################
struct vam
	dateTime::String
	very_active_minutes::Int64
end
######################################################################################################
struct rest_hr
	dateTime::String
	resting_hr::Float64
	error::Float64
end
###################################################################################################
struct run_vo2
	dateTime::String
	exerciseId::Int64
	runVO2MaxError::Float64
	filteredRunVO2MaxError::Float64
	filteredRunVO2Max::Float64
	runVO2Max::Float64
end

######################################################################################################

struct sed_min
	dateTime::String
	sedentary_minutes::Int64
end

######################################################################################################

struct step
	dateTime::String
	steps::Int64
end
######################################################################################################
struct swim
	dateTime::String
	strokeCount::Int64
	lapDurationSec::Int64
	swimAlgorithmType::String
	swimStrokeType::String
end


#######################################################################################################
struct tihrz
	dateTime::String
	IN_DEFAULT_ZONE_2::Float64
	BELOW_DEFAULT_ZONE_1::Float64
	IN_DEFAULT_ZONE_1::Float64
	IN_DEFAULT_ZONE_3::Float64
end

########################################################################################################

struct exercs
	dateTime::String
	calories::Int64
	logType::String
	steps::Union{Int64,Missing}
	manualValueSpecified_calories::Bool
	manualValueSpecified_distance::Bool
	manualValueSpecified_steps::Bool
	distanceUnit::Union{String,Missing}
	hasActiveZoneMinutes::Bool
	activeDuration::Int64
	duration::Int64
	vo2Max::Union{Float64,Missing}
	elevationGain::Union{Float64,Missing}
	distance::Union{Float64,Missing}
	activityName::String
	pace::Union{Float64,Missing}
	originalDuration::Int64
	shouldFetchDetails::Bool
	heartRateZones_out_of_range::Union{Int64,Missing}
	heartRateZones_fat_burn::Union{Int64,Missing}
	heartRateZones_cardio::Union{Int64,Missing}
	heartRateZones_peak::Union{Int64,Missing}
	logId::Int64
	activityTypeId::Int64
	averageHeartRate::Union{Int64,Missing}
	hasGps::Bool
	activityLevel_sedentary::Int64
	activityLevel_lightly::Int64
	activityLevel_fairly::Int64
	activityLevel_very::Int64
	speed::Union{Float64,Missing}
	lastModified::String
end


#########################################################################################################

struct sle
	dateTime::String
	endTime::String
	minutesAsleep::Int64
	minutesToFallAsleep::Int64
	minutesAwake::Int64
	duration::Int64
	timeInBed::Int64
	mainSleep::Bool
	infoCode::Int64
	minutesAfterWakeup::Int64
	efficiency::Int64
	type::String
	awake::Int64
	asleep::Union{Int64,Missing}
	restless::Union{Int64,Missing}
	light::Union{Int64,Missing}
	deep::Union{Int64,Missing}
	rem::Union{Int64,Missing}
end
###################################################################################

struct hr
        dateTime::String
        bpm::Int64
	confidence::Int64
end

###################################################################################
