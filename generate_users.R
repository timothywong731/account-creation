library(dplyr)
library(readr)
library(stringr)

MY_USER_FILE <- "users.csv"
MY_CMD <- "cmd.sh"

# Generate user name and password
myUsers <- tibble(user = paste0("user",str_pad(1:100,3, "left", "0"))) %>%
  rowwise() %>%
  mutate(password = c(sample(c(LETTERS, letters), 6),
                      sample(c("!", "_", "~", "@","#", "^"), 1),
                      sample(0:9, 3)) %>% 
paste0(collapse = ""))

# Save the password as a flat file
myUsers %>%
  write_csv(MY_USER_FILE)

# Read the user/password file
myUsers <- read_csv(MY_USER_FILE)

# Write the commands for creating new users -------------------------------


system(paste0("rm -rf ", MY_CMD))

for (i in 1:nrow(myUsers)) {
  usr <- myUsers[i, ]$user
  pwd <- myUsers[i, ]$password
  write_lines(paste0("useradd ", usr), MY_CMD, append = TRUE)
  write_lines(paste0("echo -e \"", pwd,"\\n",pwd, "\" | passwd ", usr), MY_CMD, append = TRUE)
  write_lines(paste0("mkhomedir_helper ", usr), MY_CMD, append = TRUE)
  if (i <=10) {
    # Use "wheel" for CENTOS
    # Use "sudo" for Ubuntu
    write_lines(paste0("usermod -aG sudo ", usr), MY_CMD, append =TRUE)
  }
  write_lines("", MY_CMD, append = TRUE)
}
