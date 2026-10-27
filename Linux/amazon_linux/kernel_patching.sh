# Check to make sure the latest kernel version is being used as the default boot loader:
sudo grubby --default-kernel

# List all installed kernel versions:

sudo dnf list installed "kernel*"

# Remove all older versions on the Linux kernel:

sudo dnf remove --oldinstallonly

# List all installed kernel versions:

sudo dnf list installed "kernel*"


# Change the default boot kernel.
# It tells the GRUB bootloader which specific Linux kernel to boot into by default the next time your server restarts:

sudo grubby --set-default /boot/vmlinuz-6.12.88-119.157.amzn2023.x86_64

# Checks your exact operating system version.
# It queries the local RPM package database (-q stands for query) to find the version details of the core system-release package, which dictates your OS name # and release year:

sudo rpm -q system-release

# Checks if a newer Amazon Linux release version is available.
# It communicates with AWS repositories to see if a brand new OS minor version (like moving from 2023.5 to 2023.6) has been published. It only checks and 
# informs you; it does not install anything:

sudo dnf check-release-update

# Points your package manager to a specific version lock before upgrading.
# In Amazon Linux 2023, packages are tied to specific release versions to prevent accidental changes. Leaving this blank or adding a specific version tells 
# DNF exactly which repository snapshot to target:

sudo dnf upgrade --releasever=2023.11.20260526

Update installed packages:
sudo dnf update

# View all available release versions:

sudo dnf --showduplicates list system-release --releasever=latest

# Check for available updates using the latest release:

sudo dnf --releasever=latest check-update

# Upgrade your system to the latest release version:

sudo dnf upgrade --releasever=latest
