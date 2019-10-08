#' @param input_dir
#'
#' @param output_dir
#'
#' @export
durnit <- function(input_dir, output_dir) {

   # Initialization ----------------------------------------------------------

   if (exists("input_dir") == FALSE) stop("No input directory provided")

   if (exists("output_dir") == FALSE) stop("No output directory provided")

   input_dir <- normalizePath(input_dir, winslash = "/")

   output_dir <- normalizePath(output_dir, winslash = "/")

   if (fs::dir_exists(input_dir) == FALSE) stop("Input directory not found")

   if (fs::dir_exists(output_dir) == FALSE) {

      message("Creating missing output directory")
      fs::dir_create(output_dir)

   }

   paste("Rendering all Rmd files in ",
         input_dir, sep = "") %>%
      message

   # Make snapshot -----------------------------------------------------------

   newsnapshot <-
      fileSnapshot(input_dir,
                   recursive = TRUE,
                   file.info = TRUE,
                   md5sum = TRUE,
                   pattern = "\\.Rmd$",
                   ignore.case = TRUE,
                   include.dirs = TRUE,
                   full.names = TRUE)

   # Compare snapshots -------------------------------------------------------

   setwd(output_dir)

   if (fs::file_exists("rmdsnapshot.rds") == TRUE) {

      message("Loading snapshot in output directory")

      oldsnapshot <- readRDS("rmdsnapshot.rds")

      message("Extracting new/changed Rmd file names")

      rmdlist <-
         changedFiles(oldsnapshot, newsnapshot) %>%
         .[c("changed", "added")] %>%
         purrr::flatten_chr %>%
         normalizePath(winslash = "/") %>%
         as.list

      dirlist <-
         rmdlist %>%
         map(~fs::path_rel(.x, start = input_dir)) %>%
         map(dirname)

      outputlist <-
         rmdlist %>%
         map(~fs::path_rel(.x, start = input_dir)) %>%
         map(fs::path_ext_remove) %>%
         map(~paste(output_dir, ., ".html", sep = ""))

   } else {

      message("NO snapshot found! Writing current snapshot to output directory")
      message("Knitting ALL Rmd files in input directory and subdirectories")

      saveRDS(newsnapshot, file = "rmdsnapshot.rds")

      rmdlist <-
         newsnapshot$info %>%
         rownames %>%
         normalizePath(winslash = "/") %>%
         as.list

      dirlist <-
         rmdlist %>%
         map(~fs::path_rel(.x, start = input_dir)) %>%
         map(dirname)

      outputlist <-
         rmdlist %>%
         map(~fs::path_rel(.x, start = input_dir)) %>%
         map(fs::path_ext_remove) %>%
         map(~paste(output_dir, ., ".html", sep = ""))

   }

   # Check for directories ---------------------------------------------------

   if (length(outputlist) != 0) {

      for (i in seq_along(dirlist)) {

         if (fs::dir_exists(dirlist[[i]]) == FALSE) {

            fs::dir_create(dirlist[[i]])
            message(paste("Directory", dirlist[[i]], "not found, created"))

         } else {

            message(paste("Directory", dirlist[[i]],
                          "found for", basename(outputlist[[i]])))

         }

      }

      # Knit new/changed documents -------------------------------------------

      yamloutput <- rmdlist %>%
         map(rmarkdown::yaml_front_matter) %>%
         map(purrr::extract2, "output") %>%
         map(names)

      pwalk(list(rmdlist, outputlist, yamloutput),
            ~rmarkdown::render(input = ..1,
                               output_file = ..2,
                               output_format = ..3))

      # Save the new snapshot at the end, just in case something fails above!

      saveRDS(newsnapshot, file = "rmdsnapshot.rds")

      message("New/changed Rmd files knitted to output
directory and new snapshot saved. FINISHED")

   } else {

      message("No new or changed Rmd files in input directory. FINISHED")
   }

}
