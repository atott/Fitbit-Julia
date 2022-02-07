using Dates, Statistics

##
function agg_mean(df::DataFrame, d::Vector{Symbol}, y::String)
	if y=="day"
		df[:,:dateTime] = floor.(df[:,:dateTime], Day(1))
	elseif y=="week"		
		df[:,:dateTime] = floor.(df[:,:dateTime], Week(1))
	elseif y=="month"
		df[:,:dateTime] = floor.(df[:,:dateTime], Month(1))
	elseif y=="year"
		df[:,:dateTime] = floor.(df[:,:dateTime], Year(1))
	else
		println("Pick year,month or day")
	end
combine(groupby(df, [:dateTime]), d .=> mean)
end
###


##
function agg_sum(df::DataFrame, d::Vector{Symbol}, y::String)
	if y=="day"
		df[:,:dateTime] = floor.(df[:,:dateTime], Day(1))
	elseif y=="week"		
		df[:,:dateTime] = floor.(df[:,:dateTime], Week(1))
	elseif y=="month"
		df[:,:dateTime] = floor.(df[:,:dateTime], Month(1))
	elseif y=="year"
		df[:,:dateTime] = floor.(df[:,:dateTime], Year(1))
	else
		println("Pick year,month or day")
	end
combine(groupby(df, [:dateTime]), d .=> sum)
end
###


##
function agg_max(df::DataFrame, d::Vector{Symbol}, y::String)
	if y=="day"
		df[:,:dateTime] = floor.(df[:,:dateTime], Day(1))
	elseif y=="week"		
		df[:,:dateTime] = floor.(df[:,:dateTime], Week(1))
	elseif y=="month"
		df[:,:dateTime] = floor.(df[:,:dateTime], Month(1))
	elseif y=="year"
		df[:,:dateTime] = floor.(df[:,:dateTime], Year(1))
	else
		println("Pick year,month or day")
	end
combine(groupby(df, [:dateTime]), d .=> maximum)
end
############################################################
function agg_min(df::DataFrame, d::Vector{Symbol}, y::String)
	if y=="day"
		df[:,:dateTime] = floor.(df[:,:dateTime], Day(1))
	elseif y=="week"		
		df[:,:dateTime] = floor.(df[:,:dateTime], Week(1))
	elseif y=="month"
		df[:,:dateTime] = floor.(df[:,:dateTime], Month(1))
	elseif y=="year"
		df[:,:dateTime] = floor.(df[:,:dateTime], Year(1))
	else
		println("Pick year,month or day")
	end
combine(groupby(df, [:dateTime]), d .=> minimum)
end

#############################################################
