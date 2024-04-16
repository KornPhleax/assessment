PING_TEST=$(gcloud compute ssh --tunnel-through-iap --project=$1 --zone=$2 $3 --ssh-key-file $4 -- ping $5 -c 1 | grep received | cut -d" " -f4 )
if [ "$PING_TEST" == "1" ]; then
	echo '{"result": "ping from '$3' to '$5' succesful"}'
else
    echo '{"result": "ping from '$3' to '$5' failed"}'
fi