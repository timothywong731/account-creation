library(dplyr)
library(readr)
library(stringr)

# Generate user name and password
myUsers <- tibble(user = paste0("user",str_pad(1:100,3, "left", "0"))) %>%
  rowwise() %>%
  mutate(password = c(sample(LETTERS, 3), 
                      sample(letters, 3),
                      sample(0:9, 3),
                      sample(c("!", "_", "~", "@","#", "$", "%", "^", "*", "+"), 1)) %>% 
           sample(10) %>% 
           paste0(collapse = ""))

# Save the password as a flat file
myUsers %>%
  write_csv("users.csv")

# Read the user/password file
myUsers <- read_csv("users.csv")

# Write the commands for creating new users -------------------------------

myCmd <- "cmd.txt"
for (i in 1:nrow(myUsers)) {
  usr <- myUsers[i, ]$user
  pwd <- myUsers[i, ]$password
  write_lines(paste0("useradd ", usr), myCmd, append = TRUE)
  write_lines(paste0("echo -e \"", pwd,"\\n",pwd, "\" | passwd ", usr), myCmd, append = TRUE)
  write_lines(paste0("mkhomedir_helper ", usr), myCmd, append = TRUE)
  if (i <=10) {
    # Use "wheel" for CENTOS
    # Use "sudo" for Ubuntu
    write_lines(paste0("usermod -aG wheel ", usr), myCmd, append =TRUE)
  }
}
