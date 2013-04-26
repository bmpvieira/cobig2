set -x NODE_ENV development
set -x LINKEDIN_API_KEY xxxxxxxxxxxx
set -x LINKEDIN_API_SECRET xxxxxxxxxxxxxxxx
set -x LINKEDIN_USER_TOKEN xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
set -x LINKEDIN_USER_SECRET xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
set -x LINKEDIN_COMPANY cobig- # to search group members
set -x LINKEDIN_FALLBACK_USER poHIXnp037 # use this users tokens when others fail
set -x MENDELEY_CONSUMER_KEY xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
set -x MENDELEY_GROUP 3033781 # used to retrieve list of publications
set -x FACEBOOK_APP_ID xxxxxxxxxxxxxxx
set -x FACEBOOK_APP_SECRET xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
set -x FACEBOOK_REDIRECT /api/facebook/authenticate/get
set -x SESSION_SECRET 'trololololo' # for express session
set -x HOST http://localhost:3000
set -x GANALYTICS UA-xxxxxxxx-x # Google Analytics
set -x DROPBOX_APP_KEY xxxxxxxxxxxxxxx
set -x DROPBOX_APP_SECRET xxxxxxxxxxxxxxx
set -x DROPBOX_FALLBACK_USER username
# visit /dropbox/authenticate/request/username to
# get the token and secret needed for the website to
# fetch the content from the Dropbox API
