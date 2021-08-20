##########################################################################
#                                                                        #
#  This file is part of WP plug-in of Frama-C.                           #
#                                                                        #
#  Copyright (C) 2007-2014                                               #
#    CEA (Commissariat a l'energie atomique et aux energies              #
#         alternatives)                                                  #
#                                                                        #
#  you can redistribute it and/or modify it under the terms of the GNU   #
#  Lesser General Public License as published by the Free Software       #
#  Foundation, version 2.1.                                              #
#                                                                        #
#  It is distributed in the hope that it will be useful,                 #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#  GNU Lesser General Public License for more details.                   #
#                                                                        #
#  See the GNU Lesser General Public License version 2.1                 #
#  for more details (enclosed in the file licenses/LGPLv2.1).            #
#                                                                        #
##########################################################################

# --------------------------------------------------------------------------
# ---  Coq Compilation
# --------------------------------------------------------------------------

.PHONY: all compile clean depend

all: compile

.SUFFIXES: .v .vo

.v.vo:
	coqc $(INCLUDES) $<

depend:
	coqdep $(INCLUDES) -slash *.v **/*.v > .depend 

clean:
	rm -f *.glob *.vo **/*.glob **/*.vo

sinclude .depend

# End of file

##########################################################################
# Local Variables:
# mode: makefile
# End:
