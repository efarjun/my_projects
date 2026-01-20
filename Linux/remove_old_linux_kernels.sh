# How to remove old Amazon Linux 2023 kernel versions with vulnerabilities


# Check to make sure the latest kernel version is being used as the default boot loader:
sudo grubby --default-kernel
 

# List all installed kernel versions:
sudo dnf list installed "kernel*"
 

# Remove all older versions on the Linux kernel:
sudo dnf remove –oldinstallonly

 
# You can confirm that the old kernel versions have been removed and only the latest version exists:
sudo dnf list installed "kernel*"
