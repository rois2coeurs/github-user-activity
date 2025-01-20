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

HTTP_CONTENT=$(curl --write-out "%{http_code}\n" --request GET -sL --url "https://api.github.com/users/$USERNAME/events")
HTTP_STATUS=$(echo "$HTTP_CONTENT" | tail -n1)

case $HTTP_STATUS in
  0)
    echo "Error: No Connection"
    exit 1
    ;;
  200)
    ;;
  404)
    echo "Error: User $USERNAME not found"
    exit 1
    ;;
  403)
    echo "Error: API rate limit exceeded"
    exit 1
    ;;
  503)
    echo "Error: Service unavailable"
    exit 1
    ;;
  *)
    echo "Error: HTTP status $HTTP_STATUS"
    exit 1
    ;;
esac

EVENTS=$(echo "$HTTP_CONTENT" | sed '$d')

GROUPEDBY=$(echo "$EVENTS" | jq -c '.[] | {type: .type, repo: .repo.name, created_at: .created_at}' | jq -s 'group_by(.repo) | map({repo: .[0].repo, events: group_by(.type) | map({type: .[0].type, events: .})})')

echo "GitHub activity for $USERNAME"

for i in $(echo "$GROUPEDBY" | jq -c '.[]'); do
  REPO=$(echo "$i" | jq -r '.repo')
  for j in $(echo "$i" | jq -c '.events[]'); do
    TYPE=$(echo "$j" | jq -r '.type')
    COUNT=$(echo "$j" | jq -c '.events | length')
    printByType "$REPO" "$TYPE" "$COUNT"
  done
done