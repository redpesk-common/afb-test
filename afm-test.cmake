###########################################################################
# Copyright 2015, 2016, 2017 IoT.bzh
#
# author: Romain Forlot <romain.forlot@iot.bzh>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/afm-test.native.sh.in ${CMAKE_CURRENT_BINARY_DIR}/afm-test.native.sh @ONLY)

if(NOT DEFINED ONTARGET)
	if("${OSRELEASE}" STREQUAL "poky-agl" OR "${OSRELEASE}" STREQUAL "yocto-build" OR "${OSRELEASE}" STREQUAL "redpesk")
		set(ONTARGET YES)
	endif()
endif()
if(ONTARGET)
	set(AFM_TEST "${CMAKE_CURRENT_SOURCE_DIR}/afm-test.target.sh")
else()
	set(AFM_TEST "${CMAKE_CURRENT_BINARY_DIR}/afm-test.native.sh")
endif()

install(PROGRAMS ${AFM_TEST} DESTINATION ${CMAKE_INSTALL_BINDIR} RENAME afm-test)
