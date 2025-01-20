function printByType() {
  REPONAME=$1
  TYPE=$2
  COUNT=$3
  case $TYPE in
    "PushEvent")
      echo "- Pushed $COUNT commits to $REPONAME"
      ;;
    "PullRequestEvent")
      echo "- Opened $COUNT pull requests on $REPONAME"
      ;;
    "CommitCommentEvent")
      echo "- Commented $COUNT times on commits in $REPONAME"
      ;;
    "CreateEvent")
      echo "- Created $COUNT branches/tags in $REPONAME"
      ;;
    "DeleteEvent")
      echo "- Deleted $COUNT branches/tags in $REPONAME"
      ;;
    "ForkEvent")
      echo "- Forked $COUNT times $REPONAME"
      ;;
    "GollumEvent")
      echo "- Created $COUNT wiki pages in $REPONAME"
      ;;
    "IssueCommentEvent")
      echo "- Commented $COUNT times on issues in $REPONAME"
      ;;
    "IssuesEvent")
      echo "- Opened $COUNT issues in $REPONAME"
      ;;
    "MemberEvent")
      echo "- Added $COUNT collaborators to $REPONAME"
      ;;
    "PublicEvent")
      echo "- Made $COUNT repositories public"
      ;;
    "PullRequestReviewEvent")
      echo "- Reviewed $COUNT pull requests in $REPONAME"
      ;;
    "PullRequestReviewCommentEvent")
      echo "- Commented $COUNT times on pull requests in $REPONAME"
      ;;
    "PullRequestReviewThreadEvent")
      echo "- Commented $COUNT times on pull requests in $REPONAME"
      ;;
    "ReleaseEvent")
      echo "- Published $COUNT releases in $REPONAME"
      ;;
    "SponsorshipEvent")
      echo "- Sponsored $COUNT times $REPONAME"
      ;;
    "WatchEvent")
      echo "- Starred $COUNT times $REPONAME"
      ;;
    *)
      echo "- $COUNT $TYPE to $REPONAME"
      ;;
  esac
  }

USERNAME=$1

if [ -z "$USERNAME" ]; then
  echo "Usage: github-activity.sh <username>"
  exit 1
fi

EVENTS=$(curl --request GET -sL --url "https://api.github.com/users/$USERNAME/events")

GROUPEDBY=$(echo "$EVENTS" | jq -c '.[] | {type: .type, repo: .repo.name, created_at: .created_at}' | jq -s 'group_by(.repo) | map({repo: .[0].repo, events: group_by(.type) | map({type: .[0].type, events: .})})')

for i in $(echo "$GROUPEDBY" | jq -c '.[]'); do
  REPO=$(echo "$i" | jq -r '.repo')
  for j in $(echo "$i" | jq -c '.events[]'); do
    TYPE=$(echo "$j" | jq -r '.type')
    COUNT=$(echo "$j" | jq -c '.events | length')
    printByType "$REPO" "$TYPE" "$COUNT"
  done
done