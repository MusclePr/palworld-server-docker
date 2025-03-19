#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

config_file="/palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"
config_dir=$(dirname "$config_file")

mkdir -p "$config_dir" || exit
# If file exists then check if it is writable
if [ -f "$config_file" ]; then
    if ! isWritable "$config_file"; then
        LogError "Unable to create $config_file"
        exit 1
    fi
# If file does not exist then check if the directory is writable
elif ! isWritable "$config_dir"; then
    # Exiting since the file does not exist and the directory is not writable.
    LogError "Unable to create $config_file"
    exit 1
fi

LogAction "Compiling PalWorldSettings.ini"

# Deprecation warnings
if [ -n "$ALLOW_CONNECT_PLATFORM" ]; then
    LogWarn "ALLOW_CONNECT_PLATFORM is deprecated and will not be applied to the PalWorldSettings.ini. Please use CROSSPLAY_PLATFORMS instead."
fi

export DIFFICULTY=${DIFFICULTY:-None}
export RANDOMIZER_TYPE=${RANDOMIZER_TYPE:-None}
export RANDOMIZER_SEED=\"${RANDOMIZER_SEED:-""}\"
export DAYTIME_SPEEDRATE=${DAYTIME_SPEEDRATE:-1.000000}
export NIGHTTIME_SPEEDRATE=${NIGHTTIME_SPEEDRATE:-1.000000}
export EXP_RATE=${EXP_RATE:-1.000000}
export PAL_CAPTURE_RATE=${PAL_CAPTURE_RATE:-1.000000}
export PAL_SPAWN_NUM_RATE=${PAL_SPAWN_NUM_RATE:-1.000000}
export PAL_DAMAGE_RATE_ATTACK=${PAL_DAMAGE_RATE_ATTACK:-1.000000}
export PAL_DAMAGE_RATE_DEFENSE=${PAL_DAMAGE_RATE_DEFENSE:-1.000000}
export PLAYER_DAMAGE_RATE_ATTACK=${PLAYER_DAMAGE_RATE_ATTACK:-1.000000}
export PLAYER_DAMAGE_RATE_DEFENSE=${PLAYER_DAMAGE_RATE_DEFENSE:-1.000000}
export PLAYER_STOMACH_DECREASE_RATE=${PLAYER_STOMACH_DECREASE_RATE:-1.000000}
export PLAYER_STAMINA_DECREASE_RATE=${PLAYER_STAMINA_DECREASE_RATE:-1.000000}
export PLAYER_AUTO_HP_REGEN_RATE=${PLAYER_AUTO_HP_REGEN_RATE:-1.000000}
export PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP=${PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP:-1.000000}
export PAL_STOMACH_DECREASE_RATE=${PAL_STOMACH_DECREASE_RATE:-1.000000}
export PAL_STAMINA_DECREASE_RATE=${PAL_STAMINA_DECREASE_RATE:-1.000000}
export PAL_AUTO_HP_REGEN_RATE=${PAL_AUTO_HP_REGEN_RATE:-1.000000}
export PAL_AUTO_HP_REGEN_RATE_IN_SLEEP=${PAL_AUTO_HP_REGEN_RATE_IN_SLEEP:-1.000000}
export BUILD_OBJECT_HP_RATE=${BUILD_OBJECT_HP_RATE:-1.000000}
export BUILD_OBJECT_DAMAGE_RATE=${BUILD_OBJECT_DAMAGE_RATE:-1.000000}
export BUILD_OBJECT_DETERIORATION_DAMAGE_RATE=${BUILD_OBJECT_DETERIORATION_DAMAGE_RATE:-1.000000}
export COLLECTION_DROP_RATE=${COLLECTION_DROP_RATE:-1.000000}
export COLLECTION_OBJECT_HP_RATE=${COLLECTION_OBJECT_HP_RATE:-1.000000}
export COLLECTION_OBJECT_RESPAWN_SPEED_RATE=${COLLECTION_OBJECT_RESPAWN_SPEED_RATE:-1.000000}
export ENEMY_DROP_ITEM_RATE=${ENEMY_DROP_ITEM_RATE:-1.000000}
export DEATH_PENALTY=${DEATH_PENALTY:-All}
export ENABLE_PLAYER_TO_PLAYER_DAMAGE=${ENABLE_PLAYER_TO_PLAYER_DAMAGE:-False}
export ENABLE_FRIENDLY_FIRE=${ENABLE_FRIENDLY_FIRE:-False}
export ENABLE_INVADER_ENEMY=${ENABLE_INVADER_ENEMY:-True}
export ACTIVE_UNKO=${ACTIVE_UNKO:-False}
export ENABLE_AIM_ASSIST_PAD=${ENABLE_AIM_ASSIST_PAD:-True}
export ENABLE_AIM_ASSIST_KEYBOARD=${ENABLE_AIM_ASSIST_KEYBOARD:-False}
export DROP_ITEM_MAX_NUM=${DROP_ITEM_MAX_NUM:-3000}
export DROP_ITEM_MAX_NUM_UNKO=${DROP_ITEM_MAX_NUM_UNKO:-100}
export BASE_CAMP_MAX_NUM=${BASE_CAMP_MAX_NUM:-128}
export BASE_CAMP_WORKER_MAX_NUM=${BASE_CAMP_WORKER_MAX_NUM:-15}
export DROP_ITEM_ALIVE_MAX_HOURS=${DROP_ITEM_ALIVE_MAX_HOURS:-1.000000}
export AUTO_RESET_GUILD_NO_ONLINE_PLAYERS=${AUTO_RESET_GUILD_NO_ONLINE_PLAYERS:-False}
export AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS=${AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS:-72.000000}
export GUILD_PLAYER_MAX_NUM=${GUILD_PLAYER_MAX_NUM:-20}
export BASE_CAMP_MAX_NUM_IN_GUILD=${BASE_CAMP_MAX_NUM_IN_GUILD:-4}
export PAL_EGG_DEFAULT_HATCHING_TIME=${PAL_EGG_DEFAULT_HATCHING_TIME:-72.000000}
export WORK_SPEED_RATE=${WORK_SPEED_RATE:-1.000000}
export AUTO_SAVE_SPAN=${AUTO_SAVE_SPAN:-30.000000}
export IS_MULTIPLAY=${IS_MULTIPLAY:-False}
export IS_PVP=${IS_PVP:-False}
export HARDCORE=${HARDCORE:-False}
export PAL_LOST=${PAL_LOST:-False}
export CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP=${CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP:-False}
export ENABLE_NON_LOGIN_PENALTY=${ENABLE_NON_LOGIN_PENALTY:-True}
export ENABLE_FAST_TRAVEL=${ENABLE_FAST_TRAVEL:-True}
export IS_START_LOCATION_SELECT_BY_MAP=${IS_START_LOCATION_SELECT_BY_MAP:-True}
export EXIST_PLAYER_AFTER_LOGOUT=${EXIST_PLAYER_AFTER_LOGOUT:-False}
export ENABLE_DEFENSE_OTHER_GUILD_PLAYER=${ENABLE_DEFENSE_OTHER_GUILD_PLAYER:-False}
export INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX=${INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX:-False}
export BUILD_AREA_LIMIT=${BUILD_AREA_LIMIT:-False}
export ITEM_WEIGHT_RATE=${ITEM_WEIGHT_RATE:-1.000000}
export COOP_PLAYER_MAX_NUM=${COOP_PLAYER_MAX_NUM:-4}
export SERVER_PLAYER_MAX_NUM=${PLAYERS:-32}
export SERVER_NAME=\"${SERVER_NAME:-"Default Palworld Server"}\"
export SERVER_DESCRIPTION=\"${SERVER_DESCRIPTION:-""}\"
export ADMIN_PASSWORD=\"${ADMIN_PASSWORD:-""}\"
export SERVER_PASSWORD=\"${SERVER_PASSWORD:-""}\"
export PUBLIC_PORT=${PUBLIC_PORT:-8211}
export PUBLIC_IP=\"${PUBLIC_IP:-""}\"
export RCON_ENABLED=${RCON_ENABLED:-False}
export RCON_PORT=${RCON_PORT:-25575}
export REGION=\"${REGION:-""}\"
export USEAUTH=${USEAUTH:-True}
export BAN_LIST_URL=\"${BAN_LIST_URL:-https://api.palworldgame.com/api/banlist.txt}\"
export REST_API_ENABLED=\"${REST_API_ENABLED:-False}\"
export REST_API_PORT=\"${REST_API_PORT:-8212}\"
export SHOW_PLAYER_LIST=${SHOW_PLAYER_LIST:-True}
export CHAT_POST_LIMIT_PER_MINUTE=${CHAT_POST_LIMIT_PER_MINUTE:-10}
export USE_BACKUP_SAVE_DATA=${USE_BACKUP_SAVE_DATA:-True}
export SUPPLY_DROP_SPAN=${SUPPLY_DROP_SPAN:-180}
export ENABLE_PREDATOR_BOSS_PAL=${ENABLE_PREDATOR_BOSS_PAL:-True}
export MAX_BUILDING_LIMIT_NUM=${MAX_BUILDING_LIMIT_NUM:-0}
export SERVER_REPLICATE_PAWN_CULL_DISTANCE=${SERVER_REPLICATE_PAWN_CULL_DISTANCE:-15000.000000}
export CROSSPLAY_PLATFORMS=${CROSSPLAY_PLATFORMS:-"(Steam,Xbox,PS5,Mac)"}
export ALLOW_GLOBAL_PALBOX_EXPORT=${ALLOW_GLOBAL_PALBOX_EXPORT:-True}
export ALLOW_GLOBAL_PALBOX_IMPORT=${ALLOW_GLOBAL_PALBOX_IMPORT:-False}


if [ "${DEBUG,,}" = true ]; then
cat <<EOF
====Debug====
DIFFICULTY = $DIFFICULTY
RANDOMIZER_TYPE=$RANDOMIZER_TYPE,
RANDOMIZER_SEED=$RANDOMIZER_SEED,
DAYTIME_SPEEDRATE = $DAYTIME_SPEEDRATE
NIGHTTIME_SPEEDRATE = $NIGHTTIME_SPEEDRATE
EXP_RATE = $EXP_RATE
PAL_CAPTURE_RATE = $PAL_CAPTURE_RATE
PAL_SPAWN_NUM_RATE = $PAL_SPAWN_NUM_RATE
PAL_DAMAGE_RATE_ATTACK = $PAL_DAMAGE_RATE_ATTACK
PAL_DAMAGE_RATE_DEFENSE = $PAL_DAMAGE_RATE_DEFENSE
PLAYER_DAMAGE_RATE_ATTACK = $PLAYER_DAMAGE_RATE_ATTACK
PLAYER_DAMAGE_RATE_DEFENSE = $PLAYER_DAMAGE_RATE_DEFENSE
PLAYER_STOMACH_DECREASE_RATE = $PLAYER_STOMACH_DECREASE_RATE
PLAYER_STAMINA_DECREASE_RATE = $PLAYER_STAMINA_DECREASE_RATE
PLAYER_AUTO_HP_REGEN_RATE = $PLAYER_AUTO_HP_REGEN_RATE
PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP = $PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP
PAL_STOMACH_DECREASE_RATE = $PAL_STOMACH_DECREASE_RATE
PAL_STAMINA_DECREASE_RATE = $PAL_STAMINA_DECREASE_RATE
PAL_AUTO_HPREGEN_RATE = $PAL_AUTO_HP_REGEN_RATE
PAL_AUTO_HP_REGEN_RATE_IN_SLEEP = $PAL_AUTO_HP_REGEN_RATE_IN_SLEEP
BUILD_OBJECT_HP_RATE = $BUILD_OBJECT_HP_RATE
BUILD_OBJECT_DAMAGE_RATE = $BUILD_OBJECT_DAMAGE_RATE
BUILD_OBJECT_DETERIORATION_DAMAGE_RATE = $BUILD_OBJECT_DETERIORATION_DAMAGE_RATE
COLLECTION_DROP_RATE = $COLLECTION_DROP_RATE
COLLECTION_OBJECT_HP_RATE = $COLLECTION_OBJECT_HP_RATE
COLLECTION_OBJECT_RESPAWN_SPEED_RATE = $COLLECTION_OBJECT_RESPAWN_SPEED_RATE
ENEMY_DROP_ITEM_RATE = $ENEMY_DROP_ITEM_RATE
DEATH_PENALTY = $DEATH_PENALTY
ENABLE_PLAYER_TO_PLAYER_DAMAGE = $ENABLE_PLAYER_TO_PLAYER_DAMAGE
ENABLE_FRIENDLY_FIRE = $ENABLE_FRIENDLY_FIRE
ENABLE_INVADER_ENEMY = $ENABLE_INVADER_ENEMY
ACTIVE_UNKO = $ACTIVE_UNKO
ENABLE_AIM_ASSIST_PAD = $ENABLE_AIM_ASSIST_PAD
ENABLE_AIM_ASSIST_KEYBOARD = $ENABLE_AIM_ASSIST_KEYBOARD
DROP_ITEM_MAX_NUM = $DROP_ITEM_MAX_NUM
DROP_ITEM_MAX_NUM_UNKO = $DROP_ITEM_MAX_NUM_UNKO
BASE_CAMP_MAX_NUM = $BASE_CAMP_MAX_NUM
BASE_CAMP_WORKER_MAX_NUM = $BASE_CAMP_WORKER_MAX_NUM
DROP_ITEM_ALIVE_MAX_HOURS = $DROP_ITEM_ALIVE_MAX_HOURS
AUTO_RESET_GUILD_NO_ONLINE_PLAYERS = $AUTO_RESET_GUILD_NO_ONLINE_PLAYERS
AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS = $AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS
GUILD_PLAYER_MAX_NUM = $GUILD_PLAYER_MAX_NUM
BASE_CAMP_MAX_NUM_IN_GUILD = $BASE_CAMP_MAX_NUM_IN_GUILD
PAL_EGG_DEFAULT_HATCHING_TIME = $PAL_EGG_DEFAULT_HATCHING_TIME
WORK_SPEED_RATE = $WORK_SPEED_RATE
AUTO_SAVE_SPAN = $AUTO_SAVE_SPAN
IS_MULTIPLAY = $IS_MULTIPLAY
IS_PVP = $IS_PVP
HARDCORE = $HARDCORE
PAL_LOST = $PAL_LOST
CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP = $CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP
ENABLE_NON_LOGIN_PENALTY = $ENABLE_NON_LOGIN_PENALTY
ENABLE_FAST_TRAVEL = $ENABLE_FAST_TRAVEL
IS_START_LOCATION_SELECT_BY_MAP = $IS_START_LOCATION_SELECT_BY_MAP
EXIST_PLAYER_AFTER_LOGOUT = $EXIST_PLAYER_AFTER_LOGOUT
ENABLE_DEFENSE_OTHER_GUILD_PLAYER = $ENABLE_DEFENSE_OTHER_GUILD_PLAYER
INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX = $INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX
BUILD_AREA_LIMIT = $BUILD_AREA_LIMIT
ITEM_WEIGHT_RATE = $ITEM_WEIGHT_RATE
COOP_PLAYER_MAX_NUM = $COOP_PLAYER_MAX_NUM
SERVER_PLAYER_MAX_NUM = $SERVER_PLAYER_MAX_NUM
SERVER_NAME = $SERVER_NAME
SERVER_DESCRIPTION = $SERVER_DESCRIPTION
ADMIN_PASSWORD = $ADMIN_PASSWORD
SERVER_PASSWORD = $SERVER_PASSWORD
PUBLIC_PORT = $PUBLIC_PORT
PUBLIC_IP = $PUBLIC_IP
RCON_ENABLED = $RCON_ENABLED
RCON_PORT = $RCON_PORT
REGION = $REGION
USEAUTH = $USEAUTH
BAN_LIST_URL = $BAN_LIST_URL
REST_API_ENABLED = $REST_API_ENABLED
REST_API_PORT = $REST_API_PORT
SHOW_PLAYER_LIST = $SHOW_PLAYER_LIST
CHAT_POST_LIMIT_PER_MINUTE = $CHAT_POST_LIMIT_PER_MINUTE
USE_BACKUP_SAVE_DATA = $USE_BACKUP_SAVE_DATA
SUPPLY_DROP_SPAN = $SUPPLY_DROP_SPAN
ENABLE_PREDATOR_BOSS_PAL = $ENABLE_PREDATOR_BOSS_PAL,
MAX_BUILDING_LIMIT_NUM = $MAX_BUILDING_LIMIT_NUM,
SERVER_REPLICATE_PAWN_CULL_DISTANCE = $SERVER_REPLICATE_PAWN_CULL_DISTANCE+
CROSSPLAY_PLATFORMS = $CROSSPLAY_PLATFORMS
ALLOW_GLOBAL_PALBOX_EXPORT = $ALLOW_GLOBAL_PALBOX_EXPORT
ALLOW_GLOBAL_PALBOX_IMPORT = $ALLOW_GLOBAL_PALBOX_IMPORT
====Debug====
EOF
fi

cat > "$config_file" <<EOF
[/Script/Pal.PalGameWorldSettings]
$(envsubst < /home/steam/server/files/PalWorldSettings.ini.template | tr -d "\n\r")
EOF

LogSuccess "Compiling PalWorldSettings.ini done!"