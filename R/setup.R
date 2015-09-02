library(limma)
# Create a contrast matrix to get p-values and fold-changes
contrast.matrix <- makeContrasts(
### Comparisons in control (normal condition)
                        # genotype comparison
                        ## n = 7
                        aat22 - col0,
			aba15 - col0,
			aba16 - col0,
			aba21 - col0,
			aba23 - col0,
			aba31 - col0,
			amt11 - col0,
			## n = 9
			cim10 - col0,
			cim11 - col0,
			cim13 - col0,
			cim14 - col0,
			cim6 - col0,
			cim7 - col0,
			cim9 - col0,
			cla1S - col0,
			cob2 - col0,
			## n = 7
			eto11 - col0,
			eto3 - col0,
			fad51 - col0,
			fad61 - col0,
			fah12 - col0,
			fur11 - col0,
			fus61S - col0,
			## n = 3
			gsr11 - col0,
			ixr11 - col0,
			ixr12 - col0,
			## n = 11
			mur11 - col0,
			mur111 - col0,
			mur12 - col0,
			mur21 - col0,
			mur32 - col0,
			mur42 - col0,
			mur51 - col0,
			mur61 - col0,
			mur71 - col0,
			mur81 - col0,
			mur91 - col0,
			## n = 8
			pac1S - col0,
			pad21 - col0,
			pad31 - col0,
			pad41 - col0,
			pap1D - col0,
			phyB9 - col0,
			prc11 - col0,
			rsw11 - col0,
			## n = 5
			rsw21 - col0,
			rsw31 - col0,
			sng11 - col0,
			tbr1 - col0,
			vtc11 - col0,
			##
			levels=colnames(design)
		)
