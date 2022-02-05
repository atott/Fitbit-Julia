using Dates, Statistics

##
function agg(df::DataFrame, d::Vector{Symbol}, y::String)
	if y=="day"
		form = "yyyy-mm-dd"
	elseif y=="week"		
		form = "yyyy"
	elseif y=="month"
		form="yyyy-mm"
	elseif y=="year"
		form="yyyy"
	else
		println("Pick year,month or day")
	end

	if y=="week"
		df[:,:week] =  [round((Date(i) - Date(minimum(df.dateTime))), Dates.Week) for i in df.dateTime] 
		df.week[1] = Week(1)
		t = groupby(df, [:week])
		t = combine(t, d .=> mean)
	else
		df[:,:agg] = Dates.format.(df[:,:dateTime], form)
		t = groupby(df, :agg)
		t = combine(t, d .=> mean)
	end
return(t)
end
###
