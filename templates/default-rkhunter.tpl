# Defaults for rkhunter automatic tasks
# sourced by /etc/cron.*/rkhunter and /etc/apt/apt.conf.d/90rkhunter
#
# This is a POSIX shell fragment
#

# Set this to yes to enable rkhunter daily runs
CRON_DAILY_RUN="yes"

# Set this to yes to enable rkhunter weekly database updates
CRON_DB_UPDATE="yes"

# Set this to yes to enable reports of weekly database updates
DB_UPDATE_EMAIL="yes"

# Set this to the email address where reports and run output should be sent
REPORT_EMAIL="rkhunter@%%domain%%"

# Set this to yes to enable automatic database updates
APT_AUTOGEN="yes"

# Nicenesses range from -20 (most favorable scheduling) to 19 (least favorable)
NICE="0"

# Should daily check be run when running on battery
# powermgmt-base is required to detect if running on battery or on AC power
RUN_CHECK_ON_BATTERY="false" 
