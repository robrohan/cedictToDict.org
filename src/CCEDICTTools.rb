# -*- coding: utf-8 -*-
########################################
# Copyright 2007-2010 Rob Rohan
# 
# This file is part of cedictToDict.org.
#
# cedictToDict.org is free software: you 
# can redistribute it and/or modify it under 
# the terms of the GNU General Public License 
# as published by the Free Software 
# Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# cedictToDict.org is distributed in the hope 
# that it will be useful, but WITHOUT ANY 
# WARRANTY; without even the implied warranty 
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
# PURPOSE. See the GNU General Public License 
# for more details.
# 
# You should have received a copy of the GNU 
# General Public License along with 
# cedictToDict.org. If not, see 
# http://www.gnu.org/licenses/.
########################################

########################################
# These are common functions needed
# when breaking pinyin apart, adding
# tones, etc.  It also has some
# utility functions to help deal with
# the CCCEDICT raw file format
########################################

module CCEDICTTools
	#Letters that take tones in reverse order of preference
	@tone_letters = ['a','o','e','i','u','ü']
	#Tones in reverse order with tone marks
	@tone_order = [
		'ā','ō','ē','ī','ū','ǖ',
		'á','ó','é','í','ú','ǘ',
		'ǎ','ǒ','ě','ǐ','ǔ','ǚ',
		'à','ò','è','ì','ù','ǜ',
		'a','o','e','i','u','ü'
	]
	
	#convert the bu4 type pinyin into the bù type
	#input to this function would be something like "bu4"
	# or "nu:3"
	def to_pinyin(st)
		#get the tone number
		tone_number = st[st.length-1, st.length]
		#remove the tone number
		#st.chop! <= messes up utf-8
		#st = st[0, st.length-1] <= so does that
		st.gsub!(/[1-5]/,'')

		#We also need to make sure n: gets turned into ü
		st.gsub!(/u:/,'ü')

		#loop over the tone letters and find the one that
		#gets the mark.
		last_find_char = ''
		last_find_idx = 0
		i = 0
		@tone_letters.each { |tm| 
			if st.match(tm)
				last_find_char = tm
				last_find_idx = i
				break
			end
			i=i+1
		}

		#now replace the found marker char with the proper tone marked char
		#(the 6 is because their are 6 letters that can take tones)
		st.gsub!(last_find_char, @tone_order[ ((tone_number.to_i-1)*6) + last_find_idx ])

		return st
	end

	def clean_english(st)
		remove_paren_contents(st)
		
		st = line_into_array(st)
		if(st.size > 1) 
			st.each { |line|
				line.strip!
			}
			return st
		else
			st[0].strip!
			return st
		end
	end


	def remove_paren_contents(st)
		tp = st.gsub(/\(.*\)/,"").strip
		#if all there was was paren text, just remove the parens
		if("".eql?(tp))
			st.gsub!(/[\(\)]/, "").strip!
		else
			st.gsub!(/\(.*\)/,"").strip!
			#st = tp
		end
	end
	
	def remove_verbs_to(st)
		st.gsub!(/^to /,"")
		st.strip!
	end
	
	def line_into_array(st)
		return st.split(/[,;]/)
	end
end
