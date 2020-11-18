library(tidyverse)
library(glue)

detach_package <- function(pkg, character.only = FALSE)
{
  if(!character.only)
  {
    pkg <- deparse(substitute(pkg))
  }
  search_item <- paste("package", pkg, sep = ":")
  while(search_item %in% search())
  {
    detach(search_item, unload = TRUE, character.only = TRUE)
  }
}

if(!dir.exists("./_rmd/Handouts")) dir.create("./_rmd/Handouts")

f <- "_rmd/tws_intro_to_r.Rmd"
nice <- "TWS - Intro to R through Figures 2020"

if(file.exists(f)) {
  # Clean Cache
  basename(f) %>%
    str_remove(".Rmd") %>%
    glue("_cache") %>%
    unlink()
  
  system(glue("Rscript -e ",
              "'rmarkdown::render(\"{f}\", ",
              "output_file = \"{nice} - answers.html\", ",
              "params = list(hide_answers = FALSE))'"))
  
  system(glue("Rscript -e ",
              "'rmarkdown::render(\"{f}\", ",
              "output_file = \"{nice}.html\", ",
              "params = list(hide_answers = TRUE))'"))
  
  for(a in c(" - answers", "")) {
    
    message("Save as PDF")
    pagedown::chrome_print(glue("./_rmd/{nice}{a}.html"),
                           glue("./_rmd/{nice}{a}.pdf"))
    
    # Reduce size (prepress = 300 dpi, printer = 300 dpi, ebook = 150 dpi, screen = 72dpi)
    message("Make Small")
    system(glue("gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 ",
                "-dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH ",
                "-sOutputFile='./_rmd/Handouts/{nice}{a}.pdf' ",
                "'./_rmd/{nice}{a}.pdf'"))
    
    # Make Handouts
    message("Save as Handout")
    # From https://github.com/DavidFirth/pdfjam-extras/blob/master/bin/pdfjam-slides3up
    system(glue("pdfjam --nup 1x3 --frame true --noautoscale false --delta '0cm 0.2cm' ",
                "--scale 0.87 --offset '-2.8cm 0cm' ",
                "--preamble '\\footskip 3.1cm' --pagecommand '\\thispagestyle{{plain}}' ",
                "--outfile './_rmd/Handouts/' --suffix 'print' ",
                "'./_rmd/Handouts/{nice}{a}.pdf'"))

  }
  unlink(list.files("./_rmd/", "_cache", full.names = TRUE), recursive = TRUE)
}


