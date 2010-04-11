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

require 'test/unit'
require 'src/CCEDICTTools'

include CCEDICTTools

class TestCCEDICTTools < Test::Unit::TestCase
	#def setup
	#end

	# def teardown
	# end

p	def test_single_to_pinyin
		rval = CCEDICTTools.to_pinyin("wo1")
		assert_equal(rval, "wō")
		
		rval = CCEDICTTools.to_pinyin("wo2")
		assert_equal(rval, "wó")
		
		rval = CCEDICTTools.to_pinyin("wo3")
		assert_equal(rval, "wǒ")
		
		rval = CCEDICTTools.to_pinyin("wo4")
		assert_equal(rval, "wò")
	end
	
	def test_umlat_to_pinyin
		rval = CCEDICTTools.to_pinyin("nu:3")
		assert_equal(rval, "nǚ")
		
		rval = CCEDICTTools.to_pinyin("lu:4")
		assert_equal(rval, "lǜ")
	end
	
	def test_remove_paren_content
		st = "(used after a verb) give it a go";
		CCEDICTTools.remove_paren_contents(st)
		assert_equal("give it a go", st)
		
		st = "bijective map (i.e. map between sets in math. that is one-to-one and onto)"
		CCEDICTTools.remove_paren_contents(st)
		assert_equal("bijective map", st)
		
		st = "do (sth for a bit to give it a try)"
		CCEDICTTools.remove_paren_contents(st)
		assert_equal("do", st)
		
		st = '"one China, one Taiwan" (policy)'
		CCEDICTTools.remove_paren_contents(st)
		assert_equal('"one China, one Taiwan"', st)
		
		st = "(verb complement indicating success)"
		CCEDICTTools.remove_paren_contents(st)
		assert_equal('verb complement indicating success', st)
	end
	
	def test_remove_verbs_to
		st = "to eat";
		CCEDICTTools.remove_verbs_to(st)
		assert_equal(st, "eat")
	end
	
	def test_line_into_array
		st = "one word worth a thousand in gold (成语 saw); valuable advice"
		assert_equal(CCEDICTTools.line_into_array(st).size, 2)
		
		st = "one word"
		assert_equal(CCEDICTTools.line_into_array(st).size, 1)
		
		st = "single sail, gentle wind (成语 saw); plain sailing"
		assert_equal(CCEDICTTools.line_into_array(st).size, 3)
	end
	
	#////////////////////////////////////////////
	
	def test_clean_english
		#puts clean_english("complete change from the normal state (成语 saw); quite uncharacteristic")
		#puts clean_english("lit. one knife to cut two segments (成语 saw); to make a clean break")
		#puts clean_english("SCO (Shanghai cooperation organization), involving China, Russia, Kazakhstan, Kyrgyzstan, Tajikistan and Uzbekistan")
		#puts clean_english("(verb complement indicating success)")
		#puts clean_english("the three rules (ruler guides subject, father guides son and husband guides wife) and five constant virtues of Confucianism (benevolence 仁, righteousness 義|义, propriety 禮|礼, wisdom 智 and fidelity 信)")
	end
	
	
end

#assert( boolean, [message] )	True if boolean
#assert_equal( expected, actual, [message] )
#assert_not_equal( expected, actual, [message] )	True if expected == actual
#assert_match( pattern, string, [message] )
#assert_no_match( pattern, string, [message] )	True if string =~ pattern
#assert_nil( object, [message] )
#assert_not_nil( object, [message] )	True if object == nil
#assert_in_delta( expected_float, actual_float, delta, [message] )	True if (actual_float - expected_float).abs <= delta
#assert_instance_of( class, object, [message] )	True if object.class == class
#assert_kind_of( class, object, [message] )	True if object.kind_of?(class)
#assert_same( expected, actual, [message])
#assert_not_same( expected, actual, [message] )	True if actual.equal?( expected ).
#assert_raise( Exception,... ) {block}
#assert_nothing_raised( Exception,...) {block}	True if the block raises (or doesn't) one of the listed exceptions.
#assert_throws( expected_symbol, [message] ) {block}
#assert_nothing_thrown( [message] ) {block}	True if the block throws (or doesn't) the expected_symbol.
#assert_respond_to( object, method, [message] )	True if the object can respond to the given method.
#assert_send( send_array, [message] )	True if the method sent to the object with the given arguments return true.
#assert_operator( object1, operator, object2, [message] )	Compares the two objects with the given operator, passes if true
#
