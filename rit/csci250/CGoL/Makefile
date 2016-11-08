#
# Makefile for CompOrg Project 1 - Conway's Game of Life
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink
RSIM  = /home/fac/wrc/bin/rsim

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Object files to be created
#
OBJECTS = life_age.obj

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -o $*.out $*.obj

#
# Main target
#
main:	$(OBJECTS)
	$(RLINK) -m -o life_age.out $(OBJECTS) > life_age.map

run:	life_age.out
	$(RSIM) life_age.out

rund:	life_age.out
	$(RSIM) -d life_age.out