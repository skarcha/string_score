
main
	define string, abv char(128)
	define score float

	let string = "hello world"
	let abv = "he"
	let score = string_score (string, abv, 0.0)
	display "\"", string clipped, "\" - \"", abv clipped, "\": ", score using "&.&&&&&&&&&&&&&&&"
end main
