# Articles that depend on other packages are precompiled
library(knitr)

# depends on keras
knit("vignettes/civ.Rmd.txt",
     "vignettes/civ.Rmd")
