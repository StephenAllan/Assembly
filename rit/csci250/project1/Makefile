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
# Main build file
#
MAIN = life_age

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
main:	$(MAIN).obj
	$(RLINK) -m -o $(MAIN).out $(MAIN).obj > $(MAIN).map

run:	$(MAIN).out
	$(RSIM) $(MAIN).out

rund:	$(MAIN).out
	$(RSIM) -d $(MAIN).out

clean:	
	rm $(MAIN).lst $(MAIN).map $(MAIN).obj $(MAIN).out