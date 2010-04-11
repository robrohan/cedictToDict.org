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

# To test out local dictionaires you can
# use:
# $ dict -h 127.0.0.1 -p 2628 test

# What kind of dictioary to generate. 
# Meaning, which part should be searchable?
# Can be: simplified, pinyin, or english
DICT_TYPE=simplified

all: fdoc_from_ce fdoc_to_dict

download:
	cd ./input; wget "http://www.mdbg.net/chindict/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip"
	cd ./input; unzip cedict_1_0_ts_utf-8_mdbg.zip
# should give us input/cedict_ts.u8

fdoc_from_ce:
	mkdir ./output/${DICT_TYPE}
	/usr/bin/env ruby ./src/dictTodict.rb \
		-f ./input/cedict_ts.u8 \
		-t ${DICT_TYPE} > ./output/${DICT_TYPE}/${DICT_TYPE}.foldoc

fdoc_to_dict:
# change the format from F.O.L.D.O.C. format
# to the dict.org style
	cd ./output/${DICT_TYPE}; dictfmt -f \
			--utf8 \
			--allchars \
			-u "http://xiaocidian.com" \
			-s "小词典 - ${DICT_TYPE} - Powered by CC-CEDICT.org" \
			--headword-separator ";" \
			${DICT_TYPE} < ${DICT_TYPE}.foldoc
	rm output/${DICT_TYPE}/${DICT_TYPE}.foldoc

test:
	/usr/bin/env ruby ./tests/Main.rb

dist:
	cd ./output; zip -r ${DICT_TYPE}.zip ${DICT_TYPE}

clean:
	rm -rf ./output/${DICT_TYPE}

install:
	sudo cp ./output/${DICT_TYPE}/${DICT_TYPE}.* /usr/share/dictd/
	sudo chmod a+r /usr/share/dictd/${DICT_TYPE}.*
#sudo dictdconfig -w
#sudo /etc/init.d/dictd restart
