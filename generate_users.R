library(dplyr)
library(readr)

# myUsers <- tibble(user = paste0("user",stringr::str_pad(1:200,3,"left","0"))) %>%
#   rowwise() %>%
#   mutate(password = paste0(sample(c(LETTERS,letters,0:9), 6),collapse = ""))
# 
# myUsers %>%
#   write_csv("users.txt")

myUsers <- read_csv("users.txt")



# Write the commands for creating new users -------------------------------

myCmd <- "cmd.txt"
for (i in 1:nrow(myUsers)) {
  usr <- myUsers[i, ]$user
  pwd <- myUsers[i, ]$password
  write_lines(paste0("useradd ", usr), myCmd, append = TRUE)
  write_lines(paste0("echo -e \"", pwd,"\\n",pwd, "\" | passwd ", usr), myCmd, append = TRUE)
  write_lines(paste0("mkhomedir_helper ", usr), myCmd, append = TRUE)
  if (i <=10) {
    write_lines(paste0("usermod -aG sudo ", usr), myCmd, append =TRUE)
  }
}