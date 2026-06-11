#!/bin/bash
# CC REPL CLI - talk to FiveM from the command line
# Usage:
#   ./repl.sh exec "print(GetPlayers())"
#   ./repl.sh client "return GetEntityCoords(PlayerPedId())"
#   ./repl.sh event cc:director_start
#   ./repl.sh status
#   ./repl.sh players
#   ./repl.sh log
#   ./repl.sh spawn fence
#   ./repl.sh effect gravity_low
#   ./repl.sh phase RUNNING

HOST="${CC_REPL_HOST:-http://localhost:30120/cc_repl}"

case "$1" in
    exec|e)
        shift
        curl -s -X POST "$HOST/exec" -H 'Content-Type: application/json' \
            -d "{\"code\": $(echo "$*" | jq -Rs .)}" | jq .
        ;;
    client|c)
        shift
        TARGET="${CC_TARGET:-1}"
        curl -s -X POST "$HOST/client_exec" -H 'Content-Type: application/json' \
            -d "{\"target\": $TARGET, \"code\": $(echo "$*" | jq -Rs .)}" | jq .
        ;;
    event|ev)
        shift
        NAME="$1"; shift
        ARGS="[$(echo "$@" | sed 's/ /,/g')]"
        curl -s -X POST "$HOST/event" -H 'Content-Type: application/json' \
            -d "{\"name\": \"$NAME\", \"args\": $ARGS}" | jq .
        ;;
    client_event|cev)
        shift
        TARGET="${CC_TARGET:-1}"
        NAME="$1"; shift
        curl -s -X POST "$HOST/client_event" -H 'Content-Type: application/json' \
            -d "{\"name\": \"$NAME\", \"target\": $TARGET, \"args\": [$@]}" | jq .
        ;;
    status|s)
        curl -s "$HOST/status" | jq .
        ;;
    players|p)
        curl -s "$HOST/players" | jq .
        ;;
    log|l)
        curl -s "$HOST/log" | jq -r '.[] | "\(.time) [\(.cat)] \(.msg)"'
        ;;
    spawn)
        shift
        TYPE="${1:-fence}"
        # Trigger cougar spawn on first player
        curl -s -X POST "$HOST/client_event" -H 'Content-Type: application/json' \
            -d "{\"name\": \"cc:spawn_cougar\", \"target\": -1, \"args\": [\"$TYPE\", {\"x\":0,\"y\":0,\"z\":0}]}" | jq .
        echo "Note: pos {0,0,0} means it spawns relative to player via FindGround"
        ;;
    effect|fx)
        shift
        ID="$1"
        curl -s -X POST "$HOST/event" -H 'Content-Type: application/json' \
            -d "{\"name\": \"cc:force_effect\", \"args\": [\"$ID\"]}" | jq .
        ;;
    phase)
        shift
        PHASE="$1"
        curl -s -X POST "$HOST/exec" -H 'Content-Type: application/json' \
            -d "{\"code\": \"State.SetPhase('$PHASE')\"}" | jq .
        ;;
    start)
        curl -s -X POST "$HOST/event" -H 'Content-Type: application/json' \
            -d '{"name": "cc:director_start"}' | jq .
        curl -s -X POST "$HOST/exec" -H 'Content-Type: application/json' \
            -d '{"code": "State.SetPhase(\"RUNNING\")"}' | jq .
        echo "Game started."
        ;;
    stop)
        curl -s -X POST "$HOST/event" -H 'Content-Type: application/json' \
            -d '{"name": "cc:director_stop"}' | jq .
        curl -s -X POST "$HOST/exec" -H 'Content-Type: application/json' \
            -d '{"code": "State.SetPhase(\"LOBBY\")"}' | jq .
        echo "Game stopped."
        ;;
    watch)
        # Live tail of events
        while true; do
            curl -s "$HOST/log" | jq -r '.[-5:] | .[] | "\(.time) [\(.cat)] \(.msg)"'
            sleep 2
        done
        ;;
    *)
        echo "CC REPL - FiveM CLI Bridge"
        echo ""
        echo "Commands:"
        echo "  exec|e <lua>        Execute Lua on server"
        echo "  client|c <lua>      Execute Lua on client (CC_TARGET=serverId)"
        echo "  event|ev <name>     Trigger server event"
        echo "  client_event|cev    Trigger client event"
        echo "  status|s            Get game status"
        echo "  players|p           List players"
        echo "  log|l               Show recent event log"
        echo "  spawn <type>        Spawn a cougar type"
        echo "  effect|fx <id>      Force-trigger an effect by ID"
        echo "  phase <PHASE>       Set game phase"
        echo "  start               Start the game (director + RUNNING)"
        echo "  stop                Stop the game"
        echo "  watch               Live tail event log"
        echo ""
        echo "Env: CC_REPL_HOST (default: http://localhost:30120/cc_repl)"
        echo "     CC_TARGET (default: 1, client server-id for client commands)"
        ;;
esac
