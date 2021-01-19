library(tidyverse)
library(glue)

#remotes::update_packages(c("pagedown", "xaringan"))
#remotes::update_packages()

#Params
p <- list(name = "Bird Cave Workshop 2021")

files <- tribble(~f,                                   ~nice,
                 "intro_to_r.Rmd",                   "Intro to R through Figures") %>%
  mutate(nice = paste0(p$name, " - ", nice),
         answers = 1:n() %in% 1:4)

files <- files %>%
  filter(answers == TRUE) %>%
  mutate(nice_file = glue("{nice} - answers")) %>%
  bind_rows(mutate(files, nice_file = nice)) %>%
  mutate(answers = str_detect(nice_file, "answers")) %>%
  arrange(nice)


p <- glue("{names(p)} = '{p}'") %>%
  glue_collapse(sep = ", ")

# Check spelling
for(i in seq_len(nrow(files))) {
  
  setwd("_rmd/")
  
  # Clean Cache before each run
  unlink(list.files(pattern = "_cache", full.names = TRUE), recursive = TRUE)
  
  # Render HTML
  glue("Rscript -e ",
       "\"rmarkdown::render('{files$f[i]}', ",
       "output_file = '{files$nice_file[i]}.html', ",
       "params = list({p}, hide_answers = {!files$answers[i]}))\"") %>%
    system()
  
  # Create PDFS
  message("Save as PDF")
  pagedown::chrome_print(glue("{files$nice_file[i]}.html"),
                         glue("{files$nice_file[i]}.pdf"),
                         extra_args = "--font-render-hinting=none")
  
  # Reduce size (prepress = 300 dpi, printer = 300 dpi, ebook = 150 dpi, screen = 72dpi)
  message("Make Small")
  system(glue("gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 ",
              "-dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH ",
              "-sOutputFile='./Handouts/{files$nice_file[i]}.pdf' ",
              "'{files$nice_file[i]}.pdf'"))
  
  # Make Handouts
  message("Save as Handout")
  # From https://github.com/DavidFirth/pdfjam-extras/blob/master/bin/pdfjam-slides3up
  system(glue("pdfjam --nup 1x3 --frame true --noautoscale false --delta '0cm 0.2cm' ",
              "--scale 0.87 --offset '-2.8cm 0cm' ",
              "--preamble '\\footskip 3.1cm' --pagecommand '\\thispagestyle{{plain}}' ",
              "--outfile './Handouts/' --suffix 'print' ",
              "'./Handouts/{files$nice_file[i]}.pdf'"))
  
  unlink(list.files(pattern = "_cache", full.names = TRUE), recursive = TRUE)
  setwd("../")
}
