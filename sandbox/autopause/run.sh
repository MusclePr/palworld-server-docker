#!/bin/bash
# Even if the server is in a PAUSE state, communication will continue on its behalf
# so that it does not disappear from the community server list.
# If the communication content changes in a future version update,
# Use following script to check it.
# > docker exec -it palworld-server cat autopause/community/register.json

function down()
{
    docker compose logs palworld > last.log 2>&1
    docker compose down
    tail last.log
}

trap 'down' SIGINT
docker compose up --build && down
