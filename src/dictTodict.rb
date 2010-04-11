#!/usr/bin/env ruby
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

#############################################
# This file will transform the cedict format
# into a format which can be fed into dictfmt
# and then used from there to create dict.org
# files index and dict files.
#############################################

$KCODE = 'UTF-8'

require 'src/CCEDICTTools'
require 'digest/md5'
require 'optparse'
require 'ostruct'
include CCEDICTTools

# The max length a Chinese word can be. (Mostly used to 
# generate the dictionary for moblie application). 
# Setting this to about 4 or 5 is good for smaller devices.  
# For the web app it is not as important.
$max_zh_len = 6

$last_digest = ""

def output_version
  puts "dictTodict.rb version 1.0 Copyright 2007-2010 Rob Rohan"
  puts "Released under the GPL"
end

def main
f = File.open(@options.file, "r")
f.each_line { |line| 
	
	if(line && line[0] != 35)
		
		step1 = line.split(/\//)
		step2 = step1[0].split(/\[/)
		
		step3 = step2[0].split(/\ /)
		
		out_trad = step3[0]
		out_simp = step3[1]
		#puts "Trad: ]#{out_trad}["
		#puts "Simp: ]#{out_simp}["
		out_pinyin = step2[1].gsub(/\] /,"").downcase
		#puts "Pinyin: ]#{out_pinyin}["
		
		# Limit the output to a max length of Chinese words
		if( out_pinyin.split(" ").size <= $max_zh_len)
			
			out_digest = Digest::MD5.hexdigest(out_simp + out_trad + out_pinyin)[3..8]
		
			#make the pinyin proper pinyin
			pinyin_parts = out_pinyin.split(' ')
			out_pinyin_display = ""
			pinyin_parts.each { |sylab| 
				out_pinyin_display += CCEDICTTools.to_pinyin(sylab) + " "
			}
			#out_pinyin.chop! <= causes UTF-8 to get all wonky
			out_pinyin_display = out_pinyin_display[0, out_pinyin_display.length-1]
			
			#remove any reference to the fifth tone.  We do it here 
            #because I wanted it until now for the md5 and the 
            #"make proper pinyin" bit above
			out_pinyin.gsub!(/5/,"")
			
            if @options.d_type == "simplified"
              puts "#{out_simp}"
              puts "\t#{out_pinyin_display}"
              puts "\t"              
            elsif @options.d_type == "pinyin"
              puts "#{out_pinyin}"
              puts "\t#{out_pinyin_display}"
              puts "\t#{out_simp}"
              puts "\t"
            end

			$last_digest = out_digest
            
			#looping over each item that was separated by a ";"
			for i in 1..step1.size
				if(step1[i])
					eng = step1[i]
					if(eng[0] != 13)
						
						#we now have a single english item, but it could 
                        #be really long, and the data isn't in a great 
                        #format for searching.  So we'll clean it
						#up a bit more.
						
						#out_english += "#{eng}; "
						CCEDICTTools.remove_verbs_to(eng)
						
						#If we see mesure word text (aka classifier), add 
                        #it to the word record and skip adding it to the 
                        #English translation
						if(eng[0,2] == "CL")
							zh_measure = eng.gsub(/^CL:/,"").gsub(/\[[a-z1-5:]+\]/,"")
							pinyin_measure = eng.scan(/([a-z1-5]+)/) #.to_s
							
                            pinyin_measure = pinyin_measure.map do |pn|
								CCEDICTTools.to_pinyin( pn.to_s )
							end
							
							if pinyin_measure.size() > 1
								measure_pinyin = pinyin_measure.join(',')
							else
								measure_pinyin = pinyin_measure[0]
							end
							
                            if(@options.d_type != "english")
                              puts "\tClassifier: #{zh_measure} (#{measure_pinyin})"
                            end

							next
						end
						
						engkey = Digest::MD5.hexdigest(eng)[3..8]
						
						do_search = 1;
						if(eng.split(" ").size > 4)
							do_search = 0;
						end

                        if(@options.d_type != "english")
                          puts "\t#{i}) #{eng}"
                        else
                          print "#{eng}; "
                        end

                        
						#puts "'#{engkey}','#{eng}'"
						#puts "'#{out_digest}','#{engkey}'"
					end
				end
			end
            
            if @options.d_type == "english"
              print "\n"
              puts "\t#{out_simp}"
              puts "\t#{out_pinyin_display}"
            end

            puts "\t"
            puts "\t繁体字: #{out_trad}"
            if(@options.verbose)
              puts "\tid: #{out_digest}"
            end
            puts ""		
		end
	end
}
f.close
end

#############################################################
@options = OpenStruct.new
@options.verbose = false
@options.quiet = false
@options.d_type = "simplified"
@options.file = "input/cedict_ts.u8_CC"

opts = OptionParser.new 
opts.on('-v', '--version', 'Show the version')    { output_version; exit 0 }
opts.on('-h', '--help', 'This screen')       { puts opts; exit 0 }
opts.on('-V', '--verbose', 'Verbose')    { @options.verbose = true }
opts.on('-f', '--file [FILE]', String, 'The CEDICT file to use') do |file|
  @options.file = file
end
opts.on('-t', '--type [TYPE]', String, 'simplified, pinyin, english') do |type|
  @options.d_type = type
end
           
opts.parse!(ARGV)

main
