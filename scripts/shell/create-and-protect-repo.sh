#!/bin/sh

#############################################################
# Shell script to Create and Initialize GitHub repository   #
# The script will also set basic configs and protect master #
# Owner: Dow DevOps                                         #
#############################################################

###################
# Input Variables #
###################
REPO_NAME=$1   # Name of the GitHub Repository
API_TOKEN=$2   # GitHub Personal Access Token
BOT_NAME=$3    # Name of the Hubot pulled from Env
BOT_EMAIL=$4   # Email for the Hubot pulled from Env
ORG_NAME='Migarjo-Test-Org'   # Name of the master Org
TEMPLATE_REPO='dow-dmc'       # Teplate repo to clone
TEAM_ID='2237075'             # Team ID for Dow
LOG_FILE='/dev/null 2>&1'          # File to push output
STATUS_CHECK_NAME='Some Status Check'  # Name of the default status check that should pass

##############
#### MAIN ####
##############

################################################################################
# Test the input for sanity
################################################################################
# Test REPO_NAME
#echo $REPO_NAME
test -z $REPO_NAME && echo "REPO_NAME Required!" 1>&2 && exit 1

# TEST API_TOKEN
#echo $API_TOKEN
test -z $API_TOKEN && echo "API_TOKEN Required!" 1>&2 && exit 1

################################################################################
# Curl to GitHub to create repository
# Curl Example: https://developer.github.com/v3/repos/#create
################################################################################
echo "------------------------------------------"
echo "Creating Repository:[$ORG_NAME/$REPO_NAME]..."
echo "------------------------------------------"
curl -s -H "Authorization: token $API_TOKEN" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/orgs/$ORG_NAME/repos" \
   -d "{\"name\":\"$REPO_NAME\", \
   \"private\":\"true\", \
   \"has_issues\":\"true\", \
   \"has_projects\":\"true\", \
   \"has_wiki\":\"true\", \
   \"team_id\":\"$TEAM_ID\", \
   \"auto_init\":\"true\"}" > $LOG_FILE

############################################
# Check that the shell returned successful #
############################################
if [ $? != 0 ]; then
   echo "ERROR! Failed to create Repo:[$ORG_NAME/$REPO_NAME]!"
   exit 1
else
   echo "Successfully Initialized Repo:[$ORG_NAME/$REPO_NAME]"
fi

################################################################################
# Initalize the repo with basic Files
################################################################################

echo "------------------------------------------"
echo "Initializing Repository templates..."
echo "------------------------------------------"

# Remove any left over cloned directories
rm -rf $TEMPLATE_REPO $REPO_NAME

# Clone the base and template repo
git clone https://$API_TOKEN@github.com/$ORG_NAME/$TEMPLATE_REPO.git > $LOG_FILE
git clone https://$API_TOKEN@github.com/$ORG_NAME/$REPO_NAME.git > $LOG_FILE

# Remove the .git from template repo so we dont copy that over
rm -rf $TEMPLATE_REPO/.git

# Copy all files and hidden files from template to new repo
cp -R $TEMPLATE_REPO/* $REPO_NAME/
cp -R $TEMPLATE_REPO/.[a-zA-Z0-9]* $REPO_NAME/

# Git add the files
cd $REPO_NAME
git add . > $LOG_FILE

# Config the git user and commit the code to the new repo
git config user.email \'$BOT_EMAIL\'; git config user.name \'$BOT_NAME\'; git commit -m "Initial commit with documents" > $LOG_FILE

# Push the code back to GitHub
git push > $LOG_FILE

# Remove the repos from the system as housekeeping
rm -rf $TEMPLATE_REPO $REPO_NAME


################################################################################
# Curl to GitHub to protect branch
# Example: https://developer.github.com/v3/repos/branches/#update-branch-protection
################################################################################
echo "------------------------------------------"
echo "Protecting the master Branch..."
echo "------------------------------------------"
curl -s -H "Authorization: token $API_TOKEN" -H "Accept: application/vnd.github.v3+json" \
  -X PUT "https://api.github.com/repos/$ORG_NAME/$REPO_NAME/branches/master/protection" \
  -d "{\"enforce_admins\": true, \
	\"required_status_checks\": { \
		\"strict\": true, \
		\"contexts\": [\"$STATUS_CHECK_NAME\"]}, \
	\"required_pull_request_reviews\": { \
		\"dismiss_stale_reviews\": true , \
      \"require_code_owner_reviews\": true },\
	\"restrictions\": null }" > $LOG_FILE

############################################
# Check that the shell returned successful #
############################################
if [ $? != 0 ]; then
   echo "ERROR! Failed to protect Repo:[$ORG_NAME/$REPO_NAME]!"
   exit 1
else
   echo "Successfully protected Repo:[$ORG_NAME/$REPO_NAME]"
fi
