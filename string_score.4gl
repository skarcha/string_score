{
	String Scoring Algorithm
	https://github.com/skarcha/4gl_string_score

	Based on Javascript code by Joshaven Potter
	https://github.com/joshaven/string_score
	Ported by Antonio Pérez <aperez@skarcha.com> from version: 0.1.10

	MIT license: http://www.opensource.org/licenses/mit-license.php

	Date: Aug 12 2011
}

function string_score(string, abbreviation, fuzziness)
# Params
define string, abbreviation char(512),
       fuzziness float,
# Local variables.
       abbreviation_length,
       string_length,
       start_of_string_bonus,
       i,
       index_c_lowercase,
       index_c_uppercase,
       min_index,
       index_in_string smallint,
       abbreviation_score,
       fuzzies,
       character_score,
       total_character_score,
       final_score float,
       c char(1)

	# If the string is equal to the abbreviation, perfect match.
	if string = abbreviation then
		return 1.0
	end if
	# if it's not a perfect match and is empty return 0
	if length(abbreviation) = 0 then
		return 0.0
	end if

	let total_character_score = 0.0
	let abbreviation_length = length(abbreviation)
	let string_length = length(string)
	let fuzzies = 1.0

	# Walk through abbreviation and add up scores.
	for i = 1 to abbreviation_length
		let character_score = 0.0

		# Find the first case-insensitive match of a character.
		let c = abbreviation[i]
		let index_c_lowercase = char_pos(string, downshift(c))
		let index_c_uppercase = char_pos(string, upshift(c))

		let min_index = min_int(index_c_lowercase, index_c_uppercase)
		if (min_index > 0) then
			let index_in_string = min_index
		else
			let index_in_string = max_int(index_c_lowercase, index_c_uppercase)
		end if

		if index_in_string = 0 then
			if (fuzziness) then
				let fuzzies = fuzzies + (1 - fuzziness)
				continue for
			else
				return 0.0
			end if
		else
			let character_score = 0.1
		end if

		# Set base score for matching 'c'.
		if string[index_in_string] = c then
			let character_score = character_score + 0.1
		end if

		# Consecutive letter & start-of-string Bonus
		if index_in_string = 1 then
			# Increase the score when matching first character of the remainder
			# of the string
			let character_score = character_score + 0.6
			if i = 1 then
				# If match is the first character of the string
				# & the first character of abbreviation, add a
				# start-of-string match bonus.
				let start_of_string_bonus = True
			end if
		else
			# Acronym Bonus
			# Weighing Logic: Typing the first character of an acronym is as if you
			# preceded it with two perfect character matches.
			if string[index_in_string-1] = " " then
				let character_score = character_score + 0.8
			end if
		end if

		# Left trim the already matched part of the string
		# (forces sequential matching).
		let string = string[index_in_string+1, string_length]

		let total_character_score = total_character_score + character_score
	end for

	let abbreviation_score = total_character_score / abbreviation_length
	let final_score = ((abbreviation_score * (abbreviation_length / string_length)) + abbreviation_score) / 2.0;
	let final_score = final_score / fuzzies;

	if start_of_string_bonus and (final_score + 0.15 < 1) then
		let final_score = final_score + 0.15
	end if

	return final_score
end function


function char_pos(string, c)
define string char(512),
       c char(1),
			 i, l smallint

	let l = length(string)
	let i = 1
	while i <= l and string[i] != c
		let i = i + 1
	end while

	if i > l then
		return 0
	end if

	return i
end function


function min_int(a, b)
define a, b integer

	if a > b then
		return b
	end if

	return a
end function


function max_int(a, b)
define a, b integer

	if a > b then
		return a
	end if

	return b
end function
