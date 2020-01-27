echo "Namespace ${1} shows the following resources:"

kubectl -n $1 get all

read -p "Delete namespace?  " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

kubectl proxy &
PID=$!
echo "Deleting ${1} namespace"
kubectl get ns $1 -o json | \
  jq '.spec.finalizers=[]' | \
  curl -X PUT http://localhost:8001/api/v1/namespaces/${1}/finalize -H "Content-Type: application/json" --data @-

kill $PID
